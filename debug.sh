#!/bin/bash

# Copyright (C) 2012 Paul Bourke <pauldbourke@gmail.com>
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

set -e

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
    -a      Activity to start once installed
    -x      The works, i.e. all of the above (-buira)
    -h      Show this message
EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

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

BUILD_CMD=${BUILD_CMD-"ant debug"}
CLEAN_CMD=${CLEAN_CMD-"ant clean"}
PKG_NAME=${PKG_NAME-"$(grep 'package' AndroidManifest.xml | \
    awk -F= '{ print $2 }' | sed "s/^\([\"']\)\(.*\)\1\$/\2/g")"}
RUN_CMD=${RUN_CMD-"adb shell 'am start -a android.intent.action.MAIN -n \
    $PKG_NAME/.'$ACTIVITY"}
INSTALL_CMD=${INSTALL_CMD-"ant debug install"}
UNINSTALL_CMD=${UNINSTALL_CMD-"adb uninstall $PKG_NAME"}

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
    # As of adt 20 'debug install' also builds. So no need to run this
    # step if we've been given -i
    if [[ ! $INSTALL ]]; then
        eval $BUILD_CMD
    fi
fi

if $UNINSTALL || $THEWORKS; then
    # Dont check uninstall status, it may not apply
    set +e
    eval $UNINSTALL_CMD
    set -e
fi

if $INSTALL || $THEWORKS; then
    eval $INSTALL_CMD
fi

if $RUN || $THEWORKS; then
    eval $RUN_CMD
fi

set +e
