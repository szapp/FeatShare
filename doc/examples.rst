.. _examples:

.. index:: Examples

Examples
========

For an introduction and the most basic examples refer to :ref:`Quick Start <tutorial>` and the
:ref:`feature introduction <features>`.
Here follow some more advanced examples.

.. note::
    **Note**: The anchor scripts below are only partial anchors.
    A lot of information is missing.
    They are incomplete.

Please be aware that these examples are still very basic.
There is much more that can be done with FeatShare.

.. _examples.matchBrackets:

Match Closed Parentheses
------------------------

Regular expression do not offer matching of brackets since it involves dealing with nested structures.
Nevertheless, FeatShare, offers matching of brackets and parenthesis (``{ }``, ``[ ]``, ``( )``).

This example matches the closed square bracket in the third row::

    FeatShare can match (parentheses, as well
    as curly {brackets and [ square brackets. Even if
    they are not} sequenced ] correctly).

.. container:: coderef

    | {
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "(.)brackets\\\\s+and\\\\s+(.)",
    |         :std:term:`"flags" <regex.flags>`: {
    |             :std:term:`"caseSensitive" <regex.flags.caseSensitive>`: false,
    |             :std:term:`"dotInclNL" <regex.flags.dotInclNL>`: false,
    |             :std:term:`"multiLine" <regex.flags.multiLine>`: true,
    |             :std:term:`"ungreedy" <regex.flags.ungreedy>`: false,
    |             :std:term:`"occurrence" <regex.flags.occurrence>`: 1
    |         }
    |     },
    |     :std:term:`"matchBracket" <matchBracket>`: {
    |         "parenthesis": "$2",
    |         "curlyBracket": "$1"
    |     }
    | }

This anchor will detect the following subpatterns::

    $0:              Position:  53   Length: 15   Content: {brackets and [
    $1:              Position:  53   Length:  1   Content: {
    $2:              Position:  67   Length:  1   Content: ]
    $curlyBracket:   Position: 107   Length:  1   Content: }
    $parenthesis:    Position: 118   Length:  1   Content: (

Find Last Occurrence
--------------------

Taking the example from :ref:`examples.matchBrackets`, the following demonstrates how to match a certain occurrence
other than the very first.

.. container:: coderef

    | {
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "brackets",
    |         :std:term:`"flags" <regex.flags>`: {
    |             :std:term:`"occurrence" <regex.flags.occurrence>`: -1
    |         }
    |     }
    | }

This anchor will detect the last (-1) occurrence of the word "brackets"::

    $0:              Position:  76   Length: 8   Content: brackets

The property :std:term:`flags.occurrence` can take any number.
If the number is negative the n-th occurrence from the back of the text will be matched.

Indent Lines
------------

Lines can easily be indented using :ref:`constrained repeat-instructions <constrainedRepeatInstructions>`::

    def plus5(x):
    return x+5

.. container:: coderef

    | {
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "(^)return.*",
    |         :std:term:`"flags" <regex.flags>`: {
    |             :std:term:`"multiLine" <regex.flags.multiLine>`: true
    |         }
    |     },
    |     :ref:`"hook" <anchors.hook>`: {
    |         :std:term:`"start" <hook.start>`: "$0",
    |         :std:term:`"length" <hook.length>`: "$0",
    |         :std:term:`"before" <hook.before>`: false,
    |         :std:term:`"replace" <hook.replace>`: {
    |             "$1": "{\t:1}"
    |         }
    |     },
    |     :ref:`"insert" <anchors.insert>`: {
    |         :std:term:`"string" <insert.string>`: " // Indented"
    |     }
    | }

This will result in:

.. container:: diffdefault

    .. code-block:: diff

         def plus5(x):
        -return x+5
        +   return x+5 // Indented


Re-Indent Statements
--------------------

There might be some malformatted code where block indentation was destroyed::

    num1       = 0;
    num2 = 2;

.. container:: coderef

    | {
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "num\\\\d+(\\\\s+)=(\\\\s+)\\\\d+;.*\\\\Rnum\\\\d+(\\\\s+)=(\\\\s+)\\\\d+;"
    |     },
    |     :std:term:`"storeVars" <storeVars>`: {
    |         "padBefore": "$1",
    |         "padAfter": "$2"
    |     },
    |     :ref:`"hook" <anchors.hook>`: {
    |         :std:term:`"start" <hook.start>`: "$0",
    |         :std:term:`"length" <hook.length>`: "$0",
    |         :std:term:`"before" <hook.before>`: false,
    |         :std:term:`"replace" <hook.replace>`: {
    |             "$3": "{pB}",
    |             "$4": "{pA}"
    |         }
    |     },
    |     :ref:`"insert" <anchors.insert>`: {
    |         :std:term:`"string" <insert.string>`: " // Fixed"
    |     },
    |     :ref:`"finalReplace" <anchors.finalReplace>`: [
    |         {
    |             :std:term:`"needle" <finalReplace.needle>`: "pB",
    |             :std:term:`"replace" <finalReplace.replace>`: "padBefore"
    |         },
    |         {
    |             :std:term:`"needle" <finalReplace.needle>`: "pA",
    |             :std:term:`"replace" <finalReplace.replace>`: "padAfter"
    |         }
    |     ]
    | }

This results in:

.. container:: diffdefault

    .. code-block:: diff

         num1       = 0;
        -num2 = 2;
        +num1       = 0;
        +num2       = 2; // Fixed


Add new files
-------------

A feature may need to add completely new files.
If it is a purely text-based file, it could technically be added by referencing a non-existent file in the anchors and
adding an empty regex needle.
However, this is very inconvenient as the feature file would have to hold the entire content of the new file.
Instead, features may add new files - even binary files.
There is no special settings that has to be applied in the anchors.
This is how it is done.

.. container:: coderef

    | ### infoText ###
    | This feature will add three new files
    | ### copyFiles ###
    | file1.txt|relative\\path\\in\\target\\environment\\
    | another\\file2.exe|relative\\path\\to\\destination\\
    | another\\file3.exe|relative\\path\\to\\destination\\
    | ### end ###

For a more thorough explanation, see the :ref:`feature introduction <features>`.

.. _examples.patch:

Update and Patches
------------------

For an example for more sophisticated anchors with conditions, see :ref:`conditional anchors <conditionalAnchor>`.
Conditional Anchors are well suited for update and patch setups, where a certain feature will only be integrated/updated
if it doesn't exist/exists in the target environment.
