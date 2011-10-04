#!/bin/bash

# Copyright (C) 2011 Paul Bourke <pauldbourke@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

usage()
{
cat << EOF
usage: debug.sh [-hrxubi] [-a ACTIVITY]

Build and deploy android projects easily. Steps are taken in a logical 
order regardless of ordering of arguments.

OPTIONS:
    -b      Build
    -u      Uninstall
    -i      Install
    -c      Clean
    -r      Run activity
    -x      The works, i.e. all of the above (-buir)
    -a      Activity to start once installed
    -h      Show this message
EOF
}

BUILD=false
RUN=false
INSTALL=false
UNINSTALL=false
THEWORKS=false
CLEAN=false
ACTIVITY=
while getopts "a:chxrbui" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         b)
             BUILD=true
             ;;
         x)
             THEWORKS=true
             ;;
         i)
             INSTALL=true
             ;;
         c)
             CLEAN=true
             ;;
         u)
             UNINSTALL=true
             ;;
         r)
             RUN=true
             ;;
         a)
             ACTIVITY=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

BUILD_CMD=${BUILD_CMD-"ssh dragon32 \"cd sandbox/sarge && ant debug\""}
CLEAN_CMD=${CLEAN_CMD-"ssh dragon32 \"cd sandbox/sarge && ant clean\""}
RUN_CMD=${RUN_CMD-"adb shell 'am start -a android.intent.action.MAIN -n com.bourke.sarge/.'$ACTIVITY"}
INSTALL_CMD=${INSTALL_CMD-"adb install -r /mnt/sandbox-dragon32/sarge/bin/SargeActivity-debug.apk"}
UNINSTALL_CMD=${UNINSTALL_CMD-"adb uninstall com.bourke.sarge"}

if $RUN || $THEWORKS; then
    if [[ -z $ACTIVITY ]]; then
        echo "Requires an activity to be specified (-a)"
        exit 1
    fi
fi

if $CLEAN; then
    eval $CLEAN_CMD
fi

if $BUILD || $THEWORKS; then
    eval $BUILD_CMD
fi

if $UNINSTALL || $THEWORKS; then
    if [[ $? -ne 0 ]]; then
        echo "Previous step exited with $?, not continuing"
        exit 1
    fi
    eval $UNINSTALL_CMD
fi

# Dont check uninstall status, it may not apply
if $INSTALL || $THEWORKS; then
    eval $INSTALL_CMD
fi

if $RUN || $THEWORKS; then
    if [[ -z $ACTIVITY ]]; then
        echo "Missing required option -a"
        usage
        exit 1
    fi
    eval $RUN_CMD
fi

