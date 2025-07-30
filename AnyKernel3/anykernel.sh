### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Something New Kernel
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a51
device.name2=f41
device.name3=m31s
device.name4=m31
device.name5=m21
device.name6=gta4xl
device.name7=gta4xlwifi
device.name8=m21s
supported.versions=13 - 15
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/platform/13520000.ufs/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
split_boot;
ui_print "- Installing SN Kernel";
flash_boot;
## end boot install
cp $AK_FOLDER/init.swappiness.rc /system_root/system/etc/init/
chmod 644 system_root/system/etc/init/init.swappiness.rc
ui_print "Copying swappiness setting script... Done. Finished!"
ui_print "Installation Done"
