/**
 * Contentblock class
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


/**
 * Class holding a block of content
 *
 * The itmes are numbered (-2 will be added to the end when creating a string):
 *
 * -2   Original (enclosed) content, iff set to end of block (placeAtEnd == 1)
 * -1   Original (enclosed) content, iff set to start of block (placeAtEnd == 0)
 *  0   Header
 *  1   New content
 *  2   New content
 *  3   New content
 * ...   ...
 *
 * The ordering of items will look like this (-2 and -1 are mutually exclusive)
 *
 * Original   Original   No changes
 * content    content     applied
 * at start    at end
 *
 *   -1                   -1/-2
 *    0          0
 *    1          1
 *    2          2
 *   ...        ...
 *              -2
 *
 */
class Contentblock {

    /**
     * Constructor taking positions of the hook and whether to add at placeAtEnd
     *
     * onset           Start position of block (hook)
     * length          Length of the hook (if not zero, it encloses content)
     * content         Complete content string which to hook
     * placeAtEnd      Place the enclosed string at end of hook
     *
     * returns         False if onset or length invalid
     */
    __New(onset, length, content, placeAtEnd) {
        if (onset < 0) || (length < 0)
            return False
        this.onset := onset
        this.length := length
        this.offset := onset+length
        this.block := []
        this.index := 0
        this.placeAtEnd := placeAtEnd
        this.rest := -(placeAtEnd+1) // Position (-2 if end, -1 if start)
        this.nlb4 := 0
        this.nlaf := 0
        this.finalReplace := []
        if (length) // If hook encloses content place it at start/end (rest)
            this.block[this.rest] := SubStr(content, onset, length)
    }

    /**
     * Wrapper method to pass all finalReplaces to regexIncr(). Though non-RegEx
     * solutions are faster performance-wise, they don't support
     * case-insensitive find and replace.
     *
     * haystack        String to modify
     *
     * returns         (Un-)Altered haystack
     */
    finalReplaceAll(haystack) {
        // Iterate over all finalReplace-pairs
        for idx, obj in this.finalReplace {

            // Wrap in brackets (escaped because of RegEx)
            needleBr := "\{" obj.needle "\}"

            // Special cases where only replace first or last occurrence
            if obj.last { // Replacing the last occurrence has priority
                // Retrieve the position of the last occurrence
                lastpos := RegExMatchOcc(haystack, "i)" needleBr, "", 1, -1)
                if lastpos {
                    haystack := RegExReplace(haystack, "i)" needleBr, obj.last, "", 1, lastpos)
                    // Retrieve the position of the last occurrence for padding
                    lastpos := RegExMatchOcc(haystack, "iO)\{.:" obj.needle ":\d+\}", "", 1, -1)
                    if lastpos // Replace padding {chr:obj.needle:num}
                        haystack := repeatPadding(haystack, obj.needle, obj.last, lastpos, 1)
                }
            }
            if obj.first { // Replacing the first occurrence is easier
                haystack := RegExReplace(haystack, "i)" needleBr, obj.first, "", 1, 1)
                // Replace padding {chr:obj.needle:num}
                haystack := repeatPadding(haystack, obj.needle, obj.first, 1, 1)
            }

            // Changes to obj.replace will not be stored in finalReplace
            modifiable := obj.replace // Obj.replace should not be modified
            haystack := regexIncr(haystack, "i)" needleBr, modifiable, obj.incr)

            // Replace padding {chr:obj.needle:num}
            haystack := repeatPadding(haystack, obj.needle, modifiable)
        }
        return haystack
    }

