.. _tutorial:

.. index:: Tutorial (Quick Start)

Tutorial (Quick Start)
======================

At the start of each setup are of course the features which should be integrated into an existing file structure.

Nevertheless, there is a little more to setup. This is a short outline of what we need to do.

#. :ref:`Create a configuration file <tutorial.configJson>`
#. :ref:`Select what to integrate (Create features) <tutorial.features>`
#. :ref:`Define how to integrate (Create anchors) <tutorial.anchors>`
#. :ref:`Build a setup <tutorial.buildSetup>`

.. _tutorial.premise:

Premise
-------

Imagine a programming project in which we want to modify a set of constants.

This project is shared with different parties.
The project turned into many independent projects, all sharing the same underlying structure, but deviating a lot.
Of course, the projects are not compatible anymore and exchanging files is not possible.
Here is the part we want to modify.

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

The only really certain information we have about where to find the part is the file it is in and the names of the
constants.

A first thought might be to just search and replace the affected parts or replace them by line number.
However, take a look at how the ``file1.cpp`` looks on a different computer:

.. code-block:: cpp

    243  ...
    244
    245    /* Constants */
    246  const  int AMPLITUDE     = 88;
    247  const int   PHASE = 89;
    248    const   int CUT_OFF  = 90; // TODO: Adjust
    249
    250  ...

First of all, the line numbers are different.
The other person seems to have added a lot to the file.
Also, and more importantly, the spelling and white spaces are different, the code is indented, there is a comment at the
end of one line and the values are different.
How do we go about this?

Clearly we need to make as little assumptions on the parts we are searching as possible.
For that we will use :ref:`regular expressions <regex>`.


.. _tutorial.configJson:

1. Configuration: config.json
-----------------------------

Before doing anything else, we will first write some general settings for the setup.

All of those settings are set using a file named :ref:`config.json <configjson>`.
Without this file the setup cannot be build.
Therefore, the first thing we need to do now is create a file named ``config.json``.
Let's keep it simple for now and write the following lines to it.

The file is written in `JSON format <http://www.json.org/>`_.
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
    |         :std:term:`"filePattern" <features.filePattern>`: ".*\\\\.feat"
    |     },
    |     :ref:`"anchors" <config.anchors>`: {
    |         "": "^anchors.*\\\\.json$"
    |     }
    | }

There is a lot more that can be set here.
The absolute minimum for a config file is the setting :ref:`anchors <config.anchors>`.
For detailed descriptions and explanations see :ref:`config.json <configjson>` or click on the references above.

.. _tutorial.features:

2. Features
-----------

Next we need to decide **what** we want to integrate - the **how** comes later.

The *what* will be stored in a feature file.
Each feature has its own file.
What exactly defines a feature is up to you.
Let's add two new constants, for each of which we will create their own feature (file).
The name of the feature files are also up to you, as well as the :std:term:`file extension <features.filePattern>`.
Here we will stick to the file extension :ref:`defined above <tutorial.configJson>` and name the feature files
``newFeature1.feat`` and ``newFeature2.feat``.

The first thing we define in the feature files is the information text.
This text is the description that will be displayed when selecting the feature in the setup before starting the
integration.
Let's assume we want to add two new constants before ``CUT_OFF`` and adjust the indices accordingly.

``newFeature1.feat``::

    ### infoText ###
    This feature adds the FREQ_IN constant.
    ### end ###

``newFeature2.feat``::

    ### infoText ###
    This feature adds the FREQ_OUT constant.
    ### end ###

The next thing we do is specify what is going to be added.
Here it is only one addition, but features usually consist of a lot of characteristics, here referred to as
:ref:`traits <features.traits>`.
Since we want to increment the values, we only need to add their names as traits and no values.
We will get the values from the target file.

``newFeature1.feat``::

    ### infoText ###
    This feature adds the FREQ_IN constant.
    ### newConstant ###
    FREQ_IN
    ### end ###

``newFeature2.feat``::

    ### infoText ###
    This feature adds the FREQ_OUT constant.
    ### newConstant ###
    FREQ_OUT
    ### end ###

.. note::
    **Note**: For more information on features, see :ref:`features <features>`.

.. _tutorial.anchors:

3. Anchor
---------

Once we know what to insert, we need to make sure it's integrated at the right position - now comes the **how**.

The new constants needs to be added between ``PHASE`` and ``CUT_OFF`` with the value of ``CUT_OFF`` while increasing it
for ``CUT_OFF``.
This can be done with only one anchor.
(More sophisticated changes usually need multiple anchors.)

As seen above ``file1.cpp`` may vary a lot in appearance.
Since we want to grab a hold of ``CUT_OFF``, we need to create a :ref:`regular expression <regex>` that will match that
line for hopefully any modification it might have undergone.

.. note::
    **Note**: In general it is always helpful to make use of the :ref:`Felper <felper>` to find a suited regular
    expression.

Here, this regex will match in both cases::

    ^\s*const\s+int\s+CUT_OFF\s+=\s*(\d+)\s*;.*$

With the parentheses around ``\d+`` this regex will create the subpattern ``$1`` for the current value of ``CUT_OFF``.
We will use this to explicitly increment and replace it.

.. note::
    **Note**: Back-slashes of the regex need to be escaped by an additional backslash (e.g. ``\\``). See below.

Around this regex we write an anchor specification, which will tell FeatShare how to add the features that need this
anchor.
In the :ref:`configuration file above <tutorial.configJson>` we specified, that the anchors would be in a file called
``anchors.json``.
The anchor has the same structure (JSON) as the :ref:`configuration file above <tutorial.configJson>` but has a lot of
different properties.
Some of these properties are not listed in this example.

.. note::
    **Note**: See :ref:`anchors <anchors>` for more details.

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

The ``regex`` block finds where to add/modify content, the ``hook`` block specifies the exact position and modifies the
regex matched phrase, the ``insert`` block adds the new content and ``storeVars`` saves the current value of ``CUT_OFF``
to be used in ``finalReplace`` where the values will be applied to the newly added constants.

.. note::
    **Note**: Each property above is a link leading to a more thorough explanation what it does.

.. note::
    **Note**: For more information on anchors, see :ref:`anchors <anchors>`.

.. _tutorial.buildSetup:

4. Building a Setup
-------------------

This is all there is to it.
Now we create a setup from the created files.

.. note::
    **Note**: For details on how to build a setup from these three types of files (configuration, anchors, features) see
    :ref:`Build Setup <buildSetup>`.

Result
------

Since we set the option :std:term:`dryRun`, the setup will only perform a test run and not actually make any changes to
the target environment.
To "arm" the setup remove the dryRun option in the configuration.
You may replace it with the :std:term:`diffGUI` option, which will still enable the preview of the changes before
applying them.
This is very end-user friendly as they can see what the setup will do and can still decide to back out.

Note, however, FeatShare always creates a back-up of all to be modified files in a designated back-up directory.
The actions of FeatShare can always be reverted, as this directory will be kept after the setup is finished.
If FeatShare notices that something is going to go wrong or went wrong in the process of applying the changes, it will
revert all changes and leave the files in their original state.

The output of setting either :std:term:`dryRun` or :std:term:`diffGUI` will be a diff utility type of text looking like
this.
The first part is the output when performing on the well-formatted ``file1.cpp`` the second output is for the
malformatted version of the file (see :ref:`above <tutorial.premise>`).

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
