#!/usr/bin/env bash

##################
## Copyright notice:
## © 2015 Paschalis Mpeis
## © 2016 Andrew Querol
##################

##################
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
##################

##################
## Dependencies:
## java in $PATH
## *nix based operating system with bash
## Marshmallow/Lollipop ART system image
##################

##################
## Globals
##################

UNPACK=0
PACK=1
mode=-1

ODEX_SYS="$(pwd)/system_odexed"
OUT_DIR="$(pwd)/system_deodexed"
framedir="$ODEX_SYS/framework"

# arch_order only used for packing when chosing what arch odex to use for the dex
arch_order=("x86_64" "x86" "arm64" "arm" "mips64" "mips")
override_arch=""
declare -i lollipop

# Edit this if the link ever goes dead for oat2dex
declare -r DEFAULTOAT2DEXURL="https://raw.githubusercontent.com/testwhat/SmaliEx/master/smaliex-bin/oat2dex.jar"
oat2dex="java -Xmx1024m -jar tools/oat2dex.jar"
SED="$SED"


##################
## Shows the usage text when called incorrectly
##################
function show_usage {
printf "Usage: \n%s unpack <odex-system-directory>\n%s pack [arch]\n" "$0" "$0"
exit
}

##################
## Delete previous files and make a fresh copy of the system files
## So it won't make any modifications to your original copy
##################
function clean_workspace {
printf "\n\n##Cleaning previous stuff\n"
rm -rf "${ODEX_SYS:?}"
rm -rf "${OUT_DIR:?}"

printf "Copying odex Directory: %s\n" "$ODEX_ORIG"
cp -R "$ODEX_ORIG" "$ODEX_SYS"
}

##################
## Determines whether the file given needs to be deodexed
## It gets this info by looking inside the file, searching for classes.dex
## files
## $1 File to check
##################
function needsDeodex {
filedir="$1"

extension=$(getExtension "$filedir")

if [[ -z $extension ]]; then
    return 0
fi

hasDex=$(unzip -Z1 "$filedir$extension" | grep classes.dex)

if [[ $hasDex == "" ]]; then
    return 0
else
    return 1
fi
}

##################
## Check if $(basename "$1").{apk,jar} exists, return either '.apk' or '.jar' on sucess
## $1 The file to check
##################
function getExtension {
if [[ -f "$1.apk" ]] ; then
    echo ".apk"
elif [[ -f "$1.jar" ]] ; then
    echo ".jar"
else
    echo ""
fi
}

##################
## finds the filenames (w/o the extension) of jars that have odex code in framework/oat
## $1 The framework directory
## $2 Boolean Is this directory of the boot classpath?
##################
function getFrameworkFiles {
framedir="$1"
isBootClasspath="$2"

if [ "$isBootClasspath" -eq 1 ]; then
    while IFS= read -r -d '' file; do if [[ $file != *"\-classes"* ]]; then frameworkFiles+=("$(basename "${file%.dex}")"); fi done < <(find "$framedir/$arch/dex" -maxdepth 2 -regex ".*\.\(dex\)" -print0)
else
    if [[ $lollipop -eq 1 ]]; then
        while IFS= read -r -d '' file; do frameworkFiles+=("$(basename "${file%.odex}")"); done < <(find "$framedir/$arch" -maxdepth 2 -regex ".*\.\(odex\)" -print0)
    else
        while IFS= read -r -d '' file; do frameworkFiles+=("$(basename "${file%.odex}")"); done < <(find "$framedir/oat/$arch" -maxdepth 2 -regex ".*\.\(odex\)" -print0)
    fi
fi
}

##################
## Unpack the boot.oat (boot classpath code)
##################
function unpack_bootoat {
printf "\n\n## Unpacking framework %s (boot-classpath)\n" "$arch"
if [ ! -d "$framedir/$arch/odex" ]; then
    $oat2dex boot "$framedir/$arch/boot.oat"
fi
}

