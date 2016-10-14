;32 mpress
/**
 * Felper.ahk - Helper tool for regular expressions
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

// Haystack
lorem := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam congue mauris tempus ligula vestibulum, eu "
    . "efficitur erat ultricies.`nVivamus {egestas sapien turpis, (eget maximus magna vehicula a.`nVestibulum et augue "
    . "feugiat, dictum est at, ullamcorper mauris. Ut convallis ornare turpis a aliquet.`nSed in ex ut nunc rhoncus "
    . "ornare. Sed ac turpis sed nunc} faucibus tempor a in velit).`nProin molestie turpis non pharetra lacinia.`n"
    . "Maecenas quis erat accumsan lacus dignissim iaculis ac eget elit. Sed tincidunt orci nec augue blandit "
    . "elementum.`nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."

// RegEx (?<=turpis\\s)(\\w*)\\s+(\\w*)
dRegEx =
(
{
    "regex": {
        "needle": "(\\{).*(\\()",
        "flags": {
            "caseSensitive": false,
            "dotInclNL": false,
            "multiLine": false,
            "ungreedy": false,
            "occurrence": -1
        }
    },
    "matchBracket": {
        "parenthesis": "$2",
        "curlyBracket": "$1"
    }
}
)

// Main GUI
Loop, 2 // Enable drag&drop with admin rights
    DllCall("ChangeWindowMessageFilter", uint, (i:=!i ? 0x49 : 0x233), uint, 1)
Gui, main:-DPIScale +HwndmainHWND +Resize +MinSize +E0x10 // E0x10 = allow drag&drop
Gui, main:Margin, 15, 5
Gui, main:Font, s8, Tahoma
Gui, main:Add, Text, y15, Search text
Gui, main:Add, Edit, w550 h200 -Wrap +HScroll gmainUpdateMatch veditHaystack, %lorem%
Gui, main:Add, Text, y+15 vtJSON, JSON Anchor
Gui, main:Font, s9, Lucida Console
Gui, main:Add, Edit, w550 h250 -Wrap +HScroll +WantTab t13 gmainParseJSON veditJSON, %dRegEx%
Gui, main:Font, s8, Tahoma
Gui, main:Add, Text, y+15 vtmatches, Matches
Gui, main:Add, DropDownList, yp-4 x+10 w180 gmainSelectMatch vmatchList AltSubmit, No matches||
Gui, main:Font, s8, Tahoma
Gui, main:Add, Edit, w550 h100 xm +ReadOnly -Wrap +HScroll veditMatch
Gui, main:Show, xcenter ycenter, Felper
GuiControl, main:Focus, editJSON // Do not focus edit box (will select all)
mainParseJSON() // Match from beginning
return
