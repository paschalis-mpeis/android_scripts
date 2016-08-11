#!/bin/bash

# Script borrowed from winsock@github
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


if [ $# -ne 1 ]; then
  echo "Usage: $0 <system-dir>"
  exit 1
fi

system_dir=$1
fix_libs $1