##################
## Unpacks the rest of the framework (non-boot)
##################
function unpack_nonboot {
printf "\n\n## Unpacking framework %s (non-boot-classpath)\n" "$arch"
frameworkFiles=()
getFrameworkFiles "$framedir" 0

for frame in "${frameworkFiles[@]}"; do
    if needsDeodex "$framedir/$frame"; then
        if [[ $lollipop -eq 1 ]]; then
            $oat2dex "$framedir/$arch/$frame.odex" "$framedir/$arch/odex"
        else
            $oat2dex "$framedir/oat/$arch/$frame.odex" "$framedir/$arch/odex"
        fi
    fi
done
}

##################
## Generates dex code from oat files for the apks
##
## $1 which applications to unpack? app or priv-app
##################
function unpack_apks {
printf "\n\n## Unpacking APKs (%s)\n" "$(basename "$1")"

find "$1" -type d -maxdepth 1 -print0 | while IFS= read -r -d '' app; do
    for app_arch in "${arch_order[@]}"; do
        if [[ -d "$app/oat/$app_arch" ]] && [[ -d "$framedir/$app_arch/odex" ]]; then
            if needsDeodex "$app/$(basename "$app")"; then
                $oat2dex "$app/oat/$app_arch/$(basename "$app").odex" "$framedir/$app_arch/odex"
            fi
        fi
    done
done
}

##################
## Generates dex code from Lollipop style oat files for the apks
##
## $1 which applications to unpack? app or priv-app
##################
function unpack_apks_lollipop {
printf "\n\n## Unpacking Lollipop APKs (%s)\n" "$(basename "$1")"

find "$1" -type d -maxdepth 1 -print0 | while IFS= read -r -d '' app; do
    for app_arch in "${arch_order[@]}"; do
        if [[ -d "$app/$app_arch" ]] && [[ -d "$framedir/$app_arch/odex" ]]; then
            if needsDeodex "$app/$(basename "$app")"; then
                $oat2dex "$app/$app_arch/$(basename "$app").odex" "$framedir/$app_arch/odex"
            fi
        fi
    done
done
}

##################
## Pack boot and non-boot dex files
##################
function pack_framework {
# Check if this system has the specified arch in it's frameworks
if [[ $lollipop -eq 1 ]] && [[ ! -d "$framedir/$arch" ]]; then
    return
elif [[ ! -d "$framedir/oat/$arch" ]]; then
    return
fi

printf "\n\n## Packing framework %s (non-boot-classpath)\n" "$arch"

frameworkFiles=()
getFrameworkFiles "$framedir" 0

for frame in "${frameworkFiles[@]}"; do
    if needsDeodex "$framedir/$frame"; then
        # Move all class files to apks dir
        if [[ $lollipop -eq 1 ]]; then
            mv "$framedir/$arch/$frame.dex" "$framedir/classes.dex"
        else
            mv "$framedir/oat/$arch/$frame.dex" "$framedir/classes.dex"
        fi

        # multi-dex support (move all extra dex files)
        if [[ $lollipop -eq 1 ]]; then
            find "$framedir/$arch" -name "$frame-classes*.dex" -print0 | while IFS= read -r -d '' classFile; do
                newLoc=$($SED "s|\(.*\)\($arch\)\(/$frame-\)\(.*\)|\1\4|g" <<< "$classFile")
                mv "$classFile" "$newLoc"
            done
        else
            find "$framedir/oat/$arch" -name "$frame-classes*.dex" -print0 | while IFS= read -r -d '' classFile; do
                newLoc=$($SED "s|\(.*\)\(oat/$arch\)\(/$frame-\)\(.*\)|\1\4|g" <<< "$classFile")
                mv "$classFile" "$newLoc"
            done
        fi

        extension=$(getExtension "$framedir/$frame")
        # Pack the classes back in the jar/apk file
        if [[ ($extension == *".apk" || $extension == *".jar") && -f "$framedir/$frame$extension" ]]; then
            printf "Packing %s\n" "$frame$extension"
            find "$framedir" -name "classes*.dex" -print0 | while IFS= read -r -d '' class; do
                (cd "${class%$(basename "$class")}" && zip "$framedir/$frame$extension" "$(basename "$class")")
            done
        fi
        while IFS= read -r -d '' dex; do rm -f "${dex:?}"; done < <(find "$framedir" -type f -name "classes*.dex" -print0)
    fi
done

if [[ ! $lollipop -eq 1 ]]; then
    rm -rf "${framedir:?}/oat"
fi

printf "\n\n## Packing framework %s (boot-classpath)\n" "$arch"
frameworkFiles=()
getFrameworkFiles "$framedir" 1

for frame in "${frameworkFiles[@]}"; do
    if needsDeodex "$framedir/$frame"; then
        # Move all class files to apks dir
        mv "$framedir/$arch/dex/$frame.dex" "$framedir/classes.dex"
        # multi-dex support (move all extra dex files)
        find "$framedir/$arch/dex" -name "$frame-classes*.dex" -print0 | while IFS= read -r -d '' classFile; do
            newLoc=$($SED "s|\(.*\)\($arch/dex\)\(/$frame-\)\(.*\)|\1\4|g" <<< "$classFile")
            mv "$classFile" "$newLoc"
        done

        extension=$(getExtension "$framedir/$frame")
        if [[ ($extension == *".apk" || $extension == *".jar") && -f "$framedir/$frame$extension" ]]; then
            printf "Packing %s\n" "$frame$extension"
            find "$framedir" -name "classes*.dex" -print0 | while IFS= read -r -d '' class; do
                (cd "${class%$(basename "$class")}" && zip "$framedir/$frame$extension" "$(basename "$class")")
            done
        fi
        while IFS= read -r -d '' dex; do rm -f "${dex:?}"; done < <(find "$framedir" -type f -name "classes*.dex" -print0)
    fi
done
}

