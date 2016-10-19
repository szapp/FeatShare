.. _tutorial:

.. index:: Tutorial (Quick Start)

Tutorial (Quick Start)
======================

At the start of each setup are of course the features which should be integrated into an existing file structure.

Nevertheless, there is a little more to setup. This is a short outline of what we need to do.

#. :ref:`Create a configuration file <tutorialConfigJson>`
#. :ref:`Select what to integrate <tutorialFeatures>`
#. :ref:`Create anchors <tutorialAnchors>`

Premise
-------

Imagine a programming project in which we want to modify a set of constants.

This project is shared with different parties.
The project turned into many independent projects, all sharing the same base structure, but differing a lot.
Of course, the projects are not compatible anymore and exchanging files is not possible.
Here are parts we want to modify.

path\\to\\file1.cpp

.. code-block:: cpp

    121  ...
    122
    123  // Constants
    124  const int AMPLITUDE          = 93;
    125  const int PHASE              = 94;
    126  const int CUT_OFF            = 95;
    127
    138  ...

The only really certain information we have about were to find the parts are the file it is in and the names of the
constants.

The first though might be to just search and replace the affected parts or replace the lines by line number.
However, take a look how the ``file1.cpp`` looks on a different computer:

.. code-block:: cpp

    243  ...
    244
    245    /* Constants */
    246  const  int AMPLITUDE     = 88;
    247  const int   PHASE = 89;
    248    const   int CUT_OFF  = 90; // TODO: Adjust
    249
    250  ...

First of all, the line numbers are different. The other person seems to have added a lot to the file. Also, and more
importantly, the spelling and white spaces are different, the code is indented, there is a comment at the end of one
line and the values are different. How do we go about this?

Clearly we need to make as little assumptions on the parts we are searching as possible. For that we use
:ref:`regular expressions <regex>`.


.. _tutorialConfigJson:

1. Configuration: config.json
-----------------------------

Before doing anything else, we will first write some general settings for the setup.

All of those settings are set using a file named :ref:`config.json <configjson>`.
Without this file the setup cannot be build.
Therefore, the first thing we need to do now is create a file named ``config.json``.
Let's keep it simple for now and write the following lines to it.
Mind the commas and the brackets.
Indentation is not important but helps for readability.

.. container:: coderef

    | {
    |     :std:term:`"title" <title>`: "My First FeatShare Setup",
    |     :std:term:`"globalHeader" <globalHeader>`: "// The lines of code below were inserted by my FeatShare setup!",
    |     :std:term:`"installInstruction" <installInstruction>`: "Choose the directory in which to integrate the features",
    |     :std:term:`"defaultPath" <defaultPath>`: "C:\\\\Data\\\\MyProject\\\\",
    |     :std:term:`"dryRun" <dryRun>`: true,
    |     :ref:`"features" <config.features>`: {
    |         :std:term:`"filePattern" <features.filePattern>`: ".*\\.feat"
    |     },
    |     :ref:`"anchors" <config.anchors>`: {
    |         "": "^anchors.*\\\\.json$"
    |     }
    | }

There is a lot more that can be set here.
The absolute minimum for a config file is the setting :ref:`"anchors" <config.anchors>`.
For detailed descriptions and explanations see :ref:`config.json <configjson>` or click on the references above.

.. _tutorialFeatures:

2. Features
-----------

Next we need to decide **what** we want to integrate - the **how** comes later.

The *what* will be stored in a feature file.
Each feature has its own file. What exactly defines a feature is up to you.
The name of the feature files are up to you as well as the :std:term:`file extension <features.filePattern>`.
Here we will stick to the default file extension, since we didn't specify otherwise in the
:ref:`configuration <tutorialConfigJson>` and name the feature file ``newFeature.feat``.

The first thing we define in the feature file is the information text.
This text is the description that will be displayed when selecting the feature in the setup before starting the
integration.
Let's assume we want to add two new constants before ``CUT_OFF`` and adjust the indices accordingly::

    ### infoText ###
    This feature adds the FREQ_IN constant.
    ### end ###

The next thing we do is specify what is going to be added.
So let's add the new one like this::

    ### infoText ###
    This feature adds the FREQ_IN constant.
    ### newConstant ###
    FREQ_IN
    ### end ###

.. _tutorialAnchors:

3. Anchors
----------

Once we know what to insert, we need to make sure it's integrated at the right position - now comes the **how**.

