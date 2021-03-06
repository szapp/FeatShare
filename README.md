FeatShare
=========

Share specific features between text-based projects of same origin

![FeatShare](doc/_static/images/icon.png)

While merge-tools generally allow fusing *all* changes from two versions of a project, **FeatShare** integrates only a selected
set of changes (along with creation and deletion of files) into an environment. This is done irrespective of how far
the target project has evolved from the common origin - and that outside of a version control system in form of a light-weight
stand-alone setup.
Its strengths lie in the high customization of configuration and its flexibility of how to integrate the features.

For more information read the documentation avaliable in each [release](../../releases/latest).


**Third-Party Software**

The following third-party software is used.

- **[MPRESS v2.19](http://autohotkey.com/mpress/mpress_web.htm)**, Copyright (C) 2007-2012 *MATCODE Software*, [License](mpress/LICENSE)
- **[AutoHotkey-JSON v2.1.1](http://github.com/cocobelgica/AutoHotkey-JSON)**, 2013-2016 *cocobelgica*, [License](lib/AutoHotkey-JSON/LICENSE)
- **[Class_RichEdit v0.1.05.00](http://github.com/AHK-just-me/Class_RichEdit)**, 2013-2015 *just me*, [License](lib/Class_RichEdit/LICENSE)


**Building**

To compile this project, the most recent version of AutoHotkey (v1.1.24.0) is recommended.
Compile (with v1.1.24.0 Unicode 32-bit) the following files in the indicated order:

 1. ``FeatShare.ahk``*
 1. ``template.ahk``
 1. ``Felper.ahk``*
 1. ``BuildSetup.ahk``*

Afterwards, ``template.exe`` and ``FeatShare.exe`` can be deleted has they are included in ``BuildSetup.exe``.

Files annotated with an asterisk (*) should be compressed with mpress (included in this repository).