    /**
     * Returns the elements of the block as one concatenated string
     *
     * only            Indices of items to include
     *
     * returns         String of the content of all included items
     */
    toString(only=0) {
        // Only return changes if atLeastOne item is present
        atLeastOne := False
        // Iterate over all elements
        for key, val in this.block {
            // Only add valid items (skip key -2)
            if (key > 0) && (!IsObject(only) || ObjHasVal(only, key)) {
                atLeastOne := True // At least one valid entry is now present
                nbstr .= val
            } else if (key == 0) // Or the header
                nbstr .= fill("`n", this.nlb4) val // Add newlines and header
            else if (key == -1) // And add original content at the beginning
                nbstr .= val
        }
        // Add newlines before entire block
        nbstr .= fill("`n", this.nlaf)

        // Get the value of key -2 and put it at the very end
        if this.block.HasKey(-2) // If original content is set to end of hook
            nbstr .= this.block[-2]

        // If no item was added, only return original content
        if !atLeastOne
            nbstr := this.block[this.rest]

        // Finally replace all pattern-replace pairs (incrementing)
        nbstr := this.finalReplaceAll(nbstr)

        return nbstr
    }

    /**
     * Length of the block as a string
     *
     * only            Indices of items to include
     *
     * returns         String length of the block
     */
    finalLen(only=0) {
        return StrLen(this.toString(only))
    }

    /*
     * Wrapper method to add something to the block. Did I mention that
     * Array.Insert() is broken? Wasted my entire day haunted by weird bugs:
     * Do not use it when the indices are important - Array.Insert() alters them
     *
     * key             Key-name
     * val             Value
     *
     * returns         Val if successful
     */
    add(key, val) {
        return this.block[key] := val
    }

    /**
     * Wrapper method to remove something from the block
     *
     * key             Key-name to remove
     *
     * returns         True if successful, False otherwise
     */
    remove(key) {
        return this.block.Remove(key)
    }

    /**
     * Searches all items in block for specific content
     *
     * needle          Search string (value)
     *
     * returns         True if found, False otherwise
     */
    search(needle) {
        for 0, item in this.block
            if InStr(item, needle)
                return True
        return False
    }

    /**
     * Sets a header string
     *
     * str             String of the header
     * force           Set header even when there is no content
     */
    setHeader(str, force:=False) {
        if this.isEmpty() and !force
            return
        this.block[0] := str // Always at postion zero
    }

    /**
     * Returns if the block is empty (excludes original content and header)
     *
     * returns         True if no new items present, False otherwise
     */
    isEmpty() {
        if (ObjCount(this.block) == 0) // Completely empty
            return True
        else if (ObjCount(this.block) == 1) // Exclude original content
        && (this.block.HasKey(-1) || this.block.HasKey(-2))
            return True
        else if (ObjCount(this.block) == 1) // Exclude header
        && (this.block.HasKey(0))
            return True
        else if (ObjCount(this.block) == 2) // Exclude both
        && (this.block.HasKey(-1) || this.block.HasKey(-2))
        && (this.block.HasKey(0))
            return True
        else
            return False
    }

    /**
     * Replaces a substring of a specified item. This method is mostly
     * equivalent to StrReplace(), but instead of taking a needle, it expects
     * the position and length of substring to replace.
     * This method expects GLOBAL offsets! Global as in this.onset+onset
     *
     * key             Block-entry index (item)
     * onset           Global (see this.onset) position of string to replace
     * count           Numer of characters to replace (length)
     * replaceText     Text to place at onset to onset+count
     *
     * returns         True if successful, False if parameters invalid
     */
    replace(key, onset, count, replaceText) {
        onset -= (this.onset-1) // Assume global onset
        if !this.block.HasKey(key) || (onset < 0) || (count < 0)
            return False
        newVal := SubStr(this.block[key], 1, onset-1) // Everthing up to onset
        newVal .= replaceText
        newVal .= SubStr(this.block[key], onset+count) // Everthing after
        this.block[key] := newVal // Update item
        return True
    }

    /**
     * Checks whether there are changes made
     *
     * only            Indices of items to include
     *
     * returns         True if the items impact the content, False otherwise
     */
    modifiedBy(only=0) {
        // Iterate over all elements
        for key, 0 in this.block
            // Only check valid items (skip key -2, -1 and 0: header, rest)
            if (key > 0) && (!IsObject(only) || ObjHasVal(only, key))
                return True
        return False
    }
}
