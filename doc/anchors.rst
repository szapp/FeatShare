.. _anchors:

.. index:: Anchors

Anchors
=======

.. toctree::
    :hidden:

    anchors/regex
    anchors/hooks
    anchors/conditional
    anchors/repeatInstructions

Anchors decide which features are integrated into which target files.
Many features may rely on the same anchors, anchors may be shared accross different projects.

There are also special anchors, that are called :ref:`conditional anchors <conditionalAnchor>`.

This is an example anchor with a complete list of settings.
See :ref:`examples <examples>` to find out what this anchor does.

.. container:: coderef

    | {
    |     :std:term:`"description" <description>`: "Anchor description",
    |     :std:term:`"path" <path>`: "path\\\\to\\\\file_to_modify",
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "const.+int.+CUT_OFF.*=[^\\\\d]*(\\\\d+).*$",
    |         :std:term:`"flags" <regex.flags>`: {
    |             :std:term:`caseSensitive" <regex.flags.caseSensitive>`: false,
    |             :std:term:`"dotInclNL" <regex.flags.dotInclNL>`: false,
    |             :std:term:`"multiLine" <regex.flags.multiLine>`: true,
    |             :std:term:`"ungreedy" <regex.flags.ungreedy>`: false,
    |             :std:term:`"occurrence" <regex.flags.occurrence>`: 1
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
    |     :ref:`"finalReplace" <anchors.finalReplace>`: [
    |         {
    |             :std:term:`"needle" <finalReplace.needle>`: "idx",
    |             :std:term:`"replace" <finalReplace.replace>`: "max_const",
    |             :std:term:`"incr" <finalReplace.incr>`: 1,
    |             :std:term:`"first" <finalReplace.first>`: "0",
    |             :std:term:`"last" <finalReplace.last>`: "1000",
    |         }
    |     ],
    |     :ref:`"deleteFiles" <anchors.deleteFiles>`: {
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
        Relative path of the file the anchor will modify. If the file does not exist, the anchor will
        :std:term:`fail<ignoreOnFail>`.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

    regex
    regex.needle
        :ref:`Regular expression <regex>` to match desired part in the target file.
        If the phrase is non-empty and not found in the file but the file exists, the anchor will
        :std:term:`fail<ignoreOnFail>`.
        If the file does not exist and needle is empty, the file will be created.
        The exact position to hook the new content is set by the :ref:`hook<anchors.hook>`-settings.

        .. note::
            **Note**: Certain characters (like back-slashes) need to be escaped by an additional backslash
            (e.g. ``\\``).

    regex.flags
    regex.flags.caseSensitive
    regex.flags.dotInclNL
    regex.flags.multiLine
    regex.flags.ungreedy
    regex.flags.occurrence
        See :ref:`Regex flags <regexflags>`

    matchBracket
        :ref:`Regex <regex>` does not support nested structures like matching brackets.
        Nevertheless, it is possible to find the position of a matching bracket/paranthesis with this property.
        This property takes an associated list of variable names and :ref:`subpatterns <subpatterns>`.
        Each variable name stores the matched character for futher use and the subpattern from the :std:term:`regex`
        (e.g. ``$1``).

        .. note::
            **Note**: The subpattern must entail only **one** character, which is either one of these: ``{``, ``(`` or
            ``[``.

        The example code below will store the matched character of the open paranthesis which is assumed to be in
        subpattern ``$2`` into ``parenthesis`` and the curly bracket in subpattern ``$1`` into ``curlyBracket``.

        .. container:: coderef

            | "matchBracket": {
            |     "parenthesis": "$2",
            |     "curlyBracket": "$1"
            | }

    storeVars
        Like in :std:term:`matchBracket<matchBracket>` this associative list of variable-:ref:`subpattern <subpatterns>`
        pairs can store parts of the matched regex phrase into variables.
        The stored subpatterns will, unlike any of the other available storing mechanisms, be preserved across anchors.
        Any of these global variables can then be referenced in **future** anchors.
        Anchors defined (and thus processed) before the anchors in which the variables are set will not find them.

        Stored variables are the only variables that can be used as :std:term:`global dependencies<globalDependencies>`.

        .. note::
            **Note**: These global variables only store the contents of a pattern, not their position properties, as
            they cannot be carried accross anchors (files).

        .. note::
            **Note**: If an anchor fails all global variables associated with this anchor will be deleted, regardless of
            whether those variables had been already defined by previous anchors.

.. _anchors.hook:

Hook
----

The hook block is defining the points at which new content will be inserted relative to the matched regex patterns.
The target file may be hooked at one precise position.
The hook may also span multiple characters (as determinded by :std:term:`hook.length`).
Thus, new content can not only be added the around a match, but the match itself can also be modified (see
:std:term:`hook.replace`).

If an anchor does not define a hook, it is a :ref:`conditional anchor<conditionalAnchor>`.

.. glossary::

    hook.start
        (Start) position of the hook.
        This may be one of the following.

            - **regex subpattern** (e.g. ``$1`` for first :ref:`subpattern <subpatterns>` or ``$0`` for entire match),
              which will take the starting position of the subpattern
            - **local variable** (as stored by :std:term:`matchBracket`), which will take the starting position of the
              contents
            - **absolute position** (this is not a line number, but a total charachter count), which is rare and is not
              recommended

        .. note::
            **Note**: Global variables (as defined in :std:term`storeVars`) **cannot** be used as they do not have
            position properties.

    hook.length
        This specifies the length of the hook.
        The same values are accepted as for :std:term:`hook.start`, with the difference of retrieving the length of
        :ref:`subpattern <subpatterns>` or variable instead of the start.
        The length of the hook does not influence the insertion of new contents directly.
        Where the new content is added is decided primarily by :std:term:`hook.before`.

    hook.before
        This property is a boolean.
        If set to ``true``, the new contents will be inserted before the hook.
        This means on :std:term:`hook.start`, pushing everything to the left.

        If set to ``false``, the new contexts will be inserted after the hook.
        This means on :std:term:`hook.start` + :std:term:`hook.length` + 1.

    hook.replace
        This associative property of needle-replace pairs can be used to replace :ref:`subpatterns <subpatterns>`
        of the regex.
        The needle is a regex subpattern (e.g. ``$1``), the replace phrase is a string.
        The replace phrase may entail :ref:`constrained repeat-instructions<constrainedRepeatInstructions>`.
        Parts of the replace phrase may also be enclosed by curly brackets ``{ }`` to constitute replace keywords to be
        subject to :ref:`final replaces<anchors.finalReplace>`.

        .. note::
            **Note**: The subpattern (e.g. ``$1``) **must lie inside** the hook, meaning between :std:term:`hook.start`
            and :std:term:`hook.start` + :std:term:`hook.length`.

.. _anchors.insert:

Insert
------

This set of properties decides what new content is integrated.
Although, new content is in most cases provided by the :ref:`features <features>`, **how** exactly it will be inserted
is defined in this part.

.. glossary::

    insert.string
        This phrase will be inserted at the specified :ref:`hook<anchors.hook>`.
        Aside from literal characters it may be made up of replace keywords (see :std:term:`insert.replace`) or
        :ref:`repeat-instructions <repeatInstructions>`.
        The contents passed to the anchor by the :ref:`features <features>` can be inserted by specifying a replace
        keyword, which can then be referred to by :std:term:`insert.replace` to incorporate the contents from the
        :ref:`features <features>`.

    insert.replace
        This associative list consists of needle-replace pairs.
        The needles can be any of the following.

            - Replace keyword without the enclosing curly brackets ``{ }``.
            - Global variable (see :std:term:`storeVars`)

        The replace phrase can be any of the following.

            - Global variable (see :std:term:`storeVars`)
            - Feature (see :ref:`features <features>`)
            - Repeat-instructions (see :ref:`repeatInstructions <repeatInstructions>`)
            - Literal text

        If the needle is a global variable, it will first be interpreted before searching the :std:term:`insert.string`.
        This enables to search for phrase which are not known at the time of definition.

        For more in depth insight see the :ref:`examples <examples>`.

    insert.stripTrailingNL
        If ``true``, trailing new lines of the :std:term:`insert.string` will be removed.

    insert.indent
        This block enables padding the beginning of all lines by phrase (typically for indenting, hence the name)

    insert.indent.string
        The characters used to prefix all lines. E.g. ``\t\t`` for indenting by two tabs.

    insert.indent.exclFirstLine
        If ``true``, do not add indentation to the first line of :std:term:`insert.string`.

    insert.indent.exclHeader
        If ``true``, the :std:term:`header <setHeader>` (if present) will not be indented.

.. _anchors.environment:

Environment
-----------

This section defines the embedding of the new content.
The environment around the new content can be altered with these properties.

.. glossary::

    newlinesBefore
        The number of line breaks before the new content.

    newlinesAfter
        The number of line breaks after the new content.

    localHeader
        A phrase to use as :std:term:`header <setHeader>` instead of the :std:term:`global header <globalHeader>`.

        .. note::
            **Note**: Do not forget to add comment flags (e.g. ``//``) before the header and a trailing new line if
            applicable.

        .. note::
            **Note**: If set to ``""``, the :std:term:`global header <globalHeader>` will be used.


    setHeader
        If ``true``, a header will be inserted before the new content.
        This may either be the :std:term:`global header <globalHeader>` or a :std:term:`local header <localHeader>`.

        .. note::
            **Note**: If :std:term:`hook.before` is ``false``, the header will be inserted between hooked phrase and the
            new content.

.. _anchors.finalReplace:

FinalReplace
------------

If, for example, incrementing a value, each insertion will depend on the previous one.
As it will not be clear before-hand whether a :ref:`feature <features>` can be successfully integrated or neglected when
applying the changes, the incrementing needs to be done at the very and.
This is where the finalReplace properties come in.

There may be several needle-replace pairs.
Each is listed in their own associative list, making up a non-associative list of final replace instructions.

.. note::
    **Note**: The final replace instructions will be processed in the order they are defined.

.. glossary::

    finalReplace.needle
        This phrase is a replace keyword without curly brackets ``{ }``.
        It will be searched in all insertions as well as the hooked phrase (if :std:term:`hook.length` > 0).

    finalReplace.replace
        The replace phrase may either be a literal phrase or a global variable (see :std:term:`storeVars`).

    finalReplace.incr
        If the replace phrase is a numeric value, it will be incremented by this amount after every insertion.

        .. note::
            **Note**: The value will **not** be incremented after every replacement, but after every block.
            A block being either a feature or the hook phrase (if :std:term:`hook.length` > 0).
            This means if the :std:term:`insert.string` is referencing the finalReplace.needle twice, both will have the
            same value.
            Only after proceeding to the next insertion block, it will increase.

        See this short example:

        .. container:: coderef

            | ...
            |
            | “insert”: {
            |     “string”: “increase this value {idx} twice {idx}\n”,
            |
            | ...
            |
            | “finalReplace”: [
            |     {
            |         “needle”: “idx”,
            |         “replace”: “0”,
            |         “incr”: 1
            |     }
            | ],
            |
            | ...

        This would yield:

        .. container:: coderef

            | increase this value 0 twice 0
            | increase this value 1 twice 1
            | increase this value 2 twice 2
            | increase this value 3 twice 3
            | ...

    finalReplace.first
        A special phrase may be defined for the first replacement.

    finalReplace.last
        A special phrase may be defined for the last replacement.

.. _anchors.deleteFiles:

DeleteFiles
------------

An anchor may not only modify a file, it can also delete other files.
The files are not connected to the :std:term:`file that this anchor references <path>`.
An anchor may also just delete files instead of modifying any file.
See :ref:`conditional anchors<conditionalAnchor>`.

.. glossary::

    deleteFiles.paths
        Non-associative list of relative file paths to files to delete.
        For security reasons it is not allowed to delete directories and absolute paths are not allowed.
        File paths may include replace keywords enclosed by curly brackets ``{ }`` to be replaced with
        :std:term:`global variables <storeVars>` with the instructions in :std:term:`deleteFiles.replace`.

    deleteFiles.replace
        This is an associative list of needle-replace pairs.
        The needles are replace keywords without curly brackets ``{ }``.
        The replace phrases may be made up of literal characters (which would not make any sense in this context),
        :std:term:`global variables <storeVars>` and
        :ref:`constrained repeat-instructions<constrainedRepeatInstructions>`.

        .. note::
            **Note**: Because of the nature of processing order regarding :ref:`conditional anchors<conditionalAnchor>`,
            the :std:term:`global variables <storeVars>` of an anchor are set **after** the deleteFiles instruction is
            processed.
            Thus, they cannot be used here.

.. _anchors.conditions:

Conditions
----------

Anchors are tied to conditions.
These conditions define which anchor will be needed for which feature.
More sophisticated conditions can be implemented with global dependencies.
See :ref:`conditional anchors<conditionalAnchor>` for more details.

.. glossary::

    globalDependencies
        This non-associative list may hold several conditions on :std:term:`global variables <storeVars>`.
        There are two types of conditions available.

        Set or not set.

        If an anchor should be processed only if a global variable exists (was set to a value other than zero at
        some previous point), specify the name of the variable (e.g. ``variablename``).
        If, however, the variable should not exist (or was set to zero), than prefix the name of the variable with an
        exclamation mark (e.g. ``!variablename``).

        .. note::
            **Note**: Unlike :std:term:`feature dependencies <dependencies>`, these global dependencies will cause the
            anchor to fail, if their conditions not met.
            See :std:term:`ignoreOnFail` for more information.

    dependencies
        This is a non-associative list holding feature requirements.
        An anchor will only be processed for :ref:`features <features>` that define the traits listed here.
        There are two types of conditions available.

        Set or not set.

        If an anchor should only process features that have a certain trait, specify the name of the trait (e.g.
        ``trait``).
        If, however, features should not have that trait, than prefix the name of the trait with an exclamation mark
        (e.g. ``!trait``).

        If a dependency is not met a feature will be skipped.
        There won't be an error or warning, because this serves to identify the anchors that are needed for a certain
        feature.

    ignoreOnFail
        Set to ``false``, to output error when the anchor fails (default and recommended behavior), or set to warning
        phrase.

        An anchor may fail for many different reasons.
        Usually it is a good idea to have this cause an error, which will notify the end-user about what went wrong and
        that the integration was not successful.

        If the anchor is a :ref:`conditional anchor<conditionalAnchor>`, however, an anchor may just fail as a result of
        an unmet :std:term:`global dependency <globalDependencies>`.
        See :ref:`conditional anchors<conditionalAnchor>` for more details.

        .. note::
            **Note**: If an anchor fails all :std:term:`global variables <storeVars>` associated with this anchor will
            be deleted, regardless of whether those variables had been already defined by previous anchors.
