.. _tutorial:

.. index:: Tutorial (Quick Start)

Tutorial (Quick Start)
======================

At the start of each setup are of course the features which should be integrated into an existing file structure.

Nevertheless, there is a little more to setup. This is a short outline of what we need to do.

#. :ref:`Select what to integrate <tutorialFeatures>`
#. :ref:`Create anchors <tutorialAnchors>`
#. :ref:`Create configuration <tutorialConfigJson>`

.. _tutorialFeatures:

1. Features
-----------

First we need to decide **what** we want to integrate - the **how** comes later.

Imagine a project shared with different parties. The project turned into many independent projects, all sharing the same
base structure, but differing a lot. Of course, the projects are not compatible anymore and exchanging files is not
possible. As an unlikely small-scale example, let's consider a java project with different files. Here are parts we need
to change. The only really certain information we have about were to find them are the files that they are in and the
function names.

path\\to\\file1\\function1.java::

    121  ...
    122
    123  public static int substract2(int i)
    124  {
    125     return i-2;
    126  }
    127
    128  ...

path\\to\\file2\\function2.java::

    596  ...
    597
    598  public static int add2(int i)
    599  {
    600      return i+2;
    601  }
    602
    603  ...

Let's assume we want to change that ``substract2()`` should only accept inputs greater than two and ``add2()`` to be
private.

The *what* will be stored in a feature file. Each feature has its own file. What exactly defines a feature is up to you.
Since the changes we want to make are somehow related, let's have them be **one** feature that we want to integrate.
The name of the feature files are up to you as well as the :std:term:`file extension <features.filePattern>`.




The first though might be to just search and replace the affected parts or replace the lines by line number.
However, take a look how the ``function1.java`` looks on a different computer::

    243  ...
    244
    245      public static INT  substract2 ( int i ) {
    246          return i-2;
    247      }
    248
    249  ...

First of all, the line numbers are different. The other person seems to have added a lot to the file. Also, and more
importantly, the spelling and white spaces are different, the code is indented and the open curly bracket is in the same
line instead of the next. How do we go about this?

Clearly we need to make as little assumptions on the parts we are searching as possible. For that we use
:ref:`regular expressions <regex>`.

The best way to go about this is to copy everything

.. _tutorialAnchors:

2. Anchors
----------

Once we know what to insert, we need to make sure it's integrated at the right position - now come the **how**.


.. _tutorialConfigJson:

3. Configuration: config.json
-----------------------------

Before beginning to write the feature files of the setup, we will first have to set some general settings for the setup.

All of those settings are set using a file name :ref:`config.json <configjson>`. Without this file the setup cannot be
build. Therefore, the first thing we need to do now is create a file named ``config.json``. Let's keep it simple for now
and write the following lines to it::

    {
        "title": "My First FeatShare Setup",
        "globalHeader": "// The lines of code below were inserted by my FeatShare setup!",
        "log": {
            "showDebug": false,
            "showWarn": true,
            "instantFlush": true,
            "timeformat": "yyyy-MM-dd HH:mm:ss"
        },
        "installInstruction": "Choose the directory in which to integrate the features",
        "defaultPath": "C:\\Data\\MyProject\\",
        "dryRun": true,
        "diffGUI": false,
        "diffGUIstyle": "windows",
        "diffGUIstyles": {
            "windows": {
                "background": "F0F0F0",
                "default": "4F4D45",
                "info": "A2A29D",
                "remove": "B11000",
                "add": "50A900"
            },
            "monokai": {
                "background": "272822",
                "default": "F8F8F2",
                "info": "75715E",
                "remove": "F92672",
                "add": "A6E22E"
            }
        },
        "features": {
            "path": "",
            "filePattern": "^.*\\.feat$",
            "anchorPattern": {
                "regex": "### ([\\w\\*\\(\\)\\.\\:_]+) ###\\R(.*)\\R### [\\w\\*\\(\\)\\.\\:_]+ ###",
                "flags": {
                    "caseSensitive": false,
                    "dotInclNL": true,
                    "multiLine": false,
                    "ungreedy": true
                },
                "key": "$1",
                "value": "$2"
            },
            "infoTextAnchor": "infoText",
            "fileCopyAnchor": {
                "name": "copyFiles",
                "regex": "^([^:*?<>|\"]+)\\|([^:*?<>|\"]+)$",
                "flags": {
                    "caseSensitive": false,
                    "dotInclNL": false,
                    "multiLine": true,
                    "ungreedy": false
                },
                "fromPath": "$1",
                "toPath": "$2"
            },
            "fileDeleteAnchor": {
                "name": "deleteFiles",
                "regex": "^([^:*?<>|\"]+)$",
                "flags": {
                    "caseSensitive": false,
                    "dotInclNL": false,
                    "multiLine": true,
                    "ungreedy": false
                },
                "filePath": "$1"
            }
        },
        "anchors": {
            "": "^.*\\.json$"
        }
    }


This looks very overwhelming. But don't worry, we will ignore most of these lines for now. For detailed descriptions and
explanations see :ref:`config.json <configjson>`.

Let's have a look at the settings that are important to us now.

+----------------------------------------------------------------------------------------------------------------------+
+----------------------------------------------------------------------------------------------------------------------+
| **title**                                                                                                            |
|     E.g.: ``"My First FeatShare Setup"``                                                                             |
|                                                                                                                      |
|     This is the title which will be visible in the window title bar of the setup. Also the backup directory in which |
|     all affected files will be copied before being modified, will be constructed from this title.                    |
|     A recommended title should not be to long.                                                                       |
+----------------------------------------------------------------------------------------------------------------------+
| **globalHeader**                                                                                                     |
|     E.g.: ``"// The lines of code below were inserted by my FeatShare setup!"``                                      |
|                                                                                                                      |
|     This is setting is optional. This will function as the default heading on top of each inserted block. As         |
|     **FeatShare** was written with coding in mind the example her is preceded by a C++ style comment flag ``//``.    |
|     FeatShare is by no means restricted to only be used on coding projects, but if it is used on one, keep in mind to|
|     include a comment flag here (**if** the header should be a comment).                                             |
|                                                                                                                      |
|     This is a **global** header as the name indicates. Each anchor may have its own ("local") header. We will come to|
|     that later. Feel free to leave this setting blank (``""``).                                                      |
+----------------------------------------------------------------------------------------------------------------------+
| **installInstruction**                                                                                               |
|     E.g.: ``"Choose the directory in which to integrate the features"``                                              |
|                                                                                                                      |
|     This description will be shown in the setup window above the target directory (see below). Choose a phrase which |
|     is not too long.                                                                                                 |
+----------------------------------------------------------------------------------------------------------------------+
| **defaultPath**                                                                                                      |
|     E.g.: ``"C:\\Data\\MyProject\\"``                                                                                |
|                                                                                                                      |
|     This is the default directory which will be selected by default and is visible in the setup window below the     |
|     **installInstruction**, before the end-use will select their preferred directory. Note, that the backslashes need|
|     to be escaped by an additional backslash (``\\``).                                                               |
+----------------------------------------------------------------------------------------------------------------------+
