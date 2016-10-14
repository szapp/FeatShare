;32 mpress
/**
 * BuildSetup.ahk - This is a tool to wrap all necessary files into one setup.
 *
 * FeatShare v0.1-beta - Text integration tool
 * Copyright (C) 2016  szapp <github.com/szapp>
 *
 * This file is part of FeatShare.
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
 * AutoHotkey-JSON (cocobelgica), License: WTFPL <http://wtfpl.net>
 * Class_RichEdit (just me), License: Unlicense <http://unlicense.org>
 *
 *
 * Info: Comments are set to C++ style. Escape character is ` e.g.: `n
 */

#SingleInstance, ignore
#NoTrayIcon
#NoEnv

#Include, lib\AutoHotkey-JSON\JSON.ahk
#CommentFlag, //
// External lib JSON.ahk relies on default comment flag, from here on: C++ style comments
#Include, funcStrRegEx.ahk
#Include, funcMaintain.ahk
#Include, Filecontent.ahk
#Include, Progressbar.ahk



// Build setup
inclFilesFullPath := {} // Empty associative file list
Loop, 2 // Enable drag&drop with admin rights
    DllCall("ChangeWindowMessageFilter", uint, (i:=!i ? 0x49 : 0x233), uint, 1)
Gui, build:-DPIScale +HwndbuildHWND +E0x10
Gui, build:Margin, 15, 5
Gui, build:Font, s8 Tahoma
Gui, build:Add, GroupBox, xm ym+3 w385, Setup file to create
Gui, build:Add, Edit, yp+22 xp+10 w270 vsetupName
Gui, build:Add, Button, yp-1 x+5 w92 vsetupNameBtn gbuildButtonBrowseStp -wrap, Brow&se...
Gui, build:Add, GroupBox, xm w385, Path to config file
Gui, build:Add, Edit, yp+22 xp+10 w270 vconfigPath
Gui, build:Add, Button, yp-1 x+5 w92 vconfigPathBtn gbuildButtonBrowseCfg -wrap, Br&owse...
Gui, build:Add, GroupBox, xm w385 h200, Drag && drop additional files to pack (only files that will be copied)
Gui, build:Add, Edit, yp+22 xp+10 w365 h145 vinclFiles +ReadOnly -wrap +HScroll
Gui, build:Add, Button, y+4 xm+10 w92 h22 -wrap, Clea&r
Gui, build:Add, Button, xm+188 y+15 w102 Default -wrap, &Build Setup
Gui, build:Add, Button, x+4 w92 -wrap, &Cancel
Gui, build:Show, w416 xcenter ycenter, FeatShare Build Setup
return // Wait for GUI events (button press)

/**
 * I chose this not to be a function, to have it in this file
 */
