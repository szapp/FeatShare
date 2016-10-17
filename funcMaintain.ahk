/**
 * Maintainance and GUI functions for FeatShare.ahk
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
#Include, Logger.ahk
#Include, Filecontent.ahk


/**
 * Collective exit routine (analogous to OnExit). Possible cleanup can be done
 * here.
 *
 * extErr              Exit code
 */
exitClean(extErr=0) {
    global prgBar
    if tempDir // TempDir is created when building a setup
        FileRemoveDir, %tempDir%, 1
    log := Logger.getInstance()
    log.flush() // Write log to file (in case of non-instant flush)
    prgBar := "" // Remove progress bar, if not already gone
    ExitApp, extErr // Return error code if set
}

/**
 * Exit routine before anything was changed.
 *
 * cause               Error message
 */
exitError(cause) {
    global prgBar
    log := Logger.getInstance()
    log.critical(cause)
    log.event("No changes made.")
    prgBar := "" // Remove progress bar (destruction removes the GUI)
    MsgBox, 16, Installation failed, Error: %cause%`n`nNo changes made.
    exitClean(2) // Error code
}

/**
 * Revert all changes made upon error
 *
 * cause               Error message
 */
revertAll(cause) {
    global backupDir, destDir, succCopied, prgBar
    log := Logger.getInstance()
    log.critical(cause)
    log.event("Reverting all changes.")
    prgBar := "" // Remove progress bar (destruction removes the GUI)
    MsgBox, 16, Installation failed, Error: %cause%`n`nReverting all changes.

    // Delete already copied files
    for 0, file in succCopied {
        FileSetAttrib, -R, %file%
        FileDelete, %file%
    }

    // Replace backup files: Restores ALL backed up files (and deletes backups)
    Loop, %backupDir%*, 1, 0
    { // OTB not possible here

        // Not entire backupDir
        if (A_LoopFileFullPath == "log.path") // Keep log
        || (A_LoopFileFullPath == "files.diff") // Keep diff
            continue
        // Two cases: Directory or file
        if InStr(FileExist(A_LoopFileFullPath), "D") { // Recursive
            FileCopyDir, %A_LoopFileFullPath%, %destDir%%A_LoopFileName%, 1
            FileRemoveDir, %A_LoopFileFullPath%, 1
        } else {
            FileCopy, %A_LoopFileFullPath%, %destDir%,1
            FileDelete, %A_LoopFileFullPath%
        }
    }
    exitClean(1) // Error code
}

/**
 * Browse directory dialog of setup GUI
 */
setupButtonBrowse() {
    global config
    tmpPath := SubStr(A_GuiControl, 1, -3)
    GuiControlGet, %tmpPath% // Retrieve string from GUI control
    tmpPath := InStr(FileExist(%tmpPath%), "D") ? %tmpPath% : config.defaultPath
    FileSelectFolder, tmpPath, *%tmpPath% , 0, Please select directory
    If tmpPath // If valid, update GUI control
        GuiControl, setup:, % SubStr(A_GuiControl, 1, -3), %tmpPath%
}

/**
 * Listener for the feature listview on setup GUI. Manipulates the checkboxes
 * on click an updates the info text.
 */
setupFeatureList() {
    global guiDescr, allFeats
    if InStr(ErrorLevel, "S", True) { // Selection made: check/uncheck item
        Gui, +LastFound // Select GUI
        // LVM_GETITEMSTATE = 4140, LVIS_STATEIMAGEMASK = 0xF000
        SendMessage, 4140, A_EventInfo-1, 0xF000, SysListView321
        if (ErrorLevel >> 12) - 1 // True if checked or False otherwise
            LV_Modify(A_EventInfo, "-Check")
        else
            LV_Modify(A_EventInfo, "Check")
    }
    if (A_GuiEvent == "Normal") // Normal left click: update info text
        // If there is no GUI description show file name
        GuiControl, setup:, info, % (allFeats[A_EventInfo][guiDescr]
            ? allFeats[A_EventInfo][guiDescr]
            : RegExReplace(allFeats[A_EventInfo]._filename, "\.[^.]+$"))
}

/**
 * Choose match from dropdown menu
 */
