.. _anchors:

.. index:: Anchors

Anchors
=======

.. toctree::
    :hidden:

    anchors/index
    anchors/regex
    anchors/hooks
    anchors/conditional

This is an example anchor with a complete list of settings.

.. container:: coderef



    | {
    |     :std:term:`"description" <description>`: "Anchor description",
    |     :std:term:`"path" <path>`: "path\\to\\file_to_modify",
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <needle>`: "const.+int.+CUT_OFF.*=[^\\d]*(\\d+).*$",
    |         :std:term:`"flags" <flags>`: {
    |             :std:term:`caseSensitive" <caseSensitive>`: false,
    |             :std:term:`"dotInclNL" <dotInclNL>`: false,
    |             :std:term:`"multiLine" <multiLine>`: true,
    |             :std:term:`"ungreedy" <ungreedy>`: false,
    |             :std:term:`"occurrence" <occurrence>`: 1
    |         }
    |     },
    |     :std:term:`"matchBracket" <matchBracket>`: {},
    |     :std:term:`"storeVars" <storeVars>`: {
    |         "max_const": "$1"
    |     },
    |     :ref:`"hook" <anchors.hook>`: {
    |         :std:term:`"start" <hook.start>`: "$0",
    |         :std:term:`"length" <hook.length>`: "$0",
    |         :std:term:`"before" <hook.before>`: true,
    |         :std:term:`"replace" <hook.replace>`: {
    |             "$1": "{idx}"
    |         }
    |     },
    |     :ref:`"insert" <anchors.insert>`: {
    |         :std:term:`"string" <insert.string>`: "const int {const_name}{ :const_name:19}= {idx};\n",
    |         :std:term:`"replace" <insert.replace>`: {
    |             "const_name": "const"
    |         },
    |         :std:term:`"stripTrailingNL" <insert.stripTrailingNL>`: false,
    |         :std:term:`"indent" <insert.indent>`: {
    |             :std:term:`"string" <insert.indent.string>`: "",
    |             :std:term:`"exclFirstLine" <insert.indent.exclFirstLine>`: false,
    |             :std:term:`"exclHeader" <insert.indent.exclHeader>`: false
    |         }
    |     },
    |     :std:term:`"newlinesBefore" <newlinesBefore>`: 0,
    |     :std:term:`"newlinesAfter" <newlinesAfter>`: 1,
    |     :std:term:`"localHeader" <localHeader>`: "",
    |     :std:term:`"setHeader" <setHeader>`: true,
    |     :std:term:`"finalReplace" <finalReplace>`: [
    |         {
    |             :std:term:`"needle" <finalReplace.needle>`: "idx",
    |             :std:term:`"replace" <finalReplace.replace>`: "max_const",
    |             :std:term:`"incr" <finalReplace.incr>`: 1,
    |             :std:term:`"first" <finalReplace.first>`: "0",
    |             :std:term:`"last" <finalReplace.last>`: "1000",
    |         }
    |     ],
    |     :std:term:`"deleteFiles" <deleteFiles>`: {
    |         :std:term:`"paths" <deleteFiles.paths>`: [],
    |         :std:term:`"replace" <deleteFiles.replace>`: {}
    |     },
    |     :std:term:`"globalDependencies" <globalDependencies>`: [],
    |     :std:term:`"dependencies" <dependencies>`: [
    |         "const"
    |     ],
    |     :std:term:`"ignoreOnFail" <ignoreOnFail>`: false
    | }

General Settings
----------------

