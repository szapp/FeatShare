.. _configjson:

.. index:: Configuration (config.json)

Configuration (config.json)
===========================

In principle everything that might be customizable, is customizable.

A valid ``config.json`` is necessary in every **FeatShare** setup - even if using default settings. An empty
``config.json`` needs to at least have the setting :ref:`anchors <config.anchors>`.

This is a complete ``config.json`` with all its default values.

.. container:: coderef

    | {
    |     :std:term:`"title" <title>`: "Setup",
    |     :std:term:`"globalHeader" <globalHeader>`: "",
    |     :ref:`"log" <config.log>`: {
    |         :std:term:`"showDebug" <log.showDebug>`: false,
    |         :std:term:`"showWarn" <log.showWarn>`: false,
    |         :std:term:`"instantFlush" <log.instantFlush>`: true,
    |         :std:term:`"timeformat" <log.timeformat>`: "yyyy-MM-dd HH:mm:ss"
    |     },
    |     :std:term:`"installInstruction" <installInstruction>`: "Choose the directory to integrate into",
    |     :std:term:`"defaultPath" <defaultPath>`: "C:\\\\Program Files (x86)",
    |     :std:term:`"dryRun" <dryRun>`: false,
    |     :ref:`"diffGUI" <config.diffGUI>`: false,
    |     :std:term:`"diffGUIstyle" <diffGUIstyle>`: "FeatShareDefault",
    |     :ref:`"diffGUIstyles" <config.diffGUIstyles>`: {
    |         :ref:`"FeatShareDefault" <config.diffGUIstyles>`: {
    |             :std:term:`"background" <diffGUIstyles.background>`: "F0F0F0",
    |             :std:term:`"default" <diffGUIstyles.default>`: "4F4D45",
    |             :std:term:`"info" <diffGUIstyles.info>`: "A2A29D",
    |             :std:term:`"remove" <diffGUIstyles.remove>`: "B11000",
    |             :std:term:`"add" <diffGUIstyles.add>`: "50A900"
    |         }
    |     },
    |     :ref:`"features" <config.features>`: {
    |         :std:term:`"path" <features.path>`: "",
    |         :std:term:`"filePattern" <features.filePattern>`: "^.*\\\\.(?!json$)(?!exe$)",
    |         :ref:`"anchorPattern" <features.anchorPattern>`: {
    |             :std:term:`"regex" <features.anchorPattern.regex>`: "### ([\\\\w\\\\*\\\\(\\\\)\\\\.\\\\:_]+) ###\\\\R(.*)\\\\R### [\\\\w\\\\*\\\\(\\\\)\\\\.\\\\:_]+ ###",
    |             :std:term:`"flags" <features.anchorPattern.flags>`: {
    |                 :std:term:`"caseSensitive" <features.anchorPattern.flags.caseSensitive>`: false,
    |                 :std:term:`"dotInclNL" <features.anchorPattern.flags.dotInclNL>`: true,
    |                 :std:term:`"multiLine" <features.anchorPattern.flags.multiLine>`: false,
    |                 :std:term:`"ungreedy" <features.anchorPattern.flags.ungreedy>`: true
    |             },
    |             :std:term:`"key" <features.anchorPattern.key>`: "$1",
    |             :std:term:`"value" <features.anchorPattern.value>`: "$2"
    |         },
    |         :std:term:`"infoTextAnchor" <features.infoTextAnchor>`: "infoText",
    |         :ref:`"fileCopyAnchor" <features.fileCopyAnchor>`: {
    |             :std:term:`"name" <features.fileCopyAnchor.name>`: "copyFiles",
    |             :std:term:`"regex" <features.fileCopyAnchor.regex>`: "^([^:\*?<>|\\"]+)\\\\|([^:\*?<>|\\"]+)$",
    |             :std:term:`"flags" <features.fileCopyAnchor.flags>`: {
    |                 :std:term:`"caseSensitive" <features.fileCopyAnchor.flags.caseSensitive>`: false,
    |                 :std:term:`"dotInclNL" <features.fileCopyAnchor.flags.dotInclNL>`: false,
    |                 :std:term:`"multiLine" <features.fileCopyAnchor.flags.multiLine>`: true,
    |                 :std:term:`"ungreedy" <features.fileCopyAnchor.flags.ungreedy>`: false
    |             },
    |             :std:term:`"fromPath" <features.fileCopyAnchor.fromPath>`: "$1",
    |             :std:term:`"toPath" <features.fileCopyAnchor.toPath>`: "$2"
    |         },
    |         :ref:`"fileDeleteAnchor" <features.fileDeleteAnchor>`: {
    |             :std:term:`"name" <features.fileDeleteAnchor.name>`: "deleteFiles",
    |             :std:term:`"regex" <features.fileDeleteAnchor.regex>`: "^([^:\*?<>|\\"]+)$",
    |             :std:term:`"flags" <features.fileDeleteAnchor.flags>`: {
    |                 :std:term:`"caseSensitive" <features.fileDeleteAnchor.flags.caseSensitive>`: false,
    |                 :std:term:`"dotInclNL" <features.fileDeleteAnchor.flags.dotInclNL>`: false,
    |                 :std:term:`"multiLine" <features.fileDeleteAnchor.flags.multiLine>`: true,
    |                 :std:term:`"ungreedy" <features.fileDeleteAnchor.flags.ungreedy>`: false
    |             },
    |             :std:term:`"filePath" <features.fileDeleteAnchor.filePath>`: "$1"
    |         }
    |     },
    |     :ref:`"anchors" <config.anchors>`: {
    |         "": "^anchor.*\\\\.json$"
    |     }
    | }


