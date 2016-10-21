/**
 * Feature class
 *
 * FeatShare v0.2 - Text integration tool
 * Copyright (C) 2016  szapp <http://github.com/szapp>
 *
 * This file is part of FeatShare.
 * <http://github.com/szapp/FeatShare>
 *
 * FeatShare is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FeatShare is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FeatShare.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * Third-party software:
 *
 * MPRESS v2.19, Copyright (C) 2007-2012 MATCODE Software,
 * for license information see: /mpress/LICENSE
 *
 * AutoHotkey-JSON v2.1.1, 2013-2016 cocobelgica, WTFPL <http://wtfpl.net>
 *
 * Class_RichEdit v0.1.05.00, 2013-2015 just me,
 * Unlicense <http://unlicense.org>
 *
 *
 * Info: Comments are set to C++ style. Escape character is ` e.g.: `n
 */

#CommentFlag, //
#Include, funcStrRegEx.ahk

/**
 * Feature class holding all relevant information
 * All class and instance variables are prefixed by an underscore to minimize
 * the occurrence of equally named anchors.
 */
class Feature {

    // Error constants
    static _DIR_DEL_NOT_ALLOWED   = 1
    static _DIR_COPY_NOT_ALLOWED  = 2
    static _FILE_NOT_FOUND        = 3

    static _reasons :=
    (c Join
    {
        (Feature._DIR_DEL_NOT_ALLOWED):  "Deleting directories is not allowed.",
        (Feature._DIR_COPY_NOT_ALLOWED): "Copying directories is not allowed.",
        (Feature._FILE_NOT_FOUND):       "File not found: "
    }
    )

    // Instance variables
    _traits := [] // Stores custom traits loaded from feature file
    _deleteFiles := {} // List of files to delete (delete instructions)
    _copyFiles := {} // List of files to copy (copy instructions)
    _disabled := False
    _errors := {(Feature._DIR_DEL_NOT_ALLOWED): []
        , (Feature._DIR_COPY_NOT_ALLOWED): []
        , (Feature._FILE_NOT_FOUND): []}

    /**
     * Constructor
     *
     * filepath        Path to the feature file
     */
    __New(filepath) {
        SplitPath, filepath, name, path
        this._path := Trim(StrReplace(path, "/", "\"), "\") "\"
        this._filename := name
    }

    /**
     * Set variables that dont have an instance variable
     *
     * var             Variable name
     * val             Content of the variable
     *
     * returns         Val on success
     */
    __Set(var, val) {
        if this.validVar(var) { // Only valid variable names are allowed
            this._traits[var] := val // Stored as traits
            return val
        }
    }

    /**
     * Get variables that dont have an instance variable
     *
     * var             Variable name
     *
     * returns         Trait variable if found
     */
    __Get(var) {
        if this.validVar(var) // Only valid variable names are allowed
            if ObjHasKey(this._traits, var)
                return this._traits[var]
    }

    /**
     * Checks if a variable name is a valid trait name. This is important to
     * distiguish the 'built-in' instance variables from the customizable _traits
     *
     * var             Variable name
     *
     * returns         True if valid, False otherwise
     */
    validVar(var) {
        nonfree := "_traits,_disabled,_errors,_path,_deleteFiles,_copyFiles,"
            . "_filename,_reasons,_DIR_DEL_NOT_ALLOWED,_DIR_COPY_NOT_ALLOWED,"
            . "_FILE_NOT_FOUND"
        if var not in %nonfree%
            return True
        return False
    }

    /**
     * Mark feature as invalid and store the reason
     *
     * reason          Reason id or string
     * param           Optional details of for the reason
     */
    disable(reason=0, param:=" ") { // Space important, otherwise == 0
        this._disabled := True
        if reason {
            if IsObject(this._errors[reason]) {
                if !ObjHasVal(this._errors[reason], param) // Prevent duplicates
                    this._errors[reason].Insert(param)
            }
            else
                this._errors[reason] := param
        }
    }

    /**
     * Returns all errors as string
     *
     * returns         A string of all errors (_reasons)
     */
    dispErrors() {
        for errNum, msg in this._errors
            if msg && (ObjCount(msg) != 0) {
                tmp := "`t" this._reasons[errNum]
                errStr .= tmp ("`n" tmp).join(msg) "`n"
            }
        return errStr
    }

    /**
     * Returns False if dependencies are not met by feature
     *
     * dependencies    Trait that the feature is checked against
     *
     * returns         True if the feature meets dependencies, False otherwise
     */
    depMet(dependencies) {
        for 0, dep in dependencies {
            // Prefix ! is a logical not, it means dep should NOT a trait
            if (SubStr(dep, 1, 1) == "!") { // Must NOT be a trait
                depTrait := LTrim(dep, "!")
                if this._traits.HasKey(depTrait) // Trait exists
                && ((!IsObject(this._traits[depTrait])) // And is either value
                    || (this._traits[depTrait].GetCapacity() > 0)) // Or list
                    return False
            } else { // Must be a trait
                if !this._traits.HasKey(dep) // Trait does not exist
                || (this._traits[dep].GetCapacity() == 0) // Or is empty list
                    return False
            }
        }
        return True
    }
}