The new constants needs to be added between ``PHASE`` and ``CUT_OFF`` with the value of ``CUT_OFF`` while increasing it
for ``CUT_OFF``.
This can be done with only one anchor.
(More sophisticated changes may need multiple anchors.)

As seen above ``file1.cpp`` may vary a lot in appearance.
Since we want to grab a hold of ``CUT_OFF``, we need to create a :ref:`regular expression <regex>` that will match that line.

.. note::
    **Note**: In general it is always helpful to make use of the :ref:`Felper <felper>` to find a suited regular expression.

Here, this regex will match the method signature::

    ^\s*const\s+int\s+CUT_OFF\s+=\s*(\d+)\s*;.*$

With the parentheses around ``\d+`` this regex will create the subpattern ``$1`` for the current value of ``CUT_OFF``.
We will use this to explicitly replace the it.

.. note::
    **Note**: Back-slashes of the regex need to be escaped by an additional backslash (e.g. ``\\``).

.. container:: coderef

    | [
    |     {
    |         :std:term:`"description" <description>`: "Add new constant and increase CUT_OFF",
    |         :std:term:`"path" <path>`: "path\\\\to\\\\file1.cpp",
    |         :std:term:`"regex" <regex>`: {
    |             :std:term:`"needle" <regex.needle>`: "^\\\\s*const\\\\s+int\\\\s+CUT_OFF\\\\s+=\\\\s*(\\\\d+)\\\\s*;.*$",
    |             :std:term:`"flags" <regex.flags>`: {
    |                 :std:term:`"caseSensitive" <regex.flags.caseSensitive>`: false,
    |                 :std:term:`"dotInclNL" <regex.flags.dotInclNL>`: false,
    |                 :std:term:`"multiLine" <regex.flags.multiLine>`: true,
    |                 :std:term:`"ungreedy" <regex.flags.ungreedy>`: false,
    |                 :std:term:`"occurrence" <regex.flags.occurrence>`: 1
    |             }
    |         },
    |         :std:term:`"storeVars" <storeVars>`: {
    |             "max_const": "$1"
    |         },
    |         :ref:`"hook" <anchors.hook>`: {
    |             :std:term:`"start" <hook.start>`: "$0",
    |             :std:term:`"length" <hook.length>`: "$0",
    |             :std:term:`"before" <hook.before>`: true,
    |             :std:term:`"replace" <hook.replace>`: {
    |                 "$1": "{idx}"
    |             }
    |         },
    |         :ref:`"insert" <anchors.insert>`: {
    |             :std:term:`"string" <insert.string>`: "const int {newConst}{ :newConst:19}= {idx};\\n",
    |             :std:term:`"replace" <insert.replace>`: {
    |                 "newConst": "newConstant"
    |             },
    |         },
    |         :std:term:`"setHeader" <setHeader>`: true,
    |         :ref:`"finalReplace" <anchors.finalReplace>`: [
    |             {
    |                 :std:term:`"needle" <finalReplace.needle>`: "idx",
    |                 :std:term:`"replace" <finalReplace.replace>`: "max_const",
    |                 :std:term:`"incr" <finalReplace.incr>`: 1
    |             }
    |         ],
    |         :std:term:`"dependencies" <dependencies>`: [
    |             "newConstant"
    |         ],
    |         :std:term:`"ignoreOnFail" <ignoreOnFail>`: false
    |     }
    | ]


Result
------

.. container:: diffdefault

    .. code-block:: diff

        --- a\path\to\file1.cpp
        +++ b\path\to\file1.cpp
        @@ -123,4 +123,7 @@
         // Constants
         const int AMPLITUDE          = 93;
         const int PHASE              = 94;
        -const int CUT_OFF            = 95;
        +// The lines of code below were inserted by my FeatShare setup!
        +const int FREQ_IN            = 95;
        +const int FREQ_OUT           = 96;
        +const int CUT_OFF            = 97;

.. container:: diffdefault

    .. code-block:: diff

        --- a\path\to\file1.cpp
        +++ b\path\to\file1.cpp
        @@ -245,4 +245,7 @@
           /* Constants */
         const  int AMPLITUDE     = 88;
         const int   PHASE = 89;
        -  const   int CUT_OFF  = 90; // TODO: Adjust
        +// The lines of code below were inserted by my FeatShare setup!
        +const int FREQ_IN            = 90;
        +const int FREQ_OUT           = 91;
        +  const   int CUT_OFF  = 92; // TODO: Adjust