General Settings
----------------

.. glossary::

    title
        The title is displayed in the setup window title.
        The title should be concise.
        It will **not** be truncated to fit the title bar.
        This setting is also used to construct the name of the backup directory created to store the original files
        before modifying or overwriting them.

    globalHeader
        This will function as the default heading on top of each inserted block. Keep in mind to include a comment flag
        here (**if** the header should be a comment), like ``//``. This is a **global** header as the name indicates.
        Each anchor may have its own :std:term:`("local") header <localHeader>`. This setting can be left blank (``""``).

    installInstruction
        This description will be shown in the setup window above the :std:term:`target directory <defaultPath>`
        (see below). Choose a phrase which is not too long. It will **not** be truncated to fit into the window.

    defaultPath
        This is the default directory which will be pre-selected by default and is visible in the setup window below the
        :std:term:`installInstruction`. The end-user can then select their preferred directory.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

.. _config.log:

Log
---

A log file will be created to to show more details on all operations performed, errors and possibly warnings.

.. glossary::

    log.showDebug
        This setting can be ignored. It was used for development purposes and should always be set to ``false``.

    log.showWarn
        Setting this to ``true`` will also log all warnings. Errors will always be logged regardless.

    log.instantFlush
        If this setting is ``true`` the log is written in real-time. Every event is then written to the log file as it
        happens, instead of at the end of the setup (``false``).

        .. note::
            **Note:** This setting is overwritten to ``false`` if :std:term:`dryRun` or :std:term:`diffGUI` are
            ``true``.

    log.timeformat
        Each line in the log file is preceded by a time stamp to identify the time at which an event occurred. The time
        may be constructed using these formatting characters.

        +------+------------------------------------------------------------------------------------+
        |      | |                                                                                  |
        |      | | **Date Formats (case sensitive)**                                                |
        +------+------------------------------------------------------------------------------------+
        | d    | Day of the month without leading zero (1 - 31)                                     |
        +------+------------------------------------------------------------------------------------+
        | dd   | Day of the month with leading zero (01 – 31)                                       |
        +------+------------------------------------------------------------------------------------+
        | ddd  | Abbreviated name for the day of the week (e.g. Mon) in the current user's language |
        +------+------------------------------------------------------------------------------------+
        | dddd | Full name for the day of the week (e.g. Monday) in the current user's language     |
        +------+------------------------------------------------------------------------------------+
        | M    | Month without leading zero (1 – 12)                                                |
        +------+------------------------------------------------------------------------------------+
        | MM   | Month with leading zero (01 – 12)                                                  |
        +------+------------------------------------------------------------------------------------+
        | MMM  | Abbreviated month name (e.g. Jan) in the current user's language                   |
        +------+------------------------------------------------------------------------------------+
        | MMMM | Full month name (e.g. January) in the current user's language                      |
        +------+------------------------------------------------------------------------------------+
        | y    | Year without century, without leading zero (0 – 99)                                |
        +------+------------------------------------------------------------------------------------+
        | yy   | Year without century, with leading zero (00 - 99)                                  |
        +------+------------------------------------------------------------------------------------+
        | yyyy | Year with century. For example: 2005                                               |
        +------+------------------------------------------------------------------------------------+
        | gg   | Period/era string for the current user's locale (blank if none)                    |
        +------+------------------------------------------------------------------------------------+
        |      | |                                                                                  |
        |      | | **Time Formats (case sensitive)**                                                |
        +------+------------------------------------------------------------------------------------+
        | h    | Hours without leading zero; 12-hour format (1 - 12)                                |
        +------+------------------------------------------------------------------------------------+
        | hh   | Hours with leading zero; 12-hour format (01 – 12)                                  |
        +------+------------------------------------------------------------------------------------+
        | H    | Hours without leading zero; 24-hour format (0 - 23)                                |
        +------+------------------------------------------------------------------------------------+
        | HH   | Hours with leading zero; 24-hour format (00– 23)                                   |
        +------+------------------------------------------------------------------------------------+
        | m    | Minutes without leading zero (0 – 59)                                              |
        +------+------------------------------------------------------------------------------------+
        | mm   | Minutes with leading zero (00 – 59)                                                |
        +------+------------------------------------------------------------------------------------+
        | s    | Seconds without leading zero (0 – 59)                                              |
        +------+------------------------------------------------------------------------------------+
        | ss   | Seconds with leading zero (00 – 59)                                                |
        +------+------------------------------------------------------------------------------------+
        | t    | Single character time marker, such as A or P (depends on locale)                   |
        +------+------------------------------------------------------------------------------------+
        | tt   | Multi-character time marker, such as AM or PM (depends on locale)                  |
        +------+------------------------------------------------------------------------------------+

        Taken from `the AutoHotkey documentation
        <https://autohotkey.com/docs/commands/FormatTime.htm#Date_Formats_case_sensitive>`_.