##################
## Packs the dex code back to the application
##
## $1 which applications to pack: app or priv-app
##################
function pack_apks {
printf "\n\n## Packing APKs %s\n" "($(basename "$1"))"

find "$1" -type d -maxdepth 1 -print0 | while IFS= read -r -d '' app; do
    for app_arch in "${arch_order[@]}"; do
        if ( [[ $lollipop -eq 1 ]] && [[ -d "$app/$app_arch" ]] ) || [[ -d "$app/oat/$app_arch" ]]; then
            if needsDeodex "$app/$(basename "$app")"; then
                printf "Packing %s with %s dex\n" "$(basename "$app")" "$app_arch"

                if [[ $lollipop -eq 1 ]]; then
                    # Move all class files to apks dir
                    mv "$app/$app_arch/$(basename "$app").dex" "$app/classes.dex"

                    # multi-dex support (move all extra dex files)
                    find "$app/$app_arch" -name "$(basename "$app")-classes*.dex" -print0 | while IFS= read -r -d '' classFile; do
                        newLoc=$($SED "s|\(.*\)\($app_arch\)\(/$(basename "$app")-\)\(.*\)|\1\4|g" <<< "$classFile")
                        mv "$classFile" "$newLoc"
                    done
                else
                    # Move all class files to apks dir
                    mv "$app/oat/$app_arch/$(basename "$app").dex" "$app/classes.dex"

                    # multi-dex support (move all extra dex files)
                    find "$app/oat/$app_arch" -name "$(basename "$app")-classes*.dex" -print0 | while IFS= read -r -d '' classFile; do
                        newLoc=$($SED "s|\(.*\)\(oat/$app_arch\)\(/$(basename "$app")-\)\(.*\)|\1\4|g" <<< "$classFile")
                        mv "$classFile" "$newLoc"
                    done
                fi

                # pack classes into the apk and delete them
                find "$app" -name "classes*.dex" -print0 | while IFS= read -r -d '' class; do
                    (cd "${class%$(basename "$class")}" && zip "$app/$(basename "$app").apk" "$(basename "$class")")
                done

                if [[ $lollipop -eq 1 ]]; then
                    # Shellcheck warns about ls -l, but we are using ls -1 to force a single file per line and then counting the lines. This advoids the issue with weird characters and symbols needing to be escaped
                    # shellcheck disable=SC2012
                    while IFS= read -r -d '' dir; do if [[ $(ls -1 "$dir/"*.odex 2>/dev/null | wc -l) -gt 0 ]]; then rm -rf "${dir:?}"; fi done < <(find "$app" -type d -print0)
                fi
                while IFS= read -r -d '' dex; do rm -f "${dex:?}"; done < <(find "$app" -type f -name "classes*.dex" -print0)
            fi
            break
        fi
    done
    if [[ -d "$app/oat" ]]; then
        rm -rf "${app:?}/oat"
    fi
done
}

