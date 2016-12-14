#!/system/bin/sh
# Init.d support

export PATH=/sbin:/system/sbin:/system/bin:/system/xbin
chmod -R 755 /system/etc/init.d
for i in /system/etc/init.d/*; do
	$i;
done