.. _config.diffGUI:

Diff GUI
--------

Before - or instead of - applying the changes, a window may be displayed presenting the full log and all the potential
changes in `diff utility style <https://en.wikipedia.org/wiki/Diff_utility>`_. This is great for testing
(see :std:term:`dryRun`) or to give the end-user more insight before they accept the changes (see :std:term:`diffGUI`).
The diff may be customized to have different color schemes, see :std:term:`diffGUIstyle`.

.. note::
    **Note:** The diff utility shows differences line-wise, not character-wise.

.. glossary::

    dryRun
        When this setting is ``true`` the full installation is disabled. This means the integration is only simulated
        and stopped before any real changes are made. This setting is great for testing and investigating if every
        anchor is hooking as intended. The dry run is indicated on the setup windows with a red mark
        showing "DRY RUN".

        The potential changes (and log file) will be shown in the :ref:`diff window <config.diffGUI>` which is enabled
        by setting the setup to perform dry run.

        The setting should be set to ``false`` when shipping the setup, otherwise the
        end-user won't be able to install the setup.

        .. note::
            **Note:** This setting will overwrite :std:term:`diffGUI` to ``true``.

        .. note::
            **Note:** This setting will overwrite :std:term:`log.instantFlush` to ``false``.

    diffGUI
        This setting is identical to :std:term:`dryRun` with the difference, that the full installation is not disabled.
        This can be usefull, to give the end-user more insight into what changes will be performed. They can then accept
        the changes or abort the setup without applying any changes. (Of course no "DIFF RUN" mark will be visible.)

        .. note::
            **Note:** This setting is overwritten to ``true`` if :std:term:`dryRun` is ``true``.

        .. note::
            **Note:** This setting will overwrite :std:term:`log.instantFlush` to ``false``.

    diffGUIstyle
        The syntax highlighting of the diff is kept in coloring schemes. This setting references the name of the scheme.
        A scheme of the same name has to be defined in :ref:`diffGUIstyles <config.diffGUIstyles>`.
        There may be infinitely many schemes, however, only one can be selected. Thus, having more than one scheme does
        not make much sense. When ignoring this setting, the default setting will be used (see below).

        For style examples see :ref:`diffStyleExamples`.

.. _config.diffGUIstyles:

Diff GUI Styles
^^^^^^^^^^^^^^^

The diff coloring schemes consist of five colors. The values for each setting are expected to be HTML-Color-Codes
without the preceding pound sign (e.g. FF0000 for red). If any of the color settings of the selected
:std:term:`diffGUIstyle` are missing or the :std:term:`diffGUIstyle` is not found, the default scheme will be used
instead.

For examples see :ref:`diffStyleExamples`.