#################
## Verify that files now have the dex code
## $1 The directory to check
## $2 The maxdepth to search(Should be 1 for framework directories and 2 for app directories)
#################
function verify_deodex {
printf "\n\n## Verifying: %s\n" "$(basename "$1")"

find "$1" -maxdepth "$2" -type f -regex ".*\.\(apk\|jar\)" -print0 | while IFS= read -r -d '' file; do
    extension=$(getExtension "$file")
    fileNoExtension=$($SED 's/\.[^.]*$//' <<< "$file")
    if [[ "$fileNoExtension" != "framework-res" ]] && needsDeodex "$fileNoExtension"; then
        printf "No dex code for: %s\n" "$file" 2>&1
        return 1
    fi
done
return 0
}

#################
## Helper fuction see if we are on Lollipop. Lollipop's ART is weird compared to the final version and requires special handling/
#################
function setup_vars {
if ( [[ -f "$1/build.prop" ]] && ( grep -q "ro.build.version.release=5" "$1/build.prop" ) ) || ( [[ -f "$1/default.prop" ]] && ( grep -q "ro.build.version.release=5" "$1/default.prop" ) ); then
    printf "Detected Lollipop(5.x.x) omitting 'oat' from odex path!\n"
    lollipop=1
fi
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
setup_vars "$ODEX_SYS"

find "$framedir" -type d -print0 | while IFS= read -r -d '' dir; do
    if [[ -f "$dir/boot.oat" ]]; then
        arch=$(basename "$dir")
        unpack_bootoat
        unpack_nonboot
    fi
done

if [[ $lollipop -eq 1 ]]; then
    if [[ -d "$ODEX_SYS/app" ]]; then
        unpack_apks_lollipop "$ODEX_SYS/app"
    fi
    if [[ -d "$ODEX_SYS/priv-app" ]]; then
        unpack_apks_lollipop "$ODEX_SYS/priv-app"
    fi
else
    if [[ -d "$ODEX_SYS/app" ]]; then
        unpack_apks "$ODEX_SYS/app"
    fi
    if [[ -d "$ODEX_SYS/priv-app" ]]; then
        unpack_apks "$ODEX_SYS/priv-app"
    fi
fi
}

##################
##  It packs the system directories
## IMPORTANT: framework has to be packed last, because the odex files from the
## bootclass path are used by the rest of the classpath, and all the apks
##################
function pack {
if [[ ! -d "$ODEX_SYS" ]]; then
    printf "Run unpack first!\n" 2>&1
    show_usage
    exit
fi
setup_vars "$ODEX_SYS"

if [[ ! -z "$override_arch" ]]; then
    # Make the override arch the only arch avaiable
    arch_order=("$override_arch")
fi

if [[ -d "$ODEX_SYS/app" ]]; then
    pack_apks "$ODEX_SYS/app"
fi
if [[ -d "$ODEX_SYS/priv-app" ]]; then
    pack_apks "$ODEX_SYS/priv-app"
fi

packed=0
for arch in "${arch_order[@]}"; do
    if [[ -d "$framedir/$arch" ]]; then
        # Only pack the first one that comes up, all the others are discarded.
        if [[ ! $packed -gt 0 ]]; then pack_framework; packed=1; fi
        rm -rf "${framedir:?}/${arch:?}"
    fi
done
}

##################
## Verify: basically prints out the files that do not contain dex code
## and renames the build directory
##################
function verify {
if ! verify_deodex "$framedir" 1; then printf "Verify Failed: %s" "$framedir!"; exit; fi
if ! verify_deodex "$ODEX_SYS/app" 2; then printf "Verify Failed: %s" "$ODEX_SYS/app!"; exit; fi
if ! verify_deodex "$ODEX_SYS/priv-app" 2; then printf "Verify Failed: %s" "$ODEX_SYS/priv-app!"; exit; fi

mv "$ODEX_SYS" "$OUT_DIR"
printf "Deoxeded system found at: %s" "$OUT_DIR"
}

