# Diclaimer
I 've written this small script just because I wanted to get some hooks into the core libraries, using the framework.
The script is provided with the waranty that will make your device unusable as most of the Google Apps will be broken.

However, you can bake a deodex rom, if you follow this steps:
* after lot of pain and effort, enable usb debugging 
* force install the android keyboard (so you can write)
* force install the Android System Webview (so you can see the "Login with Google" activities)
* force install the Google Play services

Then, after a reboot, you won't see any more "* has stopped" messages.
And to make it a proper rom, you will have to put these apps back to the system partition.

I do not recommend using it.

Thanks @JesusFreke for smali, and @testwhat for getting dex from oat.

# Usage:
There are two functionalities. Unpacking the dex code from relevant places
(boot.oat, and odex files). And packing the dex code to the relevant files
(jars and apks).

## Its itended usage:
Unpack.
Do smali tinkering (you are responsible for repacking dex).
Repack.

## 1 ./deodexer unpack odex-system-directory

 Give the directory that contains the odexed system
 The directory will be copied to the tool's directory
 so it wont modify your original copy of the system
 It should have the following format:
 • ~/myodexed_system
          ◦ /system
                      ◦ /app
                      ◦ /framework
                      ◦ /priv-app

(yes, app framework and priv-app are necessary)

## 2 ./deodexer pack

# Dependencies:

 ## I have used this with the following configuration:

 ### java version "1.8.0_51" for latest oat2dex
 (1.7 the oat2dex complains on OSX)
 ### macports: p7zip gsed
 ### OSX Yosemite
 ### Marshmallow factory images for N6

 Theoretically it could work on other Unixes, and other 32bit Nexus phones that run Marshmallow.
 I have NOT tested it though.