.. glossary::

    description
        Description of the action the anchor will perform. This will be shown in the progress bar of the installation.

    path
        Relative path of the file the anchor will modify. If the file does not exist, the anchor will :std:term:`fail<ignoreOnFail>`.

    regex
    needle
        Regular expression to match desired part in the target file.
        If the phrase is non-empty and not found in the file but the file exists, the anchor will :std:term:`fail<ignoreOnFail>`.
        If the file does not exist and needle is empty, the file will be created.
        The exact position to hook the new content is set by the :ref:`hook<anchors.hook>`-settings.

        **Note**: Certain characters (like back-slashes) need to be escaped by an additional backslash (e.g. ``\\``).

    flags
    caseSensitive
    dotInclNL
    multiLine
    ungreedy
    occurrence
        See :ref:`Regex flags <regexflags>`

    matchBracket
        Regex does not support nested structures like matching brackets.
        Nevertheless, it is possible to find the position of a matching bracket/paranthesis with this property.
        This property takes an associated list of variable names and subpatterns.
        Each variable name stores the matched character for futher use and the subpattern from the :std:term:`regex` (e.g. ``$1``).

        **Note**: The subpattern must entail only **one** character, which is either one of these: ``{``, ``(`` or ``[``.

        The example code below will store the matched character of the open paranthesis which is assumed to be in subpattern ``$2`` into ``parenthesis`` and the curly bracket in subpattern ``$1`` into ``curlyBracket``.

        .. container:: coderef

            | "matchBracket": {
            |     "parenthesis": "$2",
            |     "curlyBracket": "$1"
            | }

    storeVars
        Like in :std:term:`matchBracket<matchBracket>` this associative list of variable-subpattern pairs can store parts of the matched regex phrase into variables.
        The stored subpatterns will, unlike any of the other available storing mechanisms, be preserved across anchors.
        Any of these global variables can then be referenced in **future** anchors.
        Anchors defined (and thus processed) before the anchors in which the variables are set will not find them.

        Stored variables are the only variables that can be used as :std:term:`global dependencies<globalDependencies>`.

        **Note**: These global variables only store the contents of a pattern, not their position properties, as they cannot be carried accross anchors (files).

.. _anchors.hook:

Hook
----

The hook block is defining the points at which new content will be inserted relative to the matched regex patterns.
The target file may be hooked at one precise position.
The hook may also span multiple characters (as determinded by :std:term:`hook.length`).
Thus, new content can not only be added in the around a match, but the match itself can also be modified (see :std:term:`hook.replace`).

If an anchor does not define a hook, it is a :ref:`conditional anchor<conditionalAnchor>`.

.. glossary::

    hook.start
        (Start) position of the hook.
        This may be one of the following.

            - **regex subpattern** (e.g. ``$1`` for first subpattern or ``$0`` for entire match), which will take the starting position of the subpattern
            - **local variable** (as stored by :std:term:`matchBracket`), which will take the starting position of the contents
            - **absolute position** (this is not a line number, but a total charachter count), which is rare and is not recommended

        **Note**: Global variables (as defined in :std:term`storeVars`) **cannot** be used as they do not have position properties.

    hook.length
        This specifies the length of the hook.
        The same values are accepted as for :std:term:`hook.start`, with the difference of retrieving the length of subpattern or variable instead of the start.
        The length of the hook does not influence the insertion of new contents directly.
        Where the new content is added is decided primarily by :std:term:`hook.before`.

    hook.before
        This property is a boolean.
        If set to ``true``, the new contents will be inserted before the hook.
        This means on :std:term:`hook.start`, pushing everything to the left.

        If set to ``false``, the new contexts will be inserted after the hook.
        This means on :std:term:`hook.start` + :std:term:`hook.length` + 1.

    hook.replace
        This associative property of haystack-needle pairs can be used to replace subpatterns of the regex.
        The haystack is regex subpattern (e.g. ``$1``), the needle is a string.
        The neeedle may entail :ref:`constrained repeat instructions<constainedRepeatInstructions>`.

        **Note**: The subpattern (e.g. ``$1``) **must lie inside** the hook, meaning between :std:term:`hook.start` and :std:term:`hook.start` + :std:term:`hook.length`.

.. _anchors.insert:

Insert
------

tbd

.. glossary::

    insert.string
        tbd

    insert.replace
        tbd

    insert.stripTrailingNL
        tbd

    insert.indent
        tbd

    insert.indent.string
        tbd

    insert.indent.exclFirstLine
        tbd

    insert.indent.exclHeader
        tbd

.. _anchors.miscellaneous:

Miscellaneous
-------------

Miscellaneous properties

.. glossary::

    newlinesBefore
        tbd

    newlinesAfter
        tbd

    localHeader
        tbd

    setHeader
        tbd

    finalReplace
        tbd

    finalReplace.needle
        tbd

    finalReplace.replace
        tbd

    finalReplace.incr
        tbd

    finalReplace.first
        tbd

    finalReplace.last
        tbd

    deleteFiles
        tbd

    deleteFiles.paths
        tbd

    deleteFiles.replace
        tbd

.. _anchors.environment:

Environment
-----------

Environment properties

.. glossary::

    globalDependencies
        tbd

    dependencies
        tbd

    ignoreOnFail
        tbd