##################
## Fix: Re-symlink libs and fix permissions on them
## $1 The path of the system directory
##################

function fix_libs {
printf "\n\n## Fixing app libs\nWARNING! This section requires super user access to change permissions to what they would be expected on Android\n"

read -p "Do you want to continue? (Y/n): " -r -n1 -s response
printf "%s\n" "$response" # Silence the regular printing and print the input ourselves(this prevents double newline)
if [[ "$response" ==  "n" ]] || [[ "$response" ==  "N" ]]; then
    exit
fi

SUDO=""
if [[ -z $(which "sudo") ]] && [[ $EUID != 0 ]]; then
    # Shellcheck warns about having a variable name inside of single quotes since single quotes don't expand. However I wanted to literally print the string '$EUID' so ignore the warning
    # shellcheck disable=SC2016
    printf 'ERROR! Not running as root($EUID != 0) and no sudo binary found(which "sudo" returned null)\n' 2>&1
    exit
elif [[ ! -z $(which "sudo") ]] && [[ $EUID != 0 ]]; then
    SUDO='sudo'
fi

archs64=("x86_64" "arm64" "mips64")
archs32=("x86" "arm" "mips")
system_dir="$1"

printf "\n\n## Fixing app libs in (/app)\n"
find "$system_dir/app" -type d -print0 | while IFS= read -r -d '' app; do
    if [[ -d "$system_dir/app/$(basename "$app")/lib" ]]; then
        for arch64 in "${archs64[@]}"; do
            if [[ -d "$system_dir/app/$(basename "$app")/lib/$arch64" ]]; then
                find "$system_dir/app/$(basename "$app")/lib/$arch64" -type f -regex ".*\.\(so\)" -print0 | while IFS= read -r -d '' sharedobject; do
                    if [[ (! -L "$sharedobject") && (-f "$sharedobject")]]; then
                        echo "Fixing $arch64 $sharedobject"
                        $SUDO ln -sf "../app/$(basename "$app")/lib/$arch64/$(basename "$sharedobject")" "$system_dir/lib64/"
                        $SUDO chown 0:0 "$system_dir/lib64/$(basename "$sharedobject")"
                        $SUDO chmod 0644 "$system_dir/lib64/$(basename "$sharedobject")"
                    fi
                done
                break
            fi
        done
        for arch32 in "${archs32[@]}"; do
            if [[ -d "$system_dir/app/$(basename "$app")/lib/$arch32" ]]; then
                find "$system_dir/app/$(basename "$app")/lib/$arch32" -type f -regex ".*\.\(so\)" -print0 | while IFS= read -r -d '' sharedobject; do
                    if [[ (! -L "$sharedobject") && (-f "$sharedobject")]]; then
                        echo "Fixing $arch32 $sharedobject"
                        $SUDO ln -sf "../app/$(basename "$app")/lib/$arch32/$(basename "$sharedobject")" "$system_dir/lib/"
                        $SUDO chown 0:0 "$system_dir/lib/$(basename "$sharedobject")"
                        $SUDO chmod 0644 "$system_dir/lib/$(basename "$sharedobject")"
                    fi
                done
                break
            fi
        done
    fi
done

printf "\n\n## Fixing app libs in (/priv-app)\n"
find "$system_dir/priv-app" -type d -print0 | while IFS= read -r -d '' app; do
    if [[ -d "$system_dir/priv-app/$(basename "$app")/lib" ]]; then
        for arch64 in "${archs64[@]}"; do
            if [[ -d "$system_dir/priv-app/$(basename "$app")/lib/$arch64" ]]; then
                find "$system_dir/priv-app/$(basename "$app")/lib/$arch64" -type f -regex ".*\.\(so\)" -print0 | while IFS= read -r -d '' sharedobject; do
                    if [[ (! -L "$sharedobject") && (-f "$sharedobject")]]; then
                        echo "Fixing $arch64 $sharedobject"
                        mkdir -p "$system_dir/lib64/"
                        $SUDO ln -sf "../priv-app/$(basename "$app")/lib/$arch64/$(basename "$sharedobject")" "$system_dir/lib64/"
                        $SUDO chown 0:0 "$system_dir/lib64/$(basename "$sharedobject")"
                        $SUDO chmod 0644 "$system_dir/lib64/$(basename "$sharedobject")"
                    fi
                done
                break
            fi
        done
        for arch32 in "${archs32[@]}"; do
            if [[ -d "$system_dir/priv-app/$(basename "$app")/lib/$arch32" ]]; then
                find "$system_dir/priv-app/$(basename "$app")/lib/$arch32" -type f -regex ".*\.\(so\)" -print0 | while IFS= read -r -d '' sharedobject; do
                    if [[ (! -L "$sharedobject") && (-f "$sharedobject")]]; then
                        echo "Fixing $arch32 $sharedobject"
                        mkdir -p "$system_dir/lib/"
                        $SUDO ln -sf "../priv-app/$(basename "$app")/lib/$arch32/$(basename "$sharedobject")" "$system_dir/lib/"
                        $SUDO chown 0:0 "$system_dir/lib/$(basename "$sharedobject")"
                        $SUDO chmod 0644 "$system_dir/lib/$(basename "$sharedobject")"
                    fi
                done
                break
            fi
        done
    fi
done
}

