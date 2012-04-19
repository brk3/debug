About
-----
debug.sh is a small script I use to build, manage and deploy my Android
projects from the command line, without Eclipse.

Originally I simply used it to automate a few lines of something like
'ant debug && adb install' but eventually got round to adding some more
options.

I may change the name to something more inspired but am so used at this
stage to running ./debug.sh that it would annoy me to change it!

Usage
-----
Building, re-installing and launching your project is as easy as:

    $ ./debug.sh -xa <Activity>

from the project root.

Commands used in the various steps can be overridden with environment
variables, have a look at the usage message or browse through the script for
more info.
