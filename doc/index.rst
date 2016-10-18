
.. include:: global.rst

.. list-table::
   :class: logo
   :widths: 30, 60

   * -  .. image:: /_static/images/icon.png
          :alt:
     -  | **FeatShare v0.1-beta**
        | Copyright |copy| 2016  szapp (http://github.com/szapp)
        | `http://github.com/szapp/FeatShare <http://github.com/szapp/FeatShare>`_

        .. container:: tiny

          Software License: :ref:`GNU General Public License v3.0 <license>`


Welcome to the FeatShare Documentation
======================================

**FeatShare enables sharing specific features between projects of same origin.**

While merge-tools generally allow fusing *all* changes from two versions of a project, **FeatShare** integrates only a
selected set of changes (:ref:`Features <features>`) (along with creation and deletion of files) into an environment.
This is done irrespective of how far the target project has evolved from the common origin - and that outside of a
version control system in form of a light-weight stand-alone setup.
Its strengths lie in the high customization of configuration and its flexibility of how to integrate the features.


**FeatShare** is compartmentalized into different components.

- :ref:`Features <features>`
- :ref:`Anchors <anchors>`
- :ref:`Hooks <hooks>`

This figure illustrates the components of **FeatShare**
-------------------------------------------------------

.. image:: /_static/images/architecture.png
  :align: center
  :alt:

:ref:`Features <features>` can use multiple :ref:`anchors <anchors>` to :ref:`hook <hooks>` into a target file at
certain positions. While anchors may be used by multiple features and across FeatShare setups, features are highly
specific to a single FeatShare setup, since they carry the information which will be integrated.

Instead of relying on line numbers which might differ greatly across the files of end-users, anchors hook files at the
correct positions using :ref:`regular expressions <regex>`. This way, flexible integration even into heavily modified
files is possible.

:ref:`Anchors <anchors>` impose dependencies on :ref:`features <features>` to identify the features that need them.

:ref:`Hooks <hooks>` may be of different length, allowing to modify the hooked file content, or of no length to merely
insert new content. Hooks may also not insert or modify anything at all to allow
:ref:`conditional anchors <conditionalAnchor>`. Communication between :ref:`anchors <anchors>` contributes to that.

.. note::
  **Note:** Begin with the :ref:`Quick Start <tutorial>` to find out more.

Third-Pary Software
-------------------
The following third-party software is used (without adding any modifications).

- `MPRESS v2.19 <http://autohotkey.com/mpress/mpress_web.htm>`_, Copyright |copy| 2007-2012 *MATCODE Software*, `License <http://github.com/szapp/FeatShare/blob/master/mpress/LICENSE>`_
- `AutoHotkey-JSON v2.1.1 <http://github.com/cocobelgica/AutoHotkey-JSON>`_, 2013-2016 *cocobelgica*, `License <http://github.com/szapp/FeatShare/blob/master/lib/AutoHotkey-JSON/LICENSE>`_
- `Class_RichEdit v0.1.05.00 <http://github.com/AHK-just-me/Class_RichEdit>`_, 2013-2015 *just me*, `License <http://github.com/szapp/FeatShare/blob/master/lib/Class_RichEdit/LICENSE>`_


.. Small hack to have toc in CHM side bar but not visible on home page.
.. container:: hidden

    .. toctree::
        :includehidden:

        tutorial
        faq
        config
        felper
        examples
        reference
        license
        anchors
        features

.. |copy| unicode:: U+00A9   .. copyright symbol