.. glossary::

    diffGUIstyles.background
        This is the canvas (background) color, beneath the text.

    diffGUIstyles.default
        This is the font color.

    diffGUIstyles.info
        This is the font color for details and additional information. This color is recommended to be less prominent
        relative to the other font colors. This color will also be used to color-code the separating dots and
        debug messages in the log of the diff window.

    diffGUIstyles.remove
        This is the font color for lines that will be removed (typically red). This color will also be used to
        color-code warnings in the log of the diff window.

    diffGUIstyles.add
        This is the font color for lines that will be added (typically green).

.. _diffStyleExamples:

Diff GUI Style Examples
^^^^^^^^^^^^^^^^^^^^^^^

Here are two examples of diff coloring schemes. ``FeatShareDefault`` is the default scheme.

.. container:: coderef

    | :ref:`"diffGUIstyles" <config.diffGUIstyles>`: {
    |     "FeatShareDefault": {
    |         :std:term:`"background" <diffGUIstyles.background>`: "F0F0F0",
    |         :std:term:`"default" <diffGUIstyles.default>`: "4F4D45",
    |         :std:term:`"info" <diffGUIstyles.info>`: "A2A29D",
    |         :std:term:`"remove" <diffGUIstyles.remove>`: "B11000",
    |         :std:term:`"add" <diffGUIstyles.add>`: "50A900"
    |     },
    |     "Monokai": {
    |         :std:term:`"background" <diffGUIstyles.background>`: "272822",
    |         :std:term:`"default" <diffGUIstyles.default>`: "F8F8F2",
    |         :std:term:`"info" <diffGUIstyles.info>`: "75715E",
    |         :std:term:`"remove" <diffGUIstyles.remove>`: "F92672",
    |         :std:term:`"add" <diffGUIstyles.add>`: "A6E22E"
    |     }
    | }

.. role:: info
.. role:: remove
.. role:: add

**FeatShareDefault:**

.. container:: diffdefault

    .. code-block:: diff

        --- a\path\to\file.ext
        +++ b\path\to\file.ext
        @@ -400,6 +400,7 @@
         // Constants
         const int AMPLITUDE          = 93;
         const int PHASE              = 94;
        -const int CUT_OFF            = 95;
        +const int FREQ_IN            = 95;
        +const int CUT_OFF            = 96;

         // Additional variables below
         int recentChanges;

**Monokai:**

.. container:: diffmonokai

    .. code-block:: diff

        --- a\path\to\file.ext
        +++ b\path\to\file.ext
        @@ -400,6 +400,7 @@
         // Constants
         const int AMPLITUDE          = 93;
         const int PHASE              = 94;
        -const int CUT_OFF            = 95;
        +const int FREQ_IN            = 95;
        +const int CUT_OFF            = 96;

         // Additional variables below
         int recentChanges;


.. _config.features:

Features
--------

Here is where the feature specifics are set.

.. glossary::

    features.path
        The path in which the feature files are stored. This should be a relative path. Usually this should be empty,
        since the setup extracts all files to a temporary directory. Nevertheless, the file structure is preserved.

    features.filePattern
        This is the regex file pattern for all feature files. If the feature files end on .feat this setting should be
        ``"^.*\\.feat$"``.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

    features.infoTextAnchor
        Feature files contain key-value pairs, where the key is an :ref:`trait <features.traits>` and the value is the
        text to insert, see :ref:`anchor patterns <features.anchorPattern>`. The ``infoTextAnchor`` is an exception.
        If the feature files contain a key of the name of this setting the value will be displayed as information in the
        setup window.
        Default is "infoText".

.. _features.anchorPattern:

Anchor Pattern
^^^^^^^^^^^^^^

This set of options changes the key-value syntax in feature files. The default syntax looks as follows.

.. container:: coderef

    | ### trait ###
    | text to insert
    | spanned over multiple lines
    | ### nextTrait ###
    | some other text to insert
    | ### end ###

Where the value (text to insert at anchor) is wrapped by its key (:ref:`trait <features.traits>`) and the next.
The keys (:ref:`trait <features.traits>`) are indicated by three pound signs.

.. note::
    **Note:** There is typically no need to ever change the anchor pattern. If everything works, do not touch these
    settings.

