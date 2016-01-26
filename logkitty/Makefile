#q=@
CROSS_COMPILE=arm-linux-androideabi-

## Common definitions
CC=$(CROSS_COMPILE)gcc
AS=$(CROSS_COMPILE)as 
AR=$(CROSS_COMPILE)ar

UTIL=logkitty

# Include log library, and make it position independent (requirement by OS)
CFLAGS+= -llog -fPIE -pie

BIN_INSTALL_DIR:=/system/bin/

.PHONY: clean all $(UTIL)
all: clean install
	
install: clean $(UTIL)
	$(q)echo "Installing on android device..."
	$(q)adb root &> /dev/null
	$(q)adb shell su -c "setenforce 0"
	$(q)adb shell su -c "mount -o remount,rw /system"
	$(q)adb shell 'chmod 777 $(BIN_INSTALL_DIR)' && echo "Unlocked $(BIN_INSTALL_DIR)"
	$(q)adb shell 'mkdir -p /sdcard/tmp' 2> /dev/null
	$(q)adb push $(UTIL) /sdcard/tmp/$(UTIL) 2> /dev/null
	$(q)adb shell su -c "mv /sdcard/tmp/$(UTIL) $(BIN_INSTALL_DIR)/$(UTIL)"
	$(q)adb shell su -c "chown root:root $(BIN_INSTALL_DIR)/$(UTIL)"
	$(q)adb shell su -c "chmod 755 $(BIN_INSTALL_DIR)/$(UTIL)"
uninstall:
	$(q)echo "Uninstalling from android device..."
	$(q)adb root &> /dev/null
	$(q)adb shell 'mount -o remount,rw /system' && echo "Remounted /system/ as RW." 2> /dev/null
	$(q)adb shell 'chmod 777 $(BIN_INSTALL_DIR)' && echo "Unlocked $(BIN_INSTALL_DIR)"
	$(q)adb shell rm -f $(BIN_INSTALL_DIR)/$(UTIL)
$(UTIL):
	$(q)$(CC) $(CFLAGS) $(UTIL).c -o $@
clean:
	$(q)rm -rf $(UTIL)
