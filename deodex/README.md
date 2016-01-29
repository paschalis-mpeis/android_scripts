# Diclaimer
I 've written this small script just because I wanted to get some hooks into the core libraries, using the framework.

I think I have fixed the bugs in this script that caused this, I have not tested on device yet though:
> The script is provided with the waranty that will make your device unusable as most of the Google Apps will be broken.
> 
> However, you can bake a deodex rom, if you follow this steps:
> * after lot of pain and effort, enable usb debugging 
> * force install the android keyboard (so you can write)
> * force install the Android System Webview (so you can see the "Login with Google" activities)
> * force install the Google Play services
> 
> Then, after a reboot, you won't see any more "* has stopped" messages.
> And to make it a proper rom, you will have to put these apps back to the system partition.
> 
> I do not recommend using it.

Thanks @JesusFreke for [smali](https://github.com/JesusFreke/smali), and @testwhat for oat2dex included in [SmaliEx](https://github.com/testwhat/SmaliEx).

# Usage
There are two functionalities. Unpacking the dex code from relevant places
(boot.oat, and odex files). And packing the dex code to the relevant files
(jars and apks).

## Typical workflow
    ./deodexer.sh unpack <system-directory>
    Do smali tinkering (you are responsible for repacking dex).
    ./deodexer.sh pack

## 1 ./deodexer.sh unpack <system-directory>

Give the path to the system directory I.E. `<path to android root>/system`
The directory will be copied to the tool's directory so it wont modify your original copy of the system
It should contain the following files:

• /system
  ◦ /build.prop or default.prop
  ◦ /app
  ◦ /framework
  ◦ /priv-app

## 2 ./deodexer.sh pack [arch]

The arch paramater is optional, if provided it will override the instruction set ordering when there is more than one.
This will force that arch's decompiled odex to be used in repacking. For valid values see here:
https://android.googlesource.com/platform/art/+/master/dex2oat/dex2oat.cc#235

# Dependencies:

* GNU sed
  * OS X: OS X doesn't come with a fully GNU compataible sed install one from homebrew or ports. If you choose not to overwrite the existing sed set the SED environment variable to either the executable name that can be found in your PATH or the fully qualified path to the executable. `SED=gsed && ./deodexer.sh <unpack|pack>
    * [brew install gnu-sed](http://brewformulas.org/GnuSed)
    * [sudo port install gsed](https://trac.macports.org/browser/trunk/dports/textproc/gsed/Portfile)
* Java for oat2dex
* curl if 'tools/oat2dex.jar' is missing
  * Note: If for some reason the [default download url](https://raw.githubusercontent.com/testwhat/SmaliEx/master/smaliex-bin/oat2dex.jar) goes dead you can override it by setting OAT2DEXURL="http://..." && ./deodexer.sh <unpack|pack>
* Lollipop(ART enabled) or later system files
