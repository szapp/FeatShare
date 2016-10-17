;32 mpress
/**
 * FeatShare.ahk - Core of the program
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

#SingleInstance, ignore
#NoTrayIcon
#NoEnv

#Include, lib\AutoHotkey-JSON\JSON.ahk
#Include, lib\Class_RichEdit\Class_RichEdit.ahk
#CommentFlag, //
// External libs above rely on default comment flag, from here on: C++ style comments
#Include, funcStrRegEx.ahk
#Include, funcMaintain.ahk
#Include, Logger.ahk
#Include, Contentblock.ahk
#Include, Filecontent.ahk
#Include, Feature.ahk
#Include, ProgressBar.ahk



// #####################
//  Load configuration
// #####################

// Retrieve Logger singleton instance
log := Logger.getInstance()
log.instantFlush := False // Is set once the path is known, see below

// Retrieve config and regex anchors (config) from JSON file
configFile := "config.json" // Caution: working directory
contObj := new Filecontent(configFile) // This ensures(?) correct encoding
content := contObj.content, contObj := "" // Free file handle
if !content
    exitError("Could not load '" configFile "' (config file).")
try {
    config := JSON.Load(content)
    validateConfig(config) // Also sets up log (timpstamp, showDebug, showWarn)
} catch e // JSON offers very nice exception messages
    exitError("Parsing '" configFile "':`n`n" e.message)
if !config // If config is empty for whatever reason
    exitError("Could not read '" configFile "' (config file).")

// Format title (new lines not allowed, because used as GUI title)
title := replaceAllPatterns(config.title, removeNL, 0, False)
// Global header is the header comment above the block of added lines
globalHeader := (config.globalHeader ? config.globalHeader "`n" : "")

// Get anchors
if !IsObject(config.anchors)
    exitError("Could not find any anchors in '" configFile "' (config file).")

// Fake loop to get the first item of array
for 0, val in config.anchors {
    if !IsObject(val) // Anchors are not in the config file but in separate files
        anchorFiles := True
    break
}
// If anchors are outsourced into files and not part of the config
if anchorFiles {
    anchorFiles := {} // Will serve as a temporary anchor list
    // In this case is a list of file patterns of anchor files
    for path, pattern in config.anchors {
        path := Trim(StrReplace(path, "/", "\"), "\")
        path .= path ? "\" : ""
        Loop, %path%*, 0, 0
        { // OTB not possible here
            // Match filePatterns against regex
            if !RegExMatch(A_LoopFileName, "i)" pattern) || !pattern
                continue
            // Load anchor file content
            contObj := new Filecontent(A_LoopFileFullPath) // This ensures(?) correct encoding
            content := contObj.content, contObj := "" // Free file handle
            if !content
                exitError("Could not load '" A_LoopFileFullPath "' (anchor file).")
            try anchors := JSON.Load(content)
            catch e // JSON offers very nice exception messages
                exitError("Parsing '" A_LoopFileFullPath "':`n`n" e.message)
            if !anchors // If anchors is empty for whatever reason
                exitError("Could not read '" A_LoopFileFullPath "' (anchor file).")
            // Add all anchors from this file to anchor list
            for 0, anchor in anchors
                anchorFiles.Insert(anchor)
        }
    }
    config.anchors := anchorFiles // Anchors are now in config.anchors regardless from which file
}
if !ObjCount(config.anchors)
    exitError("No valid anchors found.")

log.event("-------------- Start Preprocessing -------------- ")



// ##################################
//  Load feature files
// ##################################

// RegEx flags
flgs := "`a"
// Case-insensitive matching.
if !config.features.anchorPattern.flags.caseSensitive
    flgs .= "i"
// DotAll: Period (.) also matches newlines (otherwise, it does not).
if config.features.anchorPattern.flags.dotInclNL
    flgs .= "s"
// MultiLine: Views haystack as a collection of individual lines.
if config.features.anchorPattern.flags.multiLine
    flgs .= "m"
// Ungreedy: Makes the *+?{} consume only those chars absolutely necessary.
if config.features.anchorPattern.flags.ungreedy
    flgs .= "U"

// Read features from files in specified directory
allFeats := [] // Array of all features
featIdx = 0 // Index for array
// File loop: Collects all feature files (non-recursive)
rootDir := Trim(StrReplace(config.features.path, "/", "\"), "\")
rootDir .= rootDir ? "\" : "" // Needs to be empty string if workingdir
if !config.features.anchorPattern.regex
    exitError("Could not find anchor pattern regex in '" configFile "' (config file).")
Loop, %rootDir%*, 0, 0
{ // OTB not possible here
    // Match filePatterns against regex
    if !RegExMatch(A_LoopFileName, "i)" config.features.filePattern) || !config.features.filePattern
        continue
    // Get content of feature file
    contObj := new Filecontent(A_LoopFileFullPath) // Ensures correct encoding
    content := contObj.content, contObj := "" // Free file handle
    // Create new feature object
    feat := new Feature(A_LoopFileFullPath)
    // Get all informaion
    idx = 1 // Idx is each needle's starting position
    While RegExMatch(content, flgs "O)" config.features.anchorPattern.regex, match, idx) {
        idx := patternPos(config.features.anchorPattern.value) + patternLen(config.features.anchorPattern.value)
        key := patternVal(config.features.anchorPattern.key)
        val := patternVal(config.features.anchorPattern.value)
        if !feat.validVar(key) || ((feat[key] := val) != val)
            log.warn("Property name invalid: " key " (" feat._filename ")")
    }
    // Add the feature to the feature list
    allFeats[++featIdx] := feat // Array.Insert() is unreliable!
}
// Free variables
feat := idx := match := ""



// ############
//  Setup GUI
// ############

// Make sure feature files are present
if (ObjCount(allFeats) == 0)
    exitError("Could not find any files matching the pattern`n '" config.features.filePattern "' in '" rootDir "'")

// Get infoText anchor name
guiDescr := config.features.infoTextAnchor
// GUI to select features from
Gui, setup:Default
Gui, setup:-DPIScale +HwndsetupHWND
Gui, setup:Margin, 15, 15
Gui, setup:Font, s8, Tahoma
Gui, setup:Add, Text, xm Section, Please choose the features to install:
Gui, setup:Font, c800000 bold
Gui, setup:Add, Text, x+189, % config.dryrun ? "[ D R Y   R U N ]" : ""
Gui, setup:Font, cDefault norm
Gui, setup:Add, GroupBox, xm ym+14 w115 h173,
Gui, setup:Add, Text, xp+8 yp+12 w100 h153 Disabled vinfo, % (allFeats[1][guiDescr]
    ? allFeats[1][guiDescr] : RegExReplace(allFeats[1]._filename, "\.[^.]+$")) // If no GUI description, show file name
Gui, setup:Add, ListView, ys+20 x140 w325 h165 +Checked +ReadOnly -Hdr +AltSubmit gsetupFeatureList, Features
for 0, feat in allFeats // Enter alle feature names in the listview
    LV_Add("Check", RegExReplace(feat._filename, "\.[^.]+$")) // Without ext
LV_ModifyCol() // Auto-size each column to fit its contents.
Gui, setup:Add, GroupBox, xm w450 h57 -wrap
    , % config.installInstruction ? config.installInstruction : "Choose the directory"
Gui, setup:Add, Edit, xp+12 yp+24 w338 -wrap vinstPath, % config.defaultPath
Gui, setup:Add, Button, yp-1 x+5 w85 h22 -wrap vinstPathBtn gsetupButtonBrowse, Browse...
Gui, setup:Add, Button, x260  w100 h22 Default -wrap gValidateAll, &Install
Gui, setup:Add, Button, yp x365 w100 h22 -wrap, &Cancel Setup
Gui, setup:Show, xcenter ycenter, %title%

return // Wait for GUI events (button press)

ValidateAll:
Gui, setup:+OwnDialogs // Subsequent windows are children of setup GUI
Gui, setup:Submit, NoHide // Keep GUI until verified there is no errors
// Directory does not exist
if !FileExist(instPath) {
    MsgBox, 48, Directory could not be opened, Directory could not be found.
    return // Go back to GUI
}
// Get selected features
rowNum := 0
features := []
While rowNum := LV_GetNext(rowNum, "Checked")
    features[rowNum] := allFeats[rowNum]
// Nothing selected for installation
if (ObjCount(features) == 0) {
    MsgBox, 64, Nothing selected, No feature was selected for installation.
    return // Go back to GUI
}



// ################################
//  All clear, no errors. Proceed
// ################################

Gui, setup:Destroy
// Set paths set to logger
destDir := RTrim(StrReplace(instPath, "/", "\"), "\") "\"
backupDir := destDir "_backup-"
Loop, Parse, title, , \/:*?<>|`"
    backupDir .= A_LoopField // Backup directory name from title
backupDir := RTrim(backupDir, "\") "\" // In case there is no valid title
// Start log
if !config.dryRun && !config.diffGUI { // Dry run does not write log to file
    FileCreateDir, %backupDir% // Needed for log
    log.path := backupDir "setup.log"
    log.instantFlush := config.log.instantFlush
}

// Arrays for replacing newlines (escaped newlines/tabs, remove newlines/tabs)
replaceNL := {"\r": "", "\n": "`n", "\t": "`t"}
removeNL := {"\r": "", "\n": "", "\t": "", "`n": "", "`t": ""}

// Array holding all custom variablename-value pairs as defined in config
storedVars := {}

// Files array
files := {}

// Create progress bar to display information
prgBar := new ProgressBar(ObjCount(config.anchors)+5, title, "Preparing changes")
if !prgBar
    log.warn("Failed to create Progressbar")
prgBar.show()



// ##############
//  Parse loop
// ##############

// Shorter variable names for file copy and file delete instruction
fileDel := config.features.fileDeleteAnchor
fileCopy := config.features.fileCopyAnchor

// Iterate all regex entries (anchors) automatically
for anchIdx, anchor in config.anchors {

    // Advance progress bar
    prgBar.section(0, anchor.description)

    // Needs to be freed because it might contain matches from last iteration!
    match := "" // Globally used

    // This is the file to edit
    if !files.HasKey(anchor.path)
        files.Insert(anchor.path, new Filecontent(destDir, anchor.path))
    // File is added to the array regardless of whether it exists. Treated later
    file := files[anchor.path]

    // Before anything else, quickly check whether the anchor is needed
    anchorNeeded := False
    for idx, feat in features
        if feat.depMet(anchor.dependencies) {
            anchorNeeded := True
            file.neededBy.Insert(idx)
        }

    // Global dependencies
    for 0, dep in anchor.globalDependencies {
        depVar := LTrim(dep, "!")
        // Prefix ! is a logical not, it means dep should not be in storedVars
        if ((SubStr(dep, 1, 1) != "!") && !storedVars.HasKey("#" depVar))
        || ((SubStr(dep, 1, 1) == "!") && storedVars.HasKey("#" depVar)) {
            file.disable("Global dependencies not met. (" anchor.description ")", anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx "(" file.name "): Global dependency not "
                . "met: " dep ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
            continue 2 // Continue outer loop
        }
    }

    // Delete files (by anchor)
    for 0, dFile in anchor.deleteFiles.paths {
        // Replace text to create file path
        fileIq := replaceAllPatterns(dFile, anchor.deleteFiles.replace)
        fileIq := Trim(destDir StrReplace(fileIq, "/", "\"), "\")

        // FileIq (origin path) must be a file (not a directory)
        if InStr(FileExist(fileIq), "D") {
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Not allowed to delete directories (" fileIq ")"
                . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : "")) // If string
            file.disable("Not allowed to delete directories (" fileIq ")  (" anchor.description ")"
                , anchorNeeded && !anchor.ignoreOnFail)
        } else if !FileExist(fileIq) // And should exist
            log.warn("File not found (" fileIq ")") // Only warn
        else // Otherwise add to instructions
            file.deleteFiles[fileIq] := fileIq
    }

    // Allow custom variables from previous anchors in needle
    anchor.regex.needle := replaceAllPatterns(anchor.regex.needle, storedVars)

    // RegEx flags
    flgs := "`a"
    // Case-insensitive matching (flgs holds regex flags (AHK specific)).
    if !anchor.regex.flags.caseSensitive
        flgs .= "i"
    // DotAll: Period (.) also matches newlines (otherwise, it does not).
    if anchor.regex.flags.dotInclNL
        flgs .= "s"
    // MultiLine: Views Haystack as a collection of individual lines.
    if anchor.regex.flags.multiLine
        flgs .= "m"
    // Ungreedy: Makes the *+?{} consume only those chars absolutely necessary.
    if anchor.regex.flags.ungreedy
        flgs .= "U"
    // Occurrence: Matches the x-th occurrence.
    // anchor.regexOccurrence // Automatic (RegExMatchOcc-wrapper function)

    // Check if specific RegEx matches file content (flags: "O)" store object)
    if !RegExMatchOcc(file.content, flgs "O)" anchor.regex.needle, match, 1, anchor.regex.flags.occurrence) {
        if !file.exists() {
            file.disable("File not found ("  file.getFullPath() ")", anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "File not found ("  file.getFullPath() ")"
                . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : "")) // If string
        } else {
            file.disable("RegEx not matched: [" StrReplace(flgs, "`a") "] '" anchor.regex.needle "'  ("
                .   anchor.description ")", anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx  "(" file.name "): "
                . "RegEx not matched: [" StrReplace(flgs, "`a") "] '" anchor.regex.needle "'"
                . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : "")) // If string
        }
        continue
    }

    // Get matching brackets positions
    extendedPatterns := {}
    for var, startIdx in anchor.matchBracket {
        // Find respective closing bracket or parenthesis
        if !(obj := matchClosed(file.content, patternPos(startIdx))) {
            file.disable("Matched bracket not found. (" anchor.description ")", anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx  "(" file.name "): Matched bracket not "
                . "found." ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
            continue
        }
        extendedPatterns[var] := obj
    }

    // Store variables (Either $patterns or strings containing $patterns)
    for var, val in anchor.storeVars
        storedVars.Insert("#" var, patternVal(replaceAllPatterns(val, storedVars)))

    // Create new hook at specified positions
    if !anchor.hook
        continue // No hook. This is for conditional anchors
    if !(hook := file.addHook(evalExprPos(anchor.hook.start), evalExprLen(anchor.hook.length), anchor.hook.before)) {
        // Hook failed
        file.disable("Hookstart and/or hooklength invalid. (" anchor.description ")"
            , anchorNeeded && !anchor.ignoreOnFail)
        log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx  "(" file.name "): Hookstart/-length "
            . "invalid." ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
        // Remove stored variables (because this anchors failed)
        for var, val in anchor.storeVars
            storedVars.Remove("#" var)
        continue
    }

    // Replace text in a matched substring
    rplcHook := []
    for subpattern, replaceText in anchor.hook.replace { // Re-sort first, so positions in string do not change
        if (SubStr(subpattern, 1, 1) != "$") {
            file.disable("Hookreplace invalid. (" anchor.description "): " subpattern
                , anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx  "(" file.name "): Hookreplace invalid."
                . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : "")) // If string
            // Remove stored variables (because this anchors failed)
            for var, val in anchor.storeVars
                storedVars.Remove("#" var)
            continue
        }
        rplcHook[-patternPos(subpattern)] := [subpattern, replaceText] // Reversed order: replace later pos first
    }
    for 0, rplc in rplcHook {
        replaceTxt := repeatPadding(rplc[2]) // Replace {chr:num} by respective padding
        if !hook.replace(hook.rest, patternPos(rplc[1]), patternLen(rplc[1]), replaceTxt) {
            file.disable("Hookreplace invalid. (" anchor.description "): ->" rplc[1]
                , anchorNeeded && !anchor.ignoreOnFail)
            log.issue(anchorNeeded && !anchor.ignoreOnFail, "Anchor #" anchIdx  "(" file.name "): Hookreplace invalid."
                . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : "")) // If string
            // Remove stored variables (because this anchors failed)
            for var, val in anchor.storeVars
                storedVars.Remove("#" var)
            continue
        }
    }

    // Insert new content before or after (anchor.hook.before) hook
    // In case someone escaped the newline or tab characters
    anchor.insert.string := replaceAllPatterns(anchor.insert.string, replaceNL, 0, False)

    // Iterate over features and add those meeting the dependencies
    // Perform three checks:
    // 1. Delete-file instructions
    // 2. Copy-file instructions
    // 3. Insert new content at hook
    for idx, feat in features {

        // Advance progress bar
        prgBar.step(feat._filename)

        // Check if feature meets all dependencies (feature doesn't need anchor)
        if !feat.depMet(anchor.dependencies)
            continue

        // 1. Delete-file instructions
        if feat[fileDel.name] && fileDel.regex {

            // RegEx flags
            flgs := "`a"
            // Case-insensitive matching.
            if !fileDel.flags.caseSensitive
                flgs .= "i"
            // DotAll: Period (.) also matches newlines (otherwise, it doesn't).
            if fileDel.flags.dotInclNL
                flgs .= "s"
            // MultiLine: Views haystack as a collection of individual lines.
            if fileDel.flags.multiLine
                flgs .= "m"
            // Ungreedy: *+?{} only consumes those chars absolutely necessary.
            if fileDel.flags.ungreedy
                flgs .= "U"

            // Parse all file paths
            pos = 1
            While pos := RegExMatch(feat[fileDel.name], flgs "O)" fileDel.regex, match, pos) {
                pos += match.Len(0)

                fileIq := Trim(destDir StrReplace(patternVal(fileDel.filePath), "/", "\"), "\`r`n")

                // fileIq (origin path) must be a file
                if InStr(FileExist(fileIq), "D") {
                    log.issue(anchorNeeded && !anchor.ignoreOnFail, "Not allowed to delete directories (" fileIq ")"
                        . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
                    feat.disable(Feature._DIR_DEL_NOT_ALLOWED, fileIq)
                } else if !FileExist(fileIq) // And should exist
                    log.warn("File not found (" fileIq ")") // Only warn
                else // Otherwise add to instructions
                    feat._deleteFiles[fileIq] := fileIq
            }
        }

        // 2. Copy-file instructions
        if feat[fileCopy.name] && fileCopy.regex {

            // RegEx flags
            flgs := "`a"
            // Case-insensitive matching.
            if !fileCopy.flags.caseSensitive
                flgs .= "i"
            // DotAll: Period (.) also matches newlines (otherwise, it doesn't).
            if fileCopy.flags.dotInclNL
                flgs .= "s"
            // MultiLine: Views haystack as a collection of individual lines.
            if fileCopy.flags.multiLine
                flgs .= "m"
            // Ungreedy: *+?{} only consumes those chars absolutely necessary.
            if fileCopy.flags.ungreedy
                flgs .= "U"

            // Parse all from-to copy pairs
            pos = 1
            While pos := RegExMatch(feat[fileCopy.name], flgs "O)" fileCopy.regex, match, pos) {
                pos += match.Len(0)

                from := Trim(rootDir Trim(StrReplace(patternVal(fileCopy.fromPath), "/", "\"), "`r`n"), "\")
                to := destDir Trim(StrReplace(patternVal(fileCopy.toPath), "/", "\"), "`r`n")

                // The destination must be the filename (for backing up)
                if (SubStr(to, 0) == "\") || InStr(FileExist(to), "D") {
                    SplitPath, from, fromFile
                    to := RTrim(to, "\")
                    to := (to ? to "\" : "") fromFile
                }

                // From (origin path) must be a file
                if InStr(FileExist(from), "D") {
                    log.issue(anchorNeeded && !anchor.ignoreOnFail, "Not allowed to copy directories (" from ")"
                        . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
                    feat.disable(Feature._DIR_COPY_NOT_ALLOWED, from)
                } else if !FileExist(from) { // And must exist
                    log.issue(anchorNeeded && !anchor.ignoreOnFail, "File not found (" from ")"
                        . ((anchor.ignoreOnFail && anchor.ignoreOnFail != 1) ? " - " anchor.ignoreOnFail : ""))
                    feat.disable(Feature._FILE_NOT_FOUND, from)
                } else // Otherwise add to instructions
                    feat._copyFiles[to] := from // This way around!
            }
        }

        // 3. Insert new content at hook
        if anchor.insert.string {

            // Replace insert-text
            if (ObjCount(anchor.insert.replace) == 0)
                anchor.insert.replace := {"": ""} // Replace-loop at least once
            insert := replaceAllPatterns(anchor.insert.string, anchor.insert.replace, feat)

            // Add indent to insert-text
            indent := replaceAllPatterns(anchor.insert.indent.string, anchor.insert.replace, feat)
            insert := replaceAllPatterns(insert, {"`n(.)": "`n" indent "$1"}, 0, False) // Period: only at full lines
            if !anchor.insert.indent.exclFirstLine
                insert := indent insert

            // Strip trailing newlines from insert-text
            if anchor.insert.stripTrailingNL
                insert := RTrim(insert, "`n")

            // Add the hook with the idx of the feature so we can keep track of it
            if !hook.search(insert)
                hook.add(idx, insert)
        }
    }

    // Add a new line before/after the insert block
    hook.nlb4 := anchor.newlinesBefore
    hook.nlaf := anchor.newlinesAfter

    // Add the (global or local) header
    if anchor.setHeader {
        // LocalHeader may contain a reference to globalHeader and padding
        if anchor.localHeader
            anchor.localHeader := replaceAllPatterns(anchor.localHeader, {"globalHeader": globalHeader})
        else
            anchor.localHeader := globalHeader

        // Add indent to header
        if !anchor.insert.indent.exclHeader {
            indent := replaceAllPatterns(anchor.insert.indent.string, anchor.insert.replace)
            anchor.localHeader := replaceAllPatterns(anchor.localHeader, {"`n(.)": "`n" indent "$1"}, 0, False)
            anchor.localHeader := indent anchor.localHeader
        }

        // Make sure it ends with a line break
        hook.setHeader(anchor.localHeader ((SubStr(anchor.localHeader, 0) != "`n") ? "`n" : ""))
    } else {
        // Key 0 (header slot) needs to be filled anyway for newlines before
         hook.setHeader("")
    }

    // Another set of replace instructions, since incrementing needs to wait
    // until we know which feature is actually valid for ALL anchors.
    // These replacements will not take effect immediately but are performed
    // when calling hook.toString() (called in the end when writing the files).
    // Here we need to replace the replaceText with storedVars before passing it
    // to the hook.
    for idx, obj in anchor.finalReplace {

        // Wrap needle in escaped (for RegEx) brackets
        // anchor.finalReplace[idx].needle := "\{" obj.needle "\}"

        // Like in replaceAllPatterns (for replace)
        if storedVars.HasKey("#" obj.replace)
            anchor.finalReplace[idx].replace := storedVars["#" obj.replace]
        else
            anchor.finalReplace[idx].replace := patternVal(obj.replace)

        // Like in replaceAllPatterns (for first)
        if storedVars.HasKey("#" obj.first)
            anchor.finalReplace[idx].first := storedVars["#" obj.first]
        else
            anchor.finalReplace[idx].first := patternVal(obj.first)

        // Like in replaceAllPatterns (for last)
        if storedVars.HasKey("#" obj.last)
            anchor.finalReplace[idx].last := storedVars["#" obj.last]
        else
            anchor.finalReplace[idx].last := patternVal(obj.last)
    }
    // Add array to hook
    hook.finalReplace := anchor.finalReplace
}
// Free variables (not really necessary)
file := hook := flgs := extendedPatterns := indent := insert := ""
fileDel := pos := fileIq := fileCopy := from := to := ""



// ##################
//  Error-handling
// ##################

// Advance progressbar
prgBar.section("Error-handling")

// This is done in a separate loop because everything needs to be set before

// Report errors of files
prgBar.step("Check files")
errs := "" // Error string
for 0, file in files {

    // Iterate over features that need this file
    for 0, idx in file.neededBy
        if file.disabled {
            feat := features[idx]
            feat.disable()
            msg := "Feature '" feat._filename "' relies on invalid file (" file.getFullPath() ")"
            log.error(msg)
        }

    // Throw errors only for needed files
    if (ObjCount(file.neededBy) > 0) && file.disabled
        errs .= file.name ":`n" file.dispErrors() "`n"
}

// Create validFeats list from each feature._disabled
prgBar.step("Check features")
validFeats := [] // This array holds all valid features
disabled := "" // Disabled string
for idx, feat in features {
    if !feat._disabled { // Dont enter in validFeats if disabled
        validFeats.Insert(idx)
        log.event("Valid feature: " feat._filename)
    } else {
        // Add to disabled string
        disabled .= feat._filename "`n"
        if feat.dispErrors() // If the feature has error messages list them
            errs .= feat._filename ":`n" feat.dispErrors() "`n"
    }
}
log.event("Total valid features: " ObjCount(validFeats))

// If we encountered errors (which have been kept silent so far), report them
if errs || disabled {
    // Hide the progress bar for the duration of this GUI
    prgBar.hide()

    // This GUI should be pretty self-explicatory
    contuneff := "Continue with unaffected (" ObjCount(validFeats) ")"
    Gui, errors:-DPIScale +HwnderrorsHWND +Resize +MinSize
    Gui, errors:Margin, 15, 15
    Gui, errors:Font, s8 Tahoma
    Gui, errors:Add, Text, w450, The following features cannot be installed:
    Gui, errors:Add, Edit, w450 h130 +ReadOnly -Wrap +HScroll verrorsEdisabled, %disabled%
    Gui, errors:Add, Text, w450 verrorsToccured, The following errors occured:
    Gui, errors:Add, Edit, w450 h250 +ReadOnly -Wrap +HScroll verrorsEerrs, %errs%
    Gui, errors:Add, Button, x200  w160 h25 Default -wrap gGo vCon, %contuneff%
    Gui, errors:Add, Button, yp x370 w100 h25 -wrap vCancel, &Cancel Setup
    Gui, errors:Show, xcenter ycenter, Errors
    GuiControl, errors:Focus, Cancel // Do not focus edit box (will select all)
    if (ObjCount(validFeats) == 0) { // If nothing can be done don't allow it
        GuiControl, errors:Disable, Con
        GuiControl, errors:Hide, Con
    }
    return // Wait for GUI events (button press)
}



// ########################
//  Show potential changes
// ########################
// Label to jump here if continuing from error GUI
Go:
Gui, errors:Destroy
prgBar.show() // Show progress bar

// Update features (feature list) to only contain validFeats
selectedFeats := features
features := {}
for 0, idx in validFeats
    features[idx] := selectedFeats[idx]
// Same for files (need files only)
allFiles := files
files := {}
for key, file in allFiles
    if !file.disabled && (ObjCount(file.neededBy) > 0)
        files[key] := file

// If this is a dry run, no changes will be actually written, but displayed
if config.dryRun || config.diffGUI {
    log.event("Preprocessing complete, display potential changes.")
    log.event("") // Add semi-new line to emphasize real changes coming now

    if config.dryRun {
        log.event("Backing up files... skipping (Dry run)")
        log.event("Delete files... skipping (Dry run)")
        log.event("Copy new files... skipping (Dry run)")
        log.event("Write changes to files... skipping (Dry run)")
    }

    // Advance progress bar
    prgBar.section("Retrieve file contents")

    // Build strings from modified files (but don't write to file)
    tabList := ""
    for desc, file in files {
        prgBar.step(file.name) // Display file name
        if file.modifiedBy(validFeats) {
            file.full := file.toString(validFeats)
            file.diff := file.toDiff(validFeats)
            tabList .= RegExReplace(desc, ".*\\") "|"
        }
    }

    // Advance progress bar
    prgBar.section("Perform diff coloring")
    if config.dryRun
        log.event("---------------- Dry run successful ---------------`n") // NL

    // Get GUI color scheme
    style := config.diffGUIstyles[config.diffGUIstyle]
    if !ObjCount(style)
        exitError("Invalid diff GUI color scheme")

    // Create dry run GUI
    Gui, diff:-DPIScale +HwnddiffHWND +Resize +MinSize
    Gui, diff:Margin, 15, 5
    Gui, diff:Font, s8, Tahoma
    Gui, diff:Add, Tab2, w800 h550 -Wrap vtabs AltSubmit, Log|%tabList%
    Gui, diff:Font, s9, Lucida Console
    i = 0 // Iterating by index prevents ambiguities
    re := [] // Holds richtext editors
    prgBar.step("Log file") // Display status
    Gui, diff:Tab, % ++i
    Gui, diff:Add, Text, , Log
    If !IsObject(re[i] := new RichEdit("diff", "w765 h490", True))
        exitError(ErrorLevel)
    re[i].SetFont({"Color": "0x" style.default})
    re[i].ReplaceSel(log.buffer)
    re[i].SetOptions(["READONLY"], "SET")
    re[i].SetBkgndColor("0x" style.background)
    // Color log: Double colons (::)
    pos = 1
    len = 0
    while pos := RegExMatch(log.buffer, "P):\:(?:.{1,10}):\:", len, pos+len) {
        re[i].SetSel(pos-1, pos+len)
        re[i].SetFont({Color: "0X" style.info})
    }
    // Color log: Warnings, errors, critical errors
    pos = 1
    len = 0
    while pos := RegExMatch(log.buffer, "P)(?<=:\:\s)(WARNING|ERROR|CRITICAL)(?=\s{1,4}:\:)", len, pos+len) {
        re[i].SetSel(pos-1, pos+len)
        re[i].SetFont({Color: "0X" style.remove})
    }
    // Color log: Debug messages
    pos = 1
    len = 0
    while pos := RegExMatch(log.buffer, "P)(?<=:\:\s)DEBUG(?=\s{4}:\:)", len, pos+len) {
        re[i].SetSel(pos-1, pos+len)
        re[i].SetFont({Color: "0x" style.info})
    }
    re[i].Deselect()
    re[i].SetScrollPos(0, 0) // Scroll back up

    // Richtext field for each file
    for desc, file in files {
        if !file.modifiedBy(validFeats)
            continue
        prgBar.step(desc) // Display file name
        Gui, diff:Tab, % ++i
        Gui, diff:Add, Text, , %desc%
        If !IsObject(re[i] := new RichEdit("diff", "w765 h490", True))
            exitError(ErrorLevel)
        re[i].SetDefaultTabs(re[i].GetMeasurement()*0.225) // ###TODO### tabsize
        re[i].SetFont({"Color": "0x" style.default})
        re[i].ReplaceSel(file.diff["text"])
        re[i].SetOptions(["READONLY"], "SET")
        re[i].SetBkgndColor("0x" style.background)
        // Color gray
        for start, end in file.diff["gray"] {
            re[i].SetSel(start, end)
            re[i].SetFont({"Color": "0x" style.info})
        }
        // Color red
        for start, end in file.diff["red"] {
            re[i].SetSel(start, end)
            re[i].SetFont({"Color": "0X" style.remove})
        }
        // Color green
        for start, end in file.diff["green"] {
            re[i].SetSel(start, end)
            re[i].SetFont({"Color": "0X" style.add})
        }
        re[i].Deselect()
        re[i].SetScrollPos(0, 0) // Scroll back up
    }
    Gui, diff:Tab // From here on general GUI (not inside a tab)
    Gui, diff:Font, s8, Tahoma
    if config.dryrun {
        Gui, diff:Font, c800000 bold
        Gui, diff:Add, Text, y+29 xm+5 vdiffTdryrun, [ D R Y   R U N ]
        Gui, diff:Font, cDefault norm
        Gui, diff:Add, Button, yp-4 x115 w140 h22 -wrap gdiffButtonSaveToFile vdiffBsave, &Save diff to file...
        Gui, diff:Add, Button, yp x705 w110 h22 -wrap vdiffBclose Default, &Close
    } else {
        Gui, diff:Add, Button, y+25 xm w140 h22 -wrap gdiffButtonSaveToFile vdiffBsave, &Save diff to file...
        Gui, diff:Add, Button, yp x572 w130 h22 -wrap gGo2 vdiffBaccept Default, &Accept Changes
        Gui, diff:Add, Button, yp x+4 w110 h22 -wrap vdiffBcancel, &Cancel
    }
    prgBar.hide() // Hide the progress bar
    Gui, diff:Show, xcenter ycenter w830 h600, %title% - Potential File Changes
    GuiControl, diff:Focus, tabs // Do not focus edit box (select all)
    return

    // Mouse wheel changes tabs
    #If WinActive("ahk_id  " diffHWND)
    ~WheelUp::
    MouseGetPos, , , , control
    if InStr(control, "RICHEDIT50W") { // Only when mouse not in edit box
        GuiControlGet, control2, Focus
        if !InStr(control2, "RICHEDIT50W")
            GuiControl, diff:Focus, %control%
        return
    }
    GuiControl, diff:Focus, tabs // Do not focus edit box (no scrolling)
    GuiControlGet, tabs, diff:
    GuiControl, diff:Choose, tabs, % tabs-1 // Switch to previous tab
    return

    #If WinActive("ahk_id  " diffHWND)
    ~WheelDown::
    MouseGetPos, , , , control
    if InStr(control, "RICHEDIT50W") { // Only when mouse not in edit box
        GuiControlGet, control2, Focus
        if !InStr(control2, "RICHEDIT50W")
            GuiControl, diff:Focus, %control%
        return
    }
    GuiControl, diff:Focus, tabs // Do not focus edit box (no scrolling)
    GuiControlGet, tabs, diff:
    GuiControl, diff:Choose, tabs, % tabs+1 // Switch to next tab
    return
}



// ##################
//  Perform changes
// ##################
// Label to jump here if continuing from diff GUI
Go2:
Gui, diff:Destroy
prgBar.show() // Show progress bar

if config.diffGUI { // Finally create the log in the case of diffGUI
    FileCreateDir, %backupDir% // Needed for log
    log.path := backupDir "setup.log"
    log.instantFlush := config.log.instantFlush
    if log.instantFlush
        log.flush() // Flush events logged so far to file
}

// From here on: !config.dryRun
log.event("Preprocessing complete, write changes.")
log.event("") // Add semi-new line to emphasize real changes coming now



// ###############
//  Backup files
// ###############

// Advance progress bar
prgBar.section("Backing up files")

// Backup files to write/delete
for 0, file in files {
    prgBar.step(file.name) // Show file name (progress bar)

    if !file.exists() // Only warn, since files might be meant to be created
        log.warn("Could not backup '" file.getFullPath() "'")
    else if file.modifiedBy(validFeats) { // Only backup if it will be modified
        // Retrieve backup path
        thsBckDir := StrReplace(file.path, destDir, backupDir)
        FileCreateDir, %thsBckDir% // Create all parent directories
        FileCopy, % file.getFullPath(), %thsBckDir%, 1 // Force (overwrite) copy
        if ErrorLevel // If ErrorLevel > 0 then error
            exitError("Could not backup '" file.name "'")
        log.event("BACKED UP: '" file.getFullPath() "' to '" thsBckDir "'")
    }

    // Also backup designated deletion files
    for 0, dFile in file.deleteFiles {
        prgBar.step(dFile) // Show file name (progress bar)
        // Retrieve backup path
        thsBckDir := StrReplace(dFile, destDir, backupDir)
        SplitPath, thsBckDir, , thsBckDir // We want the dir path not the file path!
        thsBckDir .= thsBckDir ? "\" : ""
        FileCreateDir, %thsBckDir% // Create all parent directories
        FileCopy, %dFile%, %thsBckDir%, 1 // Force (overwrite) copy
        if ErrorLevel { // If ErrorLevel > 0 then error
            SplitPath, dFile, fileName
            exitError("Could not backup '" fileName "'")
        }
        log.event("BACKED UP: '" dFile "' to '" thsBckDir "'")
    }
}

// Backup files to delete and possibly overwrite (copy)
for 0, feat in features {

    // Backup files to delete
    for 0, dFile in feat._deleteFiles {
        prgBar.step(dFile) // Show file name (progress bar)
        // Retrieve backup path
        thsBckDir := StrReplace(dFile, destDir, backupDir)
        SplitPath, thsBckDir, , thsBckDir // We want the dir path not the file path!
        thsBckDir .= thsBckDir ? "\" : ""
        FileCreateDir, %thsBckDir% // Create all parent directories
        FileCopy, %dFile%, %thsBckDir%, 1 // Force (overwrite) copy
        if ErrorLevel { // If ErrorLevel > 0 then error
            SplitPath, dFile, fileName
            exitError("Could not backup '" fileName "'")
        }
        log.event("BACKED UP: '" dFile "' to '" thsBckDir "'")
    }

    // Backup files that might be overwritten (copy-files instructions)
    for to, from in feat._copyFiles { // Iterate over copy-file instructions
        SplitPath, from, fromFile
        prgBar.step(fromFile) // Display file name

        if !FileExist(to) {
            log.warn("Could not backup '" to "'. File does not exist.")
            continue
        }

        // Retrieve backup path
        thsBckDir := StrReplace(to, destDir, backupDir)
        SplitPath, thsBckDir, , thsBckDir // We want the dir path not the file path!
        thsBckDir .= thsBckDir ? "\" : ""
        FileCreateDir, %thsBckDir% // Create all parent directories
        FileCopy, %to%, %thsBckDir%, 1 // Force (overwrite) copy
        if ErrorLevel { // If ErrorLevel > 0 then error
            SplitPath, to, fileName // The file MUST be backed up, because it exists!
            exitError("Could not backup '" fileName "'")
        }
        log.event("BACKED UP: '" to "' to '" thsBckDir "'")
    }
}



// Here starts the serious business: Deleting, Copying and Writing of files

// ###############
//  Delete files
// ###############
// First delete, in case someone didn't understand how the anchors work and
// tries to have all files deleted before copying the new ones. If files were
// copied first, then they would get deleted right after

// Advance progress bar
prgBar.section("Delete files")

// Delete files by deleteFiles instructions from files
for 0, file in files
    for 0, dFile in file.deleteFiles {
        SplitPath, dFile, fileName
        prgBar.step(dFile) // Show file name (progress bar)
        FileSetAttrib, -R, %dFile%
        FileDelete, %dFile%
        if ErrorLevel // If ErrorLevel > 0 then error
            revertAll("Could not delete '" fileName "'") // Critical: revert
        log.event("DELETED: '" dFile "'")
    }

// Delete files by deleteFiles instructions from features
for 0, feat in features
    for 0, dFile in feat._deleteFiles { // Iterate over delete-file instructions
        SplitPath, dFile, fileName
        prgBar.step(dFile) // Show file name (progress bar)
        FileSetAttrib, -R, %dFile%
        FileDelete, %dFile%
        if ErrorLevel // If ErrorLevel > 0 then error
            revertAll("Could not delete '" fileName "'") // Critical: revert
        log.event("DELETED: '" dFile "'")
    }



// #############
//  Copy files
// #############

// Advance progress bar
prgBar.section("Copy new files")

succCopied := {} // Successful operations stored for possible reverting
for 0, feat in features
    for to, from in feat._copyFiles { // Iterate over copy-file instructions
        SplitPath, from, fromFile
        SplitPath, to, , toDir
        prgBar.step(fromFile) // Display file name
        FileCreateDir, %toDir% // Will create all successive directories needed
        FileCopy, %from%, %to%, 1 // Force (overwrite) file copy (checked above)
        if ErrorLevel // Critical error: abort and revert
            revertAll("Could not copy '" fromFile "' to '" toDir "'")
        succCopied.Insert(from, to)
        log.event("COPIED: '" from "' to '" to "'")
    }



// ##############
//  Alter files
// ##############

// Advance progress bar
prgBar.section("Write changes to files")

for desc, file in files {
    prgBar.step(file.name) // Display file name
    if !file.modifiedBy(validFeats) // Redundant, but prevents logging
        continue
    succ := file.writeToFile(validFeats) // Critical error: abort and revert
    if !succ
        revertAll("Could not write '" file.name "'")
    else if (succ == 3)
        log.event("NO CHANGES: '" file.getFullPath() "'")
    else if (succ == 2)
        log.event("CREATED: '" file.getFullPath() "'")
    else
        log.event("MODIFIED: '" file.getFullPath() "'")
}



// #######################
//  Confirmation dialog
// #######################

log.event("-------------- Extraction successful --------------`n") // Newline
prgBar := "" // Destroy progress bar (destruction also removes the GUI)
MsgBox, 64, Installation successful, Installation successful!
exitClean(0) // Error code