mainSetMatch(id) {
    global match
    if !match {
        GuiControl, main:, matchList, |No matches||
        return
    }
    if (ObjCount(match) < id)
        id = 0
    GuiControl, main:Choose, matchList, % id+1
    return id
}

/**
 * Set match in edit field from dropdown menu selection
 */
mainSelectMatch() {
    global match, matchCont
    GuiControlGet, matchId, main:, matchList
    GuiControl, main:, editMatch, % "Pos: " match[matchCont[matchId-1]]["pos"]
        . "  Len: " match[matchCont[matchId-1]]["len"] "`n"
        . match[matchCont[matchId-1]]["val"]
}

/**
 * Update the match edit field with new regex match on change
 */
mainUpdateMatch() {
    global match, matchCont, anchor, mainHWND
    if !mainParseAnchor()
        return
    // GuiControlGet, editHaystack, Edit, editHaystack // LF (\n), doesn't match
    ControlGetText, editHaystack, Edit1, ahk_id %mainHWND% // CR+LF (\r\n)
    GuiControlGet, matchId, main:, matchList
    matchId -= 1

    // RegEx flags
    flgs := ""
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

    RegExMatchOcc(editHaystack, flgs "O)" anchor.regex.needle, match, 1, anchor.regex.flags.occurrence) // "`a"
    err := ErrorLevel
    if !match || err {
        GuiControl, main:, matchList, |No matches||
        GuiControl, main:, editMatch, % err ? "RegEx Error:`n" err : ""
        return
    }

    // Get matching brackets positions
    patterns := {}
    for var, startIdx in anchor.matchBracket {
        // Find respective closing bracket or parenthesis
        if !(obj := matchClosed(editHaystack, patternPos(startIdx))) {
            GuiControl, main:, matchList, |No matches||
            GuiControl, main:, editMatch, Matched bracket not found
            return
        }
        patterns[var] := obj
    }
    // Combine regex subpatterns and matchBracket subpatterns
    Loop, % match.Count()+1
        patterns[A_Index-1] := {"val": match[A_Index-1], "pos": match.Pos(A_Index-1), "len": match.Len(A_Index-1)}
    match := patterns

    matches := "|", i = 0, matchCont := {}
    for key, val in match {
        matches .= "$" key "|"
        matchCont[i++] := key // Additional array for named subpatterns
    }
    GuiControl, main:, matchList, % matches
    matchId := mainSetMatch(matchId) // Also corrects matchId
    GuiControl, main:, editMatch, % "Pos: " match[matchCont[matchId]]["pos"]
        . "  Len: " match[matchCont[matchId]]["len"] "`n" match[matchCont[matchId]]["val"]
}

/**
 * Parse anchor to retrieve regex
 */
mainParseAnchor(err:="") {
    global anchor
    if !anchor {
        GuiControl, main:, matchList, |No matches||
        GuiControl, main:, editMatch, % err ? err : ""
        return False
    }
    // Check if anchor has regex field
    if !anchor.HasKey("regex") || !anchor.regex.HasKey("needle") {
        // If not check if the entire config.json was dumped into the GUI edit
        if (anchor.HasKey("anchors") && anchor.anchors.HasKey(1)
            && anchor.anchors[1].HasKey("regex")
            && anchor.anchors[1].regex.HasKey("needle")) {
            anchor := anchor.anchors[1]
            return True
        } // else
        GuiControl, main:, matchList, |No matches||
        GuiControl, main:, editMatch, Anchor Error:`nregex.needle not found.
        return False
    }
    return True
}

/**
 * Parse JSON to anchor
 */
mainParseJSON() {
    global anchor
    GuiControlGet, editJSON, main:
    try anchor := JSON.Load(editJSON)
    catch e { // JSON offers very nice exception messages
        err := "JSON Error:`n" e.message
        anchor := ""
    }
    if !mainParseAnchor(err)
        return
    mainUpdateMatch()
}

/**
 * Enables drag&dropping files into the edit fields
 */
