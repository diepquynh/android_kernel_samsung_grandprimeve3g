# Init.d support

export PATH=/sbin:/system/sbin:/system/bin:/system/xbin
chmod -R 755 /system/etc/init.d
busybox run-parts /system/etc/init.d