buildButtonBuildSetup:
Gui, build:+OwnDialogs // Subsequent windows are children of build GUI
Gui, build:Submit, NoHide // Keep GUI until verified there is no errors
// Destination paths
SplitPath, configPath, , curDir
curDir := Trim(curDir, "\")
curDir .= curDir ? "\" : ""
SetWorkingDir, %curDir% // Important for the file operations
SplitPath, setupName, , setupPath, , setupNameIN
setupName := ""
Loop, Parse, setupNameIN, , \/:*?<>|`"
    setupName .= A_LoopField // Valid file name
setupName := (setupName ? setupName : "Setup") ".exe"
setupPath .= (setupPath ? "\" : "") setupName
// Files to pack
packFiles := []
inclFiles := Trim(inclFiles, "`n")
Loop, Parse, inclFiles, `n
{
    // Files must exist
    if !FileExist(inclFilesFullPath[A_LoopField]) {
        MsgBox, 48, File not found, % "Could not find file:`n`n'" A_LoopField "'."
        return
    }
    packFiles.Insert(A_LoopField, inclFilesFullPath[A_LoopField])
}
if !ObjCount(packFiles) {
    MsgBox, 48, No files specified, Please choose files to include.
    return
}

// Once everything is set and valid, create setup file from template
Gui, build:+Disabled
prgBar := new ProgressBar(ObjCount(packFiles)+2, setupName, "Building setup")
prgBar.show()
tempDir := A_Temp "\$FeatShare\" // Must be a subdirectory!
updfile := tempDir "template.exe"
mpress := tempDir "mpress.exe"
FileRemoveDir, %tempDir%, 1
FileCreateDir, %tempDir%
// Get template and mpress from resource
FileInstall, bin\template.exe, %updfile%, 1
FileInstall, mpress\mpress.exe, %mpress%, 1
if !FileExist(updfile) { // Only throw error for template, continue if mpress is missing (only for compression)
    prgBar := ""
    MsgBox, 48, Building Setup failed, Error: Could not unpack template.
    Gui, build:-Disabled
    return
}
// This is the code for the setup
template := "#SingleInstance, ignore`n"
    . "#NoTrayIcon`n"
    . "#NoEnv`n"
    . "destDir := A_Temp ""\$FeatShare""`n" // Temporary files are spawned into %tmp%\$FeatShare\
    . "FileRemoveDir, %destDir%, 1`n"
    . "FileCreateDir, %destDir%`n"
    . "instFiles := []`n"
    . "/*###FILELIST###*/`n" // Create directories of temporary file
    . "for 0, file in instFiles {`n"
    . "    SplitPath, file, , dir`n"
    . "    FileCreateDir, %destDir%\%dir%`n"
    . "}`n"
    . "FileInstall, FeatShare.exe, %destDir%\FeatShare.exe, 1`n"
    . "/*###INSTINSTRUCT###*/`n" // FileInstall instructions for all files to unpack
    . "RunWait, %destDir%\FeatShare.exe, %destDir%, UseErrorLevel`n" // Run FeatShare.exe
    . "err := ErrorLevel`n"
    . "FileRemoveDir, %destDir%, 1`n" // Clean up all temporary files afterwards
    . "ExitApp, %err%"
// Load rescources of template.exe
if !(hUpd := DllCall("BeginUpdateResource", Str, updfile, Int, 0)) {
    DllCall("EndUpdateResource", UInt, hUpd, Int, 0)
    FileRemoveDir, %tempDir%, 1
    prgBar := ""
    MsgBox, 48, Building Setup failed, Error: Could not update file resources of setup.
    Gui, build:-Disabled
    return
}
VarSetCapacity(bin, 64, 0)
// Iteratate though the files to pack
for relPath, filepath in packFiles {
    prgBar.section(0, relPath)
    key := Format("{:U}", relPath)
    VarSetCapacity(bin, 0)
    FileRead, bin, *c %filepath%
    if !(nSize := VarSetCapacity(bin))
    || !DllCall("UpdateResource", UInt, hUpd, UInt, 10, Str, key, Int, 0, UInt, &bin, UInt, nSize) {
        DllCall("EndUpdateResource", UInt, hUpd, Int, 0)
        FileRemoveDir, %tempDir%, 1
        prgBar := ""
        MsgBox, 48, Building Setup failed, Error: Could not pack '%relPath%'.
        Gui, build:-Disabled
        return
    }
    // Add unpack instructions to setup
    fileList .=  "instFiles.Insert(""" relPath """)`n"
    installStr .= "FileInstall, " key ", %destDir%\" relPath ", 1`n"
}
// Finally also add the code to the setup file
template := StrReplace(template, "/*###FILELIST###*/", Trim(fileList, "`n"))
template := StrReplace(template, "/*###INSTINSTRUCT###*/", Trim(installStr, "`n"))
bin := "" // Free bin, because it was used before. Must be empty
VarSetCapacity(bin, StrLen(template), 0), P := &bin
Loop, Parse, template
    NumPut(Asc(A_LoopField), P+0, 0, "Char"), P := P+1
key := Format("{:U}", ">AUTOHOTKEY SCRIPT<")
if !(nSize := VarSetCapacity(bin))
|| !DllCall("UpdateResource", UInt, hUpd, UInt, 10, Str, key, Int, 0, UInt, &bin, UInt, nSize) {
    DllCall("EndUpdateResource", UInt, hUpd, Int, 0)
    FileRemoveDir, %tempDir%, 1
    prgBar := ""
    MsgBox, 48, Building Setup failed, Error: Could not pack the extraction script code.
    Gui, build:-Disabled
    return
}
// Closing resource
DllCall("EndUpdateResource", UInt, hUpd, Int, 0)

prgBar.section("Compressing executable")
// Compress with mpress
if !FileExist(mpress) {
    prgBar.hide()
    MsgBox, 48, Mpress not found, % "Error: Could not compress setup!`n'" mpress "' not found!`n`n"
        . "Skipping compression..."
    prgBar.show()
} else {
    prgBar.step(""), prgBar.step(""), prgBar.step("This might take a few minutes.") // Give the impression of progress
    RunWait, %mpress% %updfile%, %tempDir%, UseErrorLevel Hide
    if ErrorLevel {
        prgBar.hide()
        MsgBox, 48, Mpress not found, Error: Could not compress setup! Compression failed.`n`nSkipping compression...
        prgBar.show()
    }
}
prgBar.section() // Fill bar
// Success: Move the finished setup file to the current directory
FileMove, %updfile%, %setupPath%, 1
if ErrorLevel {
    FileRemoveDir, %tempDir%, 1
    prgBar := ""
    MsgBox, 48, Building Setup failed, Error: Could not move setup file to '%setupPath%'.
    Gui, build:-Disabled
    return
}
FileRemoveDir, %tempDir%, 1
prgBar := ""
MsgBox, 64, Building Setup successful, The setup was created successfullly.`n`nFind it at:`n%setupPath%
exitClean()