.. glossary::

    features.anchorPattern.regex
        This setting defines by regex how key-value pairs (trait and text to insert, respectively) are captured.
        Key and value need to be matched in subpatterns, which will be assigned in
        :std:term:`features.anchorPattern.key` and :std:term:`features.anchorPattern.value`.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

    features.anchorPattern.flags
    features.anchorPattern.flags.caseSensitive
    features.anchorPattern.flags.dotInclNL
    features.anchorPattern.flags.multiLine
    features.anchorPattern.flags.ungreedy
        See :ref:`Regex flags <regexflags>`

    features.anchorPattern.key
        The subpattern of :std:term:`regex <features.anchorPattern.regex>` which captures the key (trait). E.g.
        ``$1``.

    features.anchorPattern.value
        The subpattern of :std:term:`regex <features.anchorPattern.regex>` which captures the value (text to insert).
        E.g. ``$2``.

.. _features.fileCopyAnchor:

File Copy Anchor
^^^^^^^^^^^^^^^^

Feature files contain key-value pairs, where the key is an :ref:`trait <features.traits>` and the value is the text to
insert, see :ref:`anchor patterns <features.anchorPattern>`.
The ``fileCopyAnchor`` is an exception.
It defines what files should be copied from the setup to the target directory (including a target sub-directory path).

.. note::
    **Note:** There is typically no need to ever change the file copy pattern. If everything works, do not touch these
    settings.

.. glossary::

    features.fileCopyAnchor.name
        The trait name to indicate the file copy anchor.

    features.fileCopyAnchor.regex
        This setting defines by regex how from-to pairs (origin file name and destination path, respectively) are
        captured. "FromPath" and "toPath" need to be matched in subpatterns, which will be assigned in
        :std:term:`features.fileCopyAnchor.fromPath` and :std:term:`features.fileCopyAnchor.toPath`.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

    features.fileCopyAnchor.flags
    features.fileCopyAnchor.flags.caseSensitive
    features.fileCopyAnchor.flags.dotInclNL
    features.fileCopyAnchor.flags.multiLine
    features.fileCopyAnchor.flags.ungreedy
        See :ref:`Regex flags <regexflags>`

    features.fileCopyAnchor.fromPath
        The subpattern of :std:term:`regex <features.fileCopyAnchor.regex>` which captures the file to copy. E.g.
        ``$1``.

    features.fileCopyAnchor.toPath
        The subpattern of :std:term:`regex <features.fileCopyAnchor.regex>` which captures the file destination path.
        E.g. ``$2``.

.. _features.fileDeleteAnchor:

File Delete Anchor
^^^^^^^^^^^^^^^^^^

Feature files contain key-value pairs, where the key is an :ref:`trait <features.traits>` and the value is the text to
insert, see :ref:`anchor patterns <features.anchorPattern>`.
The ``fileDeleteAnchor`` is an exception.
It defines what files should be deleted from the target directory.

.. note::
    **Note:** There is typically no need to ever change the file delete pattern. If everything works, do not touch these
    settings.

.. glossary::

    features.fileDeleteAnchor.name
        The trait name to indicate the file delete anchor.

    features.fileDeleteAnchor.regex
        This setting defines by regex how the file paths of the files to delete are captured. The subpattern containing
        the file path will be assigned in :std:term:`features.fileDeleteAnchor.filePath`.

        .. note::
            **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).

    features.fileDeleteAnchor.flags
    features.fileDeleteAnchor.flags.caseSensitive
    features.fileDeleteAnchor.flags.dotInclNL
    features.fileDeleteAnchor.flags.multiLine
    features.fileDeleteAnchor.flags.ungreedy
        See :ref:`Regex flags <regexflags>`

    features.fileDeleteAnchor.filePath
        The subpattern of :std:term:`regex <features.fileDeleteAnchor.regex>` which captures the path of the file to
        delete. E.g. ``$0``.

.. _config.anchors:

Anchors
-------

The anchor setting in the config file can either hold all anchors or a reference to dedicated anchor files.

If the anchors are stored in the config file, this setting is a non-associative list (enclosed by square brackets).

.. container:: coderef

    | :ref:`"anchors" <config.anchors>`: [
    |     anchor,
    |     anchor,
    |     anchor
    | ]

Where ``anchor`` is a substitute for anchors, see :ref:`Anchors <anchors>`.

If the anchors are stored in dedicated files, this setting is an associative list (enclosed by curly brackets).

.. container:: coderef

    | :ref:`"anchors" <config.anchors>`: {
    |     "path": "filePattern",
    |     "path": "filePattern",
    |     "path": "filePattern"
    | }

Where ``path`` is a file path to where to find anchor files of this ``filePattern``. The ``filePattern`` is regex.

.. note::
    **Note:** Back-slashes need to be escaped by an additional backslash (``\\``).
