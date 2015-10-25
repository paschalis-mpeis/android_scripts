#!/bin/bash

##########
# Not responsible for whatever happens to your laptop or phone.
# It will (at least) break all Google Apps.
# Paschalis Mpeis, 2015
##########

##########
## Usage: odex-system-dir
## Give the directory that contains the odexed system
## The directory will be copied to the tool's directory
## so it wont modify your original copy of the system
## e.g.
## • ~/myodex
##          ◦ /system
##                      ◦ /app
##                      ◦ /framework
##                      ◦ /priv-app
##
##########

##########
## Dependencies:
# I have used this with the following configuration:
# java version "1.8.0_51" for latest oat2dex
# OSX Yosemite
# macports: p7zip
# Marshmallow factory images for N6
#
##########
##
## User Variables
ARCH="arm"
API=23
# you might want to change this
RM="safe-rm" # regular rm?
########## end-of-user-vars



######################################
UNPACK=0
PACK=1
mode=-1



if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
    show_usage
fi


if [ $# -eq 2 ] && [ $1 == "unpack" ]; then
    mode=$UNPACK
    ODEX_ORIG=$2
elif [ $# -eq 1 ] && [ $1 == "pack" ]; then
    mode=$PACK
else
    show_usage
fi

ODEX_SYS=$(pwd)/"system_odexed"
OUT_DIR=$(pwd)/"system_deodexed"
romdir=$(pwd)
framedir=$ODEX_SYS/framework
tools=$(pwd)/tools
# TODO delete this directory..
logs=$(pwd)/tools/logs
arch=$ARCH
api=$API
oat2dex="java -Xmx1024m -jar tools/oat2dex.jar"


##########
## 
##########
function show_usage {
echo "Usage:"
echo "$0 unpack odex-system-directory"
echo "$0 pack"
exit
}
##########
## Okay, I wont implement this.
##########
function verify_input {
echo "ls $ODEX_ORIG"
folders=$(ls $ODEX_ORIG | wc -w)

if [ $folders -eq 1 ]; then
    echo "implement this.."
elif [ $folders -eq 3 ]; then
    echo "also this.."
else
    echo "Something is wrong with input odexed system"
fi
}



##########
## Delete previous files and make a fresh copy of the system files
## So it won't make any modifications to your original copy
##########
function clean_workspace {
echo "Cleaning previous stuff"
$RM -rf $ODEX_SYS
$RM -rf $OUT_DIR
$RM -rf $logs/*.log

echo "Copying odex Directory: $ODEX_ORIG"
cp -R $ODEX_ORIG/system $ODEX_SYS
}



##########
# Determines whether the file given needs to be deodexed
# It gets this info by looking inside the file, searching for classes.dex
# files
##########
function needsDeodex {
filedir=$1

extension=$(getExtension $filedir)
hasDex=$(7za l $filedir$extension | grep classes.dex)

if [[ $hasDex == "" ]]; then
    return 0
else
    return 1
fi
}



##########
## Get the .jar or .apk extension
##########
function getExtension {
filedir=$1

if [[ -f "$filedir.apk" ]] ; then
    echo ".apk"
elif [[ -f "$filedir.jar" ]] ; then
    echo ".jar"
else
    echo ""
fi
}



##########
# finds the filenames (w/o the extension) of jars that have odex code in framework/oat
##########
function getFrameworkFiles {
framedir=$1
isBootClasspath=$2

if [ $isBootClasspath -eq 1 ]; then
    echo $(ls $framedir/$arch/dex | grep .dex | rev | cut -c 5- | rev | grep -v "\-classes")
else
    echo $(ls $framedir/oat/$arch | grep .odex | rev | cut -c 6- | rev)
fi
}



##########
## Unpack the boot.oat (boot classpath code)
##########
function unpack_bootoat {
echo -e "\n\n## Unpacking framework (boot-classpath)"
if [ ! -d "$framedir/$arch/odex" ]; then
    # >> $logs/main.log"
    # use  jdk 1.8 on mac
    $oat2dex boot $framedir/$arch/boot.oat
fi

# TODO implement 64bit
if [[ ! $arch2 = "" ]]; then
    echo "64bit?? not supported"
    if [ ! -d "$framedir/$arch2/odex" ]; then
        $oat2dex boot $framedir/$arch2/boot.oat
    fi
fi
}



##########
## Unpacks the rest of the framework (non-boot)
##########
function unpack_nonboot {
echo -e "\n\n## Unpacking framework (non-boot-classpath)"

frameworkFiles=$(getFrameworkFiles $framedir 0)

for frame in $frameworkFiles;
do
    if needsDeodex $framedir/$frame; then
        $oat2dex $framedir/oat/$arch/$frame.odex $framedir/$arch/odex
    fi
done
}



##########
## Generates dex code from oat files for the apks
##
## @appType which applications to unpack? app or priv-app
##########
function unpack_apks {
appdir=$1
apps=$(ls $appdir);

for app in $apps;
do
    if [ -d "$appdir/$app/oat/$arch" ]; then	
        if needsDeodex $appdir/$app/$app; then
            $oat2dex $appdir/$app/oat/$arch/$app.odex $framedir/$arch/odex
        fi
    fi
done
}



##########
## Pack boot and non-boot dex files
##########
function pack_framework {
echo -e "\n\n## Packing framework (non-boot-classpath)"

frameworkFiles=$(getFrameworkFiles $framedir 0)
for frame in $frameworkFiles;
do
    if needsDeodex $framedir/$frame; then

        # Move all class files to apks dir
        mv $framedir/oat/$arch/$frame.dex $framedir/classes.dex
        # multi-dex support (move all extra dex files)
        for classFile in $(find $framedir/oat/$arch -name "$frame-classes*.dex");
        do
            newLoc=$(sed "s|\(.*\)\(oat/$arch\)\(/$frame-\)\(.*\)|\1\4|g" <<< $classFile)
            mv $classFile $newLoc
        done

        extension=$(getExtension $framedir/$frame)
        # Pack the classes back in the jar/apk file
        if [[  -f $framedir/$frame$extension ]]; then
            echo "Packing $frame$extension"
            7za u -tzip $framedir/$frame$extension $framedir/classes*.dex
        fi
        $RM -f $framedir/classes*.dex
    fi
done
$RM -rf "$framedir/oat"

echo -e "\n\n## Packing framework (boot-classpath)"
frameworkFiles=$(getFrameworkFiles $framedir 1)
for frame in $frameworkFiles;
do

    if needsDeodex $framedir/$frame; then

        # Move all class files to apks dir
        mv $framedir/$arch/dex/$frame.dex $framedir/classes.dex
        # multi-dex support (move all extra dex files)
        for classFile in $(find $framedir/$arch/dex -name "$frame-classes*.dex");
        do
            newLoc=$(sed "s|\(.*\)\($arch/dex\)\(/$frame-\)\(.*\)|\1\4|g" <<< $classFile)
            mv $classFile $newLoc
        done

        extension=$(getExtension $framedir/$frame)
        if [[  -f $framedir/$frame$extension ]]; then
            echo "Packing $frame$extension"
            7za u -tzip $framedir/$frame$extension $framedir/classes*.dex
        fi
        $RM -f $framedir/classes*.dex
    fi
done
$RM -rf "$framedir/$arch"
}



##########
## Packs the dex code back to the application
##
## @appdir which applications to pack: app or priv-app
##########
function pack_apks {
appdir=$1
apps=$(ls $appdir);

for app in $apps;
do
    if [ -d "$appdir/$app/oat/$arch" ]; then	

        if needsDeodex $appdir/$app/$app; then

            # Move all class files to apks dir
            mv $appdir/$app/oat/$arch/$app.dex $appdir/$app/classes.dex

            # multi-dex support (move all extra dex files)
            for classFile in $(find $appdir/$app/oat/$arch -name "$app-classes*.dex");
            do
                newLoc=$(sed "s|\(.*\)\(oat/$arch\)\(/$app-\)\(.*\)|\1\4|g" <<< $classFile)
                mv $classFile $newLoc
            done

            # pack classes into the apk and delete them
            7za u -tzip $appdir/$app/$app.apk $appdir/$app/classes*.dex
            $RM -rf $appdir/$app/oat
            $RM -rf $appdir/$app/classes*.dex
        fi
    fi
done
}



#################
## Verify that files now have the dex code 
#################
function verify_deodex {
area=$1
files=$2

echo -e "\n\nVerifying: $area"
for file in $files;
do
    extension=$(getExtension $file)
    if [[ -f "$file" ]] ; then
        fileNoExtension=$(sed 's/\.[^.]*$//' <<< $file)
        if needsDeodex $fileNoExtension; then
            # FIXME ignore framework res apk
            echo "No dex code for: $file"
        fi
    else
        # FIXME here usually go folders.
        echo "not file $file"
    fi
done
}



##################
## It unpacks the system directories
## app
## framework
## app-priv
##
## It copies the input system directory given, to a new one
## just not to mess with the original files
##################
function unpack {
clean_workspace

unpack_bootoat
unpack_nonboot
unpack_apks "$ODEX_SYS/app"
unpack_apks "$ODEX_SYS/priv-app"
}



##################
##  It packs the system directories
## IMPORTANT: framework has to be packed last, because the odex files from the
## bootclass path are used by the rest of the classpath, and all the apks
##################
function pack {
pack_apks "$ODEX_SYS/app"
pack_apks "$ODEX_SYS/priv-app"
pack_framework # pack framework at the end, as it is needed (boot-classpath)
}



##################
## Verify: basically prints out the files that do not contain dex code
## and renames the build directory
##################
function verify {
verify_deodex "framework" "$(find $framedir -maxdepth 1 -type f)"
verify_deodex "app" "$(find $ODEX_SYS/app -maxdepth 2 -type f)"
verify_deodex "priv-app" "$(find $ODEX_SYS/priv-app -maxdepth 2 -type f)"

mv $ODEX_SYS $OUT_DIR
echo "Deoxeded system found at: $OUT_DIR"
}



##################
## Main
##################
if [ $mode -eq $UNPACK ]; then
    unpack
elif [ $mode -eq $PACK ]; then
    pack && verify
fi
