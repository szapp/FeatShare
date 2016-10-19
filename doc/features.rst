.. _features:

.. index:: Features

Features
========

FeatShare is about integrating certain changes into a target environment.
These changes may be split up into different features.
There is one file per feature, which allows the end-user to select them before integration.

While :ref:`anchors <anchors>` and :ref:`hooks <hooks>` pave the way for integration, features hold the content that is
going to be integrated.
They make use of anchors and their hooks to place their content at the correct position of the target files.
While the structure of feature files is flexibly defined by the :ref:`config <configjson>`, some properties stay the
same across all integration projects.

.. index:: Traits

.. _features.traits:

Traits
------

Features in any project are usually bigger than one line of text in one file.
More likely are several changes in different files of varying complexity.
To accommodate for that, features have **traits**.
Not all features have all traits.
Like the name says the same trait may occur in different features, but might take different shape.

If one feature is red apples, it most likely has a trait called 'color' which would be red for that feature.
Another feature might be green apples.
The green-apples-feature will also have the trait 'color', but it is green in this case.

Traits are references for anchors.
There is an anchor for each trait, although not always the case (some anchors may use the same trait in different
ways).

In the apple example, there is probably an anchor that targets the color trait and incorporates it into the correct file
at the correct position.
If a trait has to modify more than one file or several different lines of text in one file, there might be more than one
anchor that references that trait.

Traits are essentially sets key-value pairs, where key is the trait name (e.g. 'color') and value is the expression of
the trait (e.g. 'red'), or to put it differently, the text to be inserted.

The way traits are represented in a feature file depends on the definitions in the :ref:`config <configjson>`.
However, it should not be necessary to change the default syntax which looks like this.

.. container:: coderef

    | ### trait1 ###
    | text to insert at anchor
    | spanned over multiple lines
    | ### trait2 ###
    | some other text to insert
    | ### end ###

Here the text to be inserted is framed by its trait and the next trait. The traits are indicated by three pound signs on
either side.

The red-apple-feature would look like this. Of course, a feature usually has more than one trait.

.. container:: coderef

    | ### color ###
    | red
    | ### end ###

In the next sections there will be a few special traits.

See alsoe :ref:`anchor patterns <features.anchorPattern>`.

.. note::
    **Note**: Outside of this section, traits may also be more commonly referred to as anchors.
    However, anchors ≠ traits.
    Since most traits are tied to only one anchors, it is more convenient to call them anchors.

Info Text Anchor
----------------

Each feature is selectable by the end-user before integration.
To give more information about, there is a short description for each feature when it is selected.
This description can be set by a specific trait .
The name of this trait may be changed in the :ref:`config <configjson>` with :std:term:`features.infoTextAnchor`.
The default name is ``infoText``.

Taking the apple example, this would look like this.

.. container:: coderef

    | ### infoText ###
    | This feature will integrate a red apple.
    | ### color ###
    | red
    | ### end ###

File Copy Anchor
----------------

Features may not only modify files but also copy files into the target environment.
A list of files to copy can be set by a specific trait.
The name of this trait, as well as the syntax of the file list may be changed in the :ref:`config <configjson>` with
:ref:`features.fileCopyAnchor <features.fileCopyAnchor>`.

The default name is ``copyFiles`` with the following syntax.

.. container:: coderef

    | ### infoText ###
    | This feature will integrate a red apple.
    | ### copyFiles ###
    | local\directory\file.txt|relative\path\in\target\environment\
    | another\file.exe|relative\path\to\destination\
    | ### color ###
    | red
    | ### end ###

Here, the first part is the relative path from the integration setup, while the second part is the destination: a
relative path in the target environment.

.. note::
    **Note**: For security reasons it is not allowed to copy directories.
    All files need to be referenced individually.

File Delete Anchor
------------------

Features may not only modify files but also delete files from the target environment.
A list of files to delete can be set by a specific trait.
The name of this trait, as well as the syntax of the file list may be changed in the :ref:`config <configjson>` with
:ref:`features.fileDeleteAnchor <features.fileDeleteAnchor>`.

The default name is ``deleteFiles`` with the following syntax.

.. container:: coderef

    | ### infoText ###
    | This feature will integrate a red apple.
    | ### copyFiles ###
    | local\directory\file.txt|relative\path\in\target\environment\
    | another\file.exe|relative\path\to\destination\
    | ### deleteFiles ###
    | relative\path\in\target\environment\old_file.txt
    | relative\path\to\destination\old_file.exe
    | ### color ###
    | red
    | ### end ###

Here, the each line is a file to delete represented by a relative path in the target environment.

.. note::
    **Note**: For security reasons it is not allowed to delete directories.
    All files need to be referenced individually.
