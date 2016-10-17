/**
 * Filecontent class
 *
 * FeatShare v0.1-beta - Text integration tool
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
#Include, Logger.ahk
#Include, Contentblock.ahk


/**
 * File content class holding file contents
 */
class Filecontent {

    // Instance variables
    hooks := [] // Core: Holds all strings (hooks) to integrate into the file
    deleteFiles := {} // List of files to delete (delete instructions)
    disabled := False
    errors := []
    neededBy := [] // Who needs this file

    /**
     * Constructor
     *
     * filename        File path to the corresponding file (global encoding)
     */
    __New(basepath, pathpart:="") {
        filename := basepath pathpart
        SplitPath, filename, name, path
        this.subpath := pathpart ? pathpart : filename
        this.name := name
        this.path := Trim(StrReplace(path, "/", "\"), "\")
        this.path := this.path ? this.path "\" : "" // Trailing slash
        this.encoding := this.guessEncoding()
        this.readFromFile()
    }

    /**
     * Checks if the file does exist
     *
     * returns         True if file exists, False otherwise
     */
    exists() {
        return FileExist(this.getFullPath())
    }

    /**
     * Create the file if it does not already exist
     */
    create() {
        if this.exists()
            return
        FileAppend, , this.getFullPath()
    }

    /**
     * Delete the file
     *
     * returns         The ErrorLevel of whether it was successful
     */
    delete() {
        if !this.exists()
            return True
        FileSetAttrib, -R, % this.getFullPath()
        FileDelete, % this.getFullPath()
        Return ErrorLevel
    }

    /**
     * Write to the file
     *
     * only            Indices of hook-blocks to include
     *
     * returns         0 if writing to file failed,
     *                 1 if modfying was successful,
     *                 2 if file was created,
     *                 3 if file did not have to be changed
     */
    writeToFile(only=0) {
        if (ObjCount(only) == 0) || !this.modifiedBy(only) // Don't change
            return 3 // No changes made

        // Make sure base directory exists, in case the file should be created
        if !FileExist(this.path)
            FileCreateDir, % this.path // This cannot be reverted however!

        rtn := this.exists() ? 1 : 2
        // Standard file operations
        file := FileOpen(this.getFullPath(), "w", this.encoding)
        if !IsObject(file)
            return 0
        string := this.toString(only)
        if !file.Write(string) {
            file.Close()
            return 0
        }
        file.Close()
        return rtn
    }

    /**
     * Get content from the file
     */
    readFromFile() {
        FileRead, content, % this.getEncodingPrefix() this.getFullPath()
        this.content := content
    }

    /**
     * Get encoding with FileRead prefix
     *
     * returns         The encoding in FileRead format
     */
    getEncodingPrefix() {
        if !this.encoding
            return ""
        enc := this.encoding
        if (SubStr(enc, 1, 2) == "CP")
            enc := SubStr(enc, 3)
        return "*P" enc " "
    }

    /**
     * Retrieves the encoding of a file (by guessing - caution is advised)
     *
     * https://autohotkey.com/board/topic/95986-filegetencoding-filegetformat/
     */
    guessEncoding() {
        static BOM := {254_255: "CP1201", 255_254: "CP1200", 239_187_191: "CP65001", 0_0_254_255: "CP12001"
            , 255_254_0_0: "CP12000", 43_47_118_43: "CP65000", 43_47_118_47: "CP65000", 43_47_118_56: "CP65000"
            , 43_47_118_57: "CP65000", 221_115_102_115: "CP500", 132_49_149_51: "CP54936"}
        if !this.exists() // Important, otherwise it will be created
            return "CP0"
        If ("D" != aFormat := A_FormatInteger)
            SetFormat, Integer, D
        f := FileOpen(this.getFullPath(), "rw"), f.Pos := 0
        BOM4 := (BOM3 := (BOM2 := f.ReadUChar() "_" f.ReadUChar()) "_" f.ReadUChar()) "_" f.ReadUChar(), f.Close()
        If (aFormat != "D")
            SetFormat, Integer, %aFormat%
        If BOM.HasKey(BOM4)
            return BOM[BOM4]
        else if BOM.HasKey(BOM3)
            return BOM[BOM3]
        else if BOM.HasKey(BOM2)
            return BOM[BOM2]
        // If it contains umlauts (This is a hack, I added. It imposes yet more assumptions on the files! Caution)
        FileRead, f, % "*P0 " this.getFullPath()
        if InStr(f, chr(195) chr(188)) || InStr(f, chr(195) chr(164)) || InStr(f, chr(195) chr(182)) // Ae Oe Ue
        || InStr(f, chr(195) chr(339)) || InStr(f, chr(195) chr(8222)) || InStr(f, chr(195) chr(8211)) // ae oe ue
            return "CP65001"
        else if InStr(f, chr(196)) || InStr(f, chr(214)) || InStr(f, chr(220)) // Ae Oe Ue
        || InStr(f, chr(228)) || InStr(f, chr(246)) || InStr(f, chr(252)) // ae oe ue
            return "CP0"
        // Otherwise prefer UTF-8 over Windows-1252, because it is more common
        FileRead, f, % "*P65001 " this.getFullPath()
        FileGetSize, size, % this.getFullPath()
        return (StrLen(f) == size) ? "CP0" : "CP65001"
    }

    /**
     * Returns the file path as string
     *
     * returns         The path
     */
    getFullPath() {
        return this.path this.name
    }

    /**
     * Returns the content as string
     *
     * only            Indices of hook-blocks to include
     *
     * returns         The string of content of the file
     */
    toString(only=0) {
        if this.isEmtpy()
            return ""
        // Take original content
        rtn := this.content
        // Apply hooks in reversed order (so the onsets do not change)
        for onset, blockList in this.hooks {
            rtnw := SubStr(this.content, 1, -onset)
            offset := -onset
            for 0, block in blockList { // Add the blocks after each other
                rtnw .= block.toString(only) // Pass on the responsibility
                offset := (block.offset > offset) ? block.offset : offset
            }
            rtnw .= SubStr(rtn, offset) // Continue at the heighest of offsets
            rtn := rtnw
        }
        // Purge single carriage returns (\r) that were split from line feeds (\n)
        rtn := RegExReplace(rtn, "\r(?!\n)")
        // Return created string
        return rtn
    }

    /**
     * Returns a file-diff string and coloring instruction
     *
     * only            Indices of hook-blocks to include
     *
     * returns         An object containing diff string and color offsets
     */
    toDiff(only=0) {
        if this.isEmtpy()
            return ""
        // Reverse onsets (copy this.hooks with reversed order)
        reversed := []
        for onset, blockList in this.hooks {
            for 0, block in blockList {
                if !reversed.HasKey(-onset)
                    reversed[-onset] := []
                reversed[-onset].Insert(block) // Negative for reversed order
            }
        }
        // Initialize diff variables
        diff := "--- a\" this.subpath "`n+++ b\" this.subpath "`n"
        gray := {0: StrLen(diff)-1}, green := {}, red := {}
        oldLineNum = 0
        newLineNum = 0
        // Apply hooks in reversed-reversed order (so correct numerical order)
        for onset, blockList in reversed {

            // Retrieve length of entire blockList at this onset
            blocksLength = 0
            for 0, block in blockList
                blocksLength := (block.length > blocksLength) ? block.length : blocksLength

            // Track whether the header has been already set or not
            headerSet := False

            for 0, block in blockList {

                if !block.modifiedBy(only)
                    continue

                // Add header only once per blockList
                if !headerSet {
                    // Get line numbers
                    oldL := lineNum(this.content, 1, onset)
                    oldS := blocksLength ? lineNum(this.content, block.onset, blocksLength) : 1 // Different onset!

                    advanceByLines := oldL - oldLineNum
                    newL := newLineNum + advanceByLines
                    newS := lineNum(block.toString(only))
                    // Get the possible range of three lines above and below
                    oldCntxtB4 := (oldL-3 > 1) ? 3 : oldL-1 // Don't display extra lines when at start of string
                    oldCntxtAf := (oldL+oldS+3 < lineNum(this.content)) ? 3 : 0 // Or at end of string

                    // Update the line number in both old and new content
                    oldLineNum += advanceByLines + oldS
                    newLineNum += advanceByLines + newS

                    // Diff block

                    // Diff header (gray color)
                    diffHeader := "@@ -" oldL-oldCntxtB4 "," oldS+oldCntxtB4+oldCntxtAf " "
                        . "+" newL-oldCntxtB4 "," newS+oldCntxtB4+oldCntxtAf " @@`n"
                    diffHeader := StrReplace(diffHeader, "`r`n", "`n")
                    gray[StrLen(diff)] := StrLen(diff)+StrLen(diffHeader)-1
                    diff .= diffHeader

                    // Context: Three lines prior to diff
                    if oldCntxtB4 // Only if there is enough lines prior to the hook (might be beginning of string)
                        diff .= StrReplace(prefixLines(getLines(this.content, oldL-oldCntxtB4, oldCntxtB4)), "`r`n"
                            , "`n")

                    // Diff orignial (red color)
                    diffRed := prefixLines(getLines(this.content, oldL, oldS), "-")
                    diffRed := StrReplace(diffRed, "`r`n", "`n")
                    red[StrLen(diff)] := StrLen(diff)+StrLen(diffRed)-1
                    diff .= diffRed

                    // Diff new (green color)
                    diffGreen := getContext(this.content, onset, True)

                    // This section is only executed once every blockList
                    headerSet := True
                }

                // Diff new (green color) Block-wise
                diffGreen .= block.toString(only)
            }

            if headerSet { // If there was something added

                diffGreen .= getContext(this.content, block.offset, False)
                diffGreen := StrReplace(prefixLines(diffGreen, "+"), "`r`n", "`n")
                green[StrLen(diff)] := StrLen(diff)+StrLen(diffGreen)-1
                diff .= diffGreen

                // Context: Three lines after to diff
                diff .= StrReplace(prefixLines(getLines(this.content, oldL+oldS, oldCntxtAf)), "`r`n", "`n")
                // Remove left over carriage returns (needs to be RegEx, normal StrReplace won't work for some reason)
                diff := RegExReplace(diff, "\r(?!\n)")
            }
        }
        // Return created string and color positions
        return {"text": diff, "gray": gray, "green": green, "red": red}
    }

    /**
     * Returns whether there is no content
     *
     * returns         True if the file is empty, False otherwise
     */
    isEmpty() {
        return (this.content == "")
    }

    /**
     * Add content hook at the specified position. The Hook onsets are stored
     * with negative sign. This is to apply them later in reversed order. See
     * toString(). When starting with the last hook first (highest onset), the
     * string onsets do not change for the remaining hooks, because the string
     * only changes after their onset.
     * Several anchors may hook at the same onset. This is why this.hooks is a
     * nested list. Otherwise two hooks with the same onset will replace each
     * other.
     *
     * onset           Start position in string
     * length          Length in string
     * placeAtEnd      Place the included (by length) string at end of hook
     *
     * return          New hook if successful, False otherwise
     */
    addHook(onset, length=0, placeAtEnd=False) {
        // if this.isEmpty() // Commented out: We want be able to CREATE files
        //     return False
        newhook := new Contentblock(onset, length, this.content, placeAtEnd)
        // Array.Insert() is broken! Stop changing my indices. You little shit.
        if !this.hooks.HasKey(-(onset-1))
            this.hooks[-(onset-1)] := [] // Nested list
        else if length { // Show warning because, same onsets should be avoided
            log := Logger.getInstance()
            log.warn("Anchors should not use identical onsets! Use at own risk. (Hook length: " length ".)")
        }
        this.hooks[-(onset-1)].Insert(newhook) // Negative for reversed order
        return newhook
    }

    /**
     * Checks whether there are changes made
     *
     * only            Indices of hook-blocks to include
     *
     * returns         True if the blocks impackt the content, False otherwise
     */
    modifiedBy(only=0) {
        // Check each hook if it modified the contents
        for 0, blockList in this.hooks
            for 0, block in blockList
                if block.modifiedBy(only)
                    return True
        return False
    }

    /**
     * Marks this instance as invalid and remembers the reason
     *
     * reason          Reason for disabling the file
     * conditional     Boolean whether to really disable (as extra layer)
     */
    disable(reason, conditional:=True) {
        if !conditional
            return
        this.disabled := True
        this.errors.Insert(reason)
    }

    /**
     * Returns all errors as string
     *
     * returns         The string of all errors
     */
    dispErrors() {
        for 0, msg in this.errors
            errStr .= "`t" msg "`n"
        return errStr
    }
}
