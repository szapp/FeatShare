/**
 * Progressbar class - Tailored to FeatShare.ahk
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

#CommentFlag, //
#Include, funcStrRegEx.ahk


/**
 * Progressbar class maintaining a progressbar
 */
class Progressbar {

    static globalId = [] // Only up to 10 instances allowed

    /**
     * Create new progress bar
     *
     * sections        Number of total sections
     * title           Text for title (larger font)
     * task            Text for main task (above)
     * subtask         Text for subtask (below)
     *
     * returns         False if maximum number of progress bars is reached
     */
    __New(sections, title:="", task:="", subtask:="") {
        // Only up to 10 instances allowed (limited by AHK)
        if (ObjCount(this.globalId) >= 10)
            return False
        // Find next available id
        this.id := 1
        while this.globalId.HasKey(this.id)
            this.id++
        this.globalId[this.id] := this.id // Assign new id
        this.max := sections*30 // Each section has 30 steps
        this.filled := 0 // Start of the bar
        this.title := title
        // Don't set the instance variables yet. Will be done in buildSubtext()
        task := (task == "") ? A_Space : task // Must be non-empty string
        subtask := (subtask == "") ? A_Space : this.truncate(subtask)
        // Create progressbar
        optionstr := this.id ":B2 H85 W350 C01 R0-" this.max " FS8 FM11 WM600 ZH15 Hide"
        // Least ugly windows monospaced default font
        Progress, %optionstr%, % this.buildSubtext(task, subtask), %title%, % "progressbar#" this.id, Lucida Console
    }

    /**
     * Destructor
     *
     * Called by prgbar := "". This frees the object and calls this destructor.
     */
    __Delete() {
        // Delete GUI
        Progress, % this.id ":Off"
        // Free variables
        this.id := this.max := this.filled := ""
    }

    /**
     * Sets the bar to fill position
     *
     * fill            Position to set the bar to. If empty string, set to max
     * task            Updates the task string, 0 leaves it as it is
     * subtask         Updatest the subtask string, 0 leaves it as it is
     */
    set(fill:="", task=0, subtask=0) {
        this.filled := (fill > this.max || fill == "") ? this.max : fill
        // Check what actually needs to be changed
        if (newSubtext := this.buildSubtext(task, subtask))
            Progress, % this.id ":" this.filled, % newSubtext
        else // Only change position
            Progress, % this.id ":" this.filled
    }

    /**
     * Advance the bar with additional options. Wrapper for this.set()
     *
     * ticks           Advances the progress bar by ticks
     * task            Updates the task string, 0 leaves it as it is
     * subtask         Updatest the subtask string, 0 leaves it as it is
     */
    advance(ticks=1, task=0, subtask=0) {
        // Advance progress bar
        ticks := (ticks+this.filled > this.max) ? this.max : (ticks+this.filled)
        this.set(ticks, task, subtask)
    }

    /**
     * Adances the bar by a small step
     *
     * subtask         Updatest the subtask string, 0 leaves it as it is
     */
    step(subtask=0) {
        // Only advance if bar stays in the current section
        if (floor(this.filled/30) == floor((this.filled+1)/30))
            this.advance(1, 0, subtask)
    }

    /**
     * Sets the bar to the next section
     *
     * task            Updates the task string, 0 leaves it as it is
     * subtask         Updatest the subtask string (will reset if not set)
     */
    section(task=0, subtask:="") {
        // Retrieve position of next section
        section := (floor(this.filled/30)+1)*30
        this.set(section, task, subtask)
    }

    /**
     * Builds the GUI subtext from task and subtask
     *
     * task            Task string, 0 leaves it as it is
     * subtask         Subtask string, 0 leaves it as it is
     *
     * returns         Updated subtext if it changed, False otherwise
     */
    buildSubtext(task=0, subtask=0) {
        subtextCurr := this.task "...`n" this.subtask
        if (task != 0) { // 0 keeps it unaltered
            if (task == "")
                task := A_Space // Must be an non-empty string
            this.task := task
        }
        if (subtask != 0) { // 0 keeps it unaltered
            if (subtask == "")
                subtask := A_Space // Must be an non-empty string
            this.subtask := this.truncate(subtask)
        }
        if (subtextCurr != this.task "...`n" this.subtask)
            return this.task "...`n" this.subtask
        else
            return False
    }

    /**
     * Truncates the length of subtask string to fit into the GUI (Two lines)
     *
     * string          String to truncate
     */
    truncate(string) {
        string := SubStr(string, 1, 47) " " SubStr(string, 48) // Wrap lines. File paths usually do not have spaces
        return SubStr(string, 1, 92) ((StrLen(string) > 92) ? "..." : "")
    }

    /**
     * Hides the GUI
     */
    hide() {
        // Progress, % this.id ":Hide" // This command resets the layout!
        WinHide, % "progressbar#" this.id
    }

    /**
     * Shows the GUI
     */
    show() {
        Progress, % this.id ":Show"
    }
}