##################
## Begin script setup
##################

# Check number of arguments is either one or two
if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
    # Show the proper usage
    show_usage
    exit
fi

# Check the arguments as it relates to the specified command
if [ $# -eq 2 ] && [ "$1" == "unpack" ]; then
    mode=$UNPACK
    ODEX_ORIG="$2"
elif ( [ $# -eq 1 ] || [ $# -eq 2 ] ) && [ "$1" == "pack" ]; then
    if [ $# -eq 2 ]; then
        override_arch="$2"
    fi
    mode=$PACK
else
    # Show the proper usage
    printf "Invalid arguments! Usage:\n" 2>&1
    show_usage
    exit
fi

# Should we use some other sed binary?
if [[ -z "$SED" ]]; then
    # No override found, default to 'sed'
    SED="sed"
fi

# Check for java
if [[ -z "$(which java)" ]] && ( [[ -z "$JAVA_HOME" ]] || [[ ! -e "$JAVA_HOME/bin/java" ]] ); then
    printf "\n\n## java not found in path and either JAVA_HOME is not set or JAVA_HOME/bin/java doesn't exist! ##\n" 2>&1
    exit
fi

# If JAVA_HOME is setup correctly and bin/java exists while no java exists in the PATH change the default oat2dex command
if [[ -z "$(which java)" ]] && ( [[ ! -z "$JAVA_HOME" ]] || [[ -e "$JAVA_HOME/bin/java" ]] ); then
    oat2dex="$JAVA_HOME/bin/java -Xmx1024m -jar tools/oat2dex.jar"
fi

# Do we need to download oat2dex?
if [[ ! -f "tools/oat2dex.jar" ]]; then
    # Prevision to override the download url in case of it going dead
    if [[ -z "$OAT2DEXURL" ]]; then
        OAT2DEXURL="$DEFAULTOAT2DEXURL"
    fi

    printf "\noat2dex.jar not found!\nDownloading copy from %s to %s\n" "$OAT2DEXURL" "$(pwd)/tools"
    mkdir -p "tools"
    # Using curl since almost all *nix operating systems have it. While some *cough* OSX *cough* don't come with it in their base install
    (cd "tools" && curl --remote-name "$OAT2DEXURL")
fi

# Check to make sure download didn't fail
if [[ ! -f "tools/oat2dex.jar" ]]; then
    printf "\n\n## tools/oat2dex.jar not found! Did the automatic download fail? ##\n" 2>&1
    exit
fi

##################
## End script setup
##################

##################
## Main
##################
if [ $mode -eq $UNPACK ]; then
    unpack
elif [ $mode -eq $PACK ]; then
    pack && verify && fix_libs "$OUT_DIR"
fi