mainGuiDropFiles() {
    if A_GuiControl not in editHaystack,editJSON
        return
    filename := RegExReplace(A_GuiEvent, "`n.*")
    if !FileExist(filename)
        return
    contObj := new Filecontent(filename) // This ensures correct encoding
    content := contObj.content, contObj := "" // Free file handle
    GuiControl, main:, %A_GuiControl%, %content%
    if (A_GuiControl == "editHaystack")
        mainUpdateMatch()
    else
        mainParseJSON()
}

/**
 * Stores diffs to file
 */
diffButtonSaveToFile() {
    global files, backupDir, config
    Gui, diff:+OwnDialogs // Dialogs are children of setup GUI
    for desc, file in files
        toString .= file.diff["text"] "`n`n`n`n"
    if !FileExist(backupDir)
        FileCreateDir, %backupDir%
    FileSetAttrib, -R, %backupDir%files.diff
    FileDelete, %backupDir%files.diff
    FileAppend, %toString%, %backupDir%files.diff
    if ErrorLevel
        MsgBox, 48, Writing to file, Error: Could not write to`n'%backupDir%files.diff'
    else
        MsgBox, 64, Writing to file, Successfully written to`n'%backupDir%files.diff'
}

/**
 * Anchor GUI controls in window for resizing
 *
 * Author: Titan
 *
 * c                   Control to anchor
 * a                   How to anchor the control
 * r                   Redraw control
 */
guiAnchor(c, a, r:=False) { // v3.5.1 - Titan
    static d
    GuiControlGet, p, Pos, %c%
    If !A_Gui or ErrorLevel
        Return
    i = x.w.y.h./.7.%A_GuiWidth%.%A_GuiHeight%.`n%A_Gui%:%c%=
    StringSplit, i, i, .
    d .= (n := !InStr(d, i9)) ? i9 :
    Loop, 4
        x := A_Index, j := i%x%, i6 += x = 3
        , k := !RegExMatch(a, j . "([\d.]+)", v) + (v1 ? v1 : 0)
        , e := p%j% - i%i6% * k, d .= n ? e . i5 : ""
        , RegExMatch(d, RegExReplace(i9, "([[\\\^\$\.\|\?\*\+\(\)])", "\$1")
        . "(?:([\d.\-]+)/){" . x . "}", v)
        , l .= InStr(a, j) ? j . v1 + i%i6% * k : ""
    r := r ? "Draw" :
    GuiControl, Move%r%, %c%, %l%
}

/**
 * Add GUI anchors for resizing - thanks to Titan
 */
mainGuiSize() {
    guiAnchor("editHaystack","wh0.5")
    guiAnchor("tJSON","y0.5")
    guiAnchor("editJSON","wy0.5")
    guiAnchor("tmatches","y0.5")
    guiAnchor("matchList","y0.5")
    guiAnchor("editMatch","wh0.5y0.5")
}

/**
 * Add GUI anchors for resizing - thanks to Titan
 */
diffGuiSize() {
    global re
    guiAnchor("tabs","wh")
    for i, 0 in re
        guiAnchor("RICHEDIT50W" i, "wh")
    guiAnchor("diffTdryrun", "y")
    guiAnchor("diffBsave", "y", true)
    guiAnchor("diffBclose", "xy", true)
    guiAnchor("diffBaccept", "xy", true)
    guiAnchor("diffBcancel", "xy", true)
}

/**
 * Add GUI anchors for resizing - thanks to Titan
 */
errorsGuiSize() {
    global re
    guiAnchor("errorsEdisabled","wh0.3")
    guiAnchor("errorsToccured", "y0.3")
    guiAnchor("errorsEerrs", "y0.3wh0.7")
    guiAnchor("Con", "xy", true)
    guiAnchor("Cancel", "xy", true)
}

/**
 * Clear file list (except of anchor files)
 */
buildButtonClear() {
    global anchorFiles
    GuiControl, build:, inclFiles, %anchorFiles%
}

/**
 * Enables drag&dropping files into the edit fields
 */
buildGuiDropFiles() {
    global inclFilesFullPath
    if (A_GuiControl != "inclFiles")
        return
    GuiControlGet, inclFiles, build:
    Loop, Parse, A_GuiEvent, `n
    { // OTB not possible here
        SplitPath, A_LoopField, filename, path
        if InStr(FileExist(A_LoopField), "D") {
            Loop, %A_LoopField%\*, 0, 1
            { // OTB not possible here
                filename := StrReplace(A_LoopFileFullPath, Trim(path, "\") "\")
                if !RegExMatch(inclFiles, "`aim)^" filename "$")
                    inclFiles .= filename "`n"
                inclFilesFullPath.Insert(filename, A_LoopFileFullPath)
            }
        } else {
            if !RegExMatch(inclFiles, "`aim)^" filename "$")
                inclFiles .= filename "`n"
            inclFilesFullPath.Insert(filename, A_LoopField)
        }
    }
    GuiControl, build:, inclFiles, %inclFiles%
}

/**
 * Browse for file location for setup to be created
 */
buildButtonBrowseStp() {
    GuiControlGet, setupName, build:
    SplitPath, setupName, , tmpPath, , name
    tmpPath := FileExist(tmpPath) ? tmpPath "\" name ".exe" : A_WorkingDir
    FileSelectFile, tmpPath, 18S, %tmpPath%, Please specify where to create the setup , Executable (*.exe)
    if tmpPath {
        SplitPath, tmpPath, , tmpPath, , name
        GuiControl, build:, setupName, %tmpPath%\%name%.exe
    }
}

/**
 * Browse for config file and add its anchor files to file list
 */
buildButtonBrowseCfg() {
    global inclFiles, anchorFiles, inclFilesFullPath
    Gui, build:+OwnDialogs // Subsequent windows are children of build GUI
    GuiControlGet, configPath, build:
    GuiControlGet, inclFiles, build:
    SplitPath, configPath, , tmpPath
    tmpPath := Trim(FileExist(tmpPath) ? StrReplace(tmpPath, "/", "\") : A_WorkingDir, "\")
    tmpPath .= tmpPath ? "\" : ""
    FileSelectFile, tmpPath, 3, %tmpPath%, Please select the config file, Config file (*.json)
    if !tmpPath
        return
    configPath := tmpPath
    SplitPath, configPath, configFile, tmpPath
    tmpPath .= tmpPath ? "\" : ""
    // Load config file
    contObj := new Filecontent(configPath) // This ensures(?) correct encoding
    content := contObj.content, contObj := "" // Free file handle
    if !content {
        MsgBox, 48, Config invalid, Error: Could not load '%configPath%'.
        return
    }
    try config := JSON.Load(content)
    catch e { // JSON offers very nice exception messages
        MsgBox, 48, Config invalid, % "Error: Parsing '" configPath "':`n`n" e.message
        return
    }
    if !config { // If config is empty for whatever reason
        MsgBox, 48, Config invalid, Error: Could not read '%configPath%'.
        return
    }
    if !IsObject(config.anchors) { // If config does not contain anchors
        MsgBox, 48, Config invalid, Error: Could not find any anchors in '%configPath%'.
        return
    }
    for 0, val in config.anchors { // Fake loop to get the first item of array
        if !IsObject(val) // Anchors are not in the config file but in separate files
            anchFiles := True
        else
            anchFiles := False
        break
    }
    // If anchors are outsourced into files and not part of the config
    anchorFilesNew := configFile "`n" // Will serve as a temporary anchor list
    inclFilesFullPath.Insert(configFile, configPath)
    if anchFiles {
        // In this case is a list of file patterns of anchor files
        for path, pattern in config.anchors {
            path := Trim(StrReplace(path, "/", "\"), "\")
            path .= path ? "\" : ""
            Loop, %tmpPath%%path%*, 0, 0
            { // OTB not possible here
                // Match filePatterns against regex
                if !RegExMatch(A_LoopFileName, "i)" pattern) || !pattern || (A_LoopFileLongPath == configPath)
                    continue
                anchorFilesNew .= path A_LoopFileName "`n"
                inclFilesFullPath.Insert(path A_LoopFileName, A_LoopFileLongPath)
            }
        }
        // if !anchorFilesNew { // Do not show error here. The user knows what they are doing.
        //     MsgBox, 48, Config invalid, Error: No valid anchors found in '%configPath%'.
        //     return
        // }
    }
    if anchorFiles
        inclFiles := StrReplace(inclFiles, anchorFiles, anchorFilesNew)
    else
        inclFiles := anchorFilesNew inclFiles
    anchorFiles := anchorFilesNew
    GuiControl, build:, inclFiles, %inclFiles%
    GuiControl, build:, configPath, %configPath%
}

/**
 * Checks the json-config array. If important values are missing, they are either replaced by default values or an
 * exception is thrown.
 *
 * config              The parsed config array
 *
 * throws              Exception, if invalid
 */
validateConfig(ByRef config) {
    // Get program files directory for default install directory
    EnvGet, ProgFiles, ProgramFiles(x86)
    if !ProgFiles
        EnvGet, ProgFiles, ProgramFiles

    // Validate log first, to initialize its values
    log := Logger.getInstance()
    if !IsObject(config.log)
        config.log := {}
    // Field: log.showDebug, default: False
    if !config.log.HasKey("showDebug")
        config.log.showDebug := False
    log.showDebug := config.log.showDebug // Apply right away
    // Field: log.showWarn, default: False
    if !config.log.HasKey("showWarn")
        config.log.showWarn := False
    log.showWarn := config.log.showWarn // Apply right away
    // Field: log.instantFlush, default: True
    if !config.log.HasKey("instantFlush")
        config.log.instantFlush := True
    // Field: log.timeformat, default: "yyyy-MM-dd HH:mm:ss"
    if !config.log.HasKey("timeformat") {
        config.log.timeformat := "yyyy-MM-dd HH:mm:ss"
        log.warn("Log timeformat not set (setting to default: 'yyyy-MM-dd HH:mm:ss')") // Don't log before this line
    }
    log.timeformat := config.log.timeformat // Apply right away

    // Field: title, default: "Setup"
    if !config.HasKey("title") || (config.title == "") {
        log.warn("Title not set (setting to default: 'Setup')")
        config.title := "Setup"
    }
    // Field: globalHeader, default: ""
    if !config.HasKey("globalHeader")
        config.globalHeader := ""
    // Field: installInstruction, default: "Choose the directory to integrate into"
    if !config.HasKey("installInstruction") || (config.installInstruction == "") {
        log.warn("Install instruction not set (setting to default: 'Choose the directory to integrate into')")
        config.installInstruction := "Choose the directory to integrate into"
    }
    // Field: defaultPath, default: "C:\Program Files (x86)\"
    if !config.HasKey("defaultPath") || (config.defaultPath == "") {
        log.warn("Default path not set (setting to default: '" StrReplace(ProgFiles, "/", "\") "')")
        config.defaultPath := StrReplace(ProgFiles, "/", "\")
    }

    // Field: dryRun, default: False
    if !config.HasKey("dryRun")
        config.dryRun := False
    // Field: diffGUI, default: False
    if !config.HasKey("diffGUI")
        config.diffGUI := False
    if config.diffGUI || config.dryRun {
        // Field: diffGUIstyle, default: "FeatShareDefault"
        if !config.HasKey("diffGUIstyle") || (config.diffGUIstyle == "") {
            log.warn("Diff GUI style not set (setting to default)")
            config.diffGUIstyle := "FeatShareDefault"
        }
        if !IsObject(config.diffGUIstyles)
            config.diffGUIstyles := {}
        if  !config.diffGUIstyles.HasKey(config.diffGUIstyle) {
            log.warn("Diff GUI style not found (setting to default)")
            config.diffGUIstyle := "FeatShareDefault"
        }
        // Field: diffGUIstyles.FeatShareDefault, default: {<colorset>}
        if !config.diffGUIstyles.HasKey(config.diffGUIstyle)
        || !RegExMatch(config.diffGUIstyles[config.diffGUIstyle].background, "i)^[0-9a-f]{6}$")
        || !RegExMatch(config.diffGUIstyles[config.diffGUIstyle].default, "i)^[0-9a-f]{6}$")
        || !RegExMatch(config.diffGUIstyles[config.diffGUIstyle].info, "i)^[0-9a-f]{6}$")
        || !RegExMatch(config.diffGUIstyles[config.diffGUIstyle].remove, "i)^[0-9a-f]{6}$")
        || !RegExMatch(config.diffGUIstyles[config.diffGUIstyle].add, "i)^[0-9a-f]{6}$") {
            log.warn("Diff GUI style colors invalid (setting to default)")
            config.diffGUIstyle := "FeatShareDefault"
            config.diffGUIstyles["FeatShareDefault"] := {"background": "F0F0F0", "default": "4F4D45", "info": "A2A29D"
                , "remove": "B11000", "add": "50A900"}
        }
    }

    // Field: features
    if !IsObject(config.features) {
        log.warn("No feature settings set (setting to default)")
        config.features := {}
    }
    // Field: features.path, default: ""
    if  !config.features.HasKey("path")
        config.features.path := ""
    // Field: features.filePattern, default: ".*"
    if  !config.features.HasKey("filePattern")
        config.features.filePattern := ".*"
    // Field: features.anchorPattern
    if  !IsObject(config.features.anchorPattern)
        config.features.anchorPattern := {}
    // Field: features.anchorPattern.regex, default: <string>
    if  !config.features.anchorPattern.HasKey("regex")
        config.features.anchorPattern.regex := "### ([\w\*\(\)\.\:_]+) ###\R(.*)\R### [\w\*\(\)\.\:_]+ ###"
    // Field: features.anchorPattern.flags
    if  !IsObject(config.features.anchorPattern.flags)
        config.features.anchorPattern.flags := {}
    // Field: features.anchorPattern.flags.caseSensitive, default: False
    if  !config.features.anchorPattern.flags.HasKey("caseSensitive")
        config.features.anchorPattern.flags.caseSensitive := False
    // Field: features.anchorPattern.flags.dotInclNL, default: True
    if  !config.features.anchorPattern.flags.HasKey("dotInclNL")
        config.features.anchorPattern.flags.dotInclNL := True
    // Field: features.anchorPattern.flags.multiLine, default: False
    if  !config.features.anchorPattern.flags.HasKey("multiLine")
        config.features.anchorPattern.flags.multiLine := False
    // Field: features.anchorPattern.flags.ungreedy, default: True
    if  !config.features.anchorPattern.flags.HasKey("ungreedy")
        config.features.anchorPattern.flags.ungreedy := True
    // Field: features.anchorPattern.key, default: "$1"
    if  !config.features.anchorPattern.HasKey("key")
        config.features.anchorPattern.key := "$1"
    // Field: features.anchorPattern.value, default: "$2"
    if  !config.features.anchorPattern.HasKey("value")
        config.features.anchorPattern.value := "$2"
    // Field: features.infoTextAnchor, default: "infoText"
    if  !config.features.HasKey("infoTextAnchor")
        config.features.infoTextAnchor := "infoText"

    // Field: features.fileCopyAnchor
    if  !IsObject(config.features.fileCopyAnchor)
        config.features.fileCopyAnchor := {}
    // Field: features.fileCopyAnchor.name, default: "copyFiles"
    if  !config.features.fileCopyAnchor.HasKey("name")
        config.features.fileCopyAnchor.name := "copyFiles"
    // Field: features.fileCopyAnchor.regex, default: "^([^:*?<>|"]+)\|([^:*?<>|"]+)$"
    if  !config.features.fileCopyAnchor.HasKey("regex")
        config.features.fileCopyAnchor.regex := "^([^:*?<>|""]+)\|([^:*?<>|""]+)$" // Double-escape quotes
    // Field: features.fileCopyAnchor.flags
    if  !IsObject(config.features.fileCopyAnchor.flags)
        config.features.fileCopyAnchor.flags := {}
    // Field: features.fileCopyAnchor.flags.caseSensitive, default: False
    if  !config.features.fileCopyAnchor.flags.HasKey("caseSensitive")
        config.features.fileCopyAnchor.flags.caseSensitive := False
    // Field: features.fileCopyAnchor.flags.dotInclNL, default: False
    if  !config.features.fileCopyAnchor.flags.HasKey("dotInclNL")
        config.features.fileCopyAnchor.flags.dotInclNL := False
    // Field: features.fileCopyAnchor.flags.multiLine, default: True
    if  !config.features.fileCopyAnchor.flags.HasKey("multiLine")
        config.features.fileCopyAnchor.flags.multiLine := True
    // Field: features.fileCopyAnchor.flags.ungreedy, default: False
    if  !config.features.fileCopyAnchor.flags.HasKey("ungreedy")
        config.features.fileCopyAnchor.flags.ungreedy := False
    // Field: features.fileCopyAnchor.fromPath, default: "$1"
    if  !config.features.fileCopyAnchor.HasKey("fromPath")
        config.features.fileCopyAnchor.fromPath := "$1"
    // Field: features.fileCopyAnchor.toPath, default: "$2"
    if  !config.features.fileCopyAnchor.HasKey("toPath")
        config.features.fileCopyAnchor.toPath := "$2"

    // Field: features.fileDeleteAnchor
    if  !IsObject(config.features.fileDeleteAnchor)
        config.features.fileDeleteAnchor := {}
    // Field: features.fileDeleteAnchor.name, default: "deleteFiles"
    if  !config.features.fileDeleteAnchor.HasKey("name")
        config.features.fileDeleteAnchor.name := "deleteFiles"
    // Field: features.fileDeleteAnchor.regex, default: "^([^:*?<>|"]+)$"
    if  !config.features.fileDeleteAnchor.HasKey("regex")
        config.features.fileDeleteAnchor.regex := "^([^:*?<>|""]+)$" // Double-escape quotes
    // Field: features.fileDeleteAnchor.flags
    if  !IsObject(config.features.fileDeleteAnchor.flags)
        config.features.fileDeleteAnchor.flags := {}
    // Field: features.fileDeleteAnchor.flags.caseSensitive, default: False
    if  !config.features.fileDeleteAnchor.flags.HasKey("caseSensitive")
        config.features.fileDeleteAnchor.flags.caseSensitive := False
    // Field: features.fileDeleteAnchor.flags.dotInclNL, default: False
    if  !config.features.fileDeleteAnchor.flags.HasKey("dotInclNL")
        config.features.fileDeleteAnchor.flags.dotInclNL := False
    // Field: features.fileDeleteAnchor.flags.multiLine, default: True
    if  !config.features.fileDeleteAnchor.flags.HasKey("multiLine")
        config.features.fileDeleteAnchor.flags.multiLine := True
    // Field: features.fileDeleteAnchor.flags.ungreedy, default: False
    if  !config.features.fileDeleteAnchor.flags.HasKey("ungreedy")
        config.features.fileDeleteAnchor.flags.ungreedy := False
    // Field: features.fileDeleteAnchor.filePath, default: "$1"
    if  !config.features.fileDeleteAnchor.HasKey("filePath")
        config.features.fileDeleteAnchor.filePath := "$1"

    // Field: anchors, default: (isObject -> Exception)
    if !IsObject(config.anchors)
        throw Exception("Could not find any anchors.")

    // Config calidated
    return
}

/**
 * On GUI close, perform clean exit
 */
closeGUI(GUIinst) {
    Gui, %GUIinst%:Destroy
    exitClean()
}
setupButtonCancelSetup() {
    closeGUI(A_Gui)
}
setupGuiClose() {
    closeGUI(A_Gui)
}
setupGuiEscape() {
    closeGUI(A_Gui)
}
errorsButtonCancelSetup() {
    closeGUI(A_Gui)
}
errorsGuiClose() {
    closeGUI(A_Gui)
}
errorsGuiEscape() {
    closeGUI(A_Gui)
}
mainGuiEscape() {
    closeGUI(A_Gui)
}
mainGuiClose() {
    closeGUI(A_Gui)
}
diffGuiClose() {
    closeGUI(A_Gui)
}
diffGuiEscape() {
    closeGUI(A_Gui)
}
diffButtonClose() {
    closeGUI(A_Gui)
}
diffButtonCancel() {
    closeGUI(A_Gui)
}
buildGuiClose() {
    closeGUI(A_Gui)
}
buildGuiEscape() {
    closeGUI(A_Gui)
}
buildButtonCancel() {
    closeGUI(A_Gui)
}
