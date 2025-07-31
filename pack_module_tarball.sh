#!/usr/bin/env bash
topdir="$(pwd)"
kernel_modules="$(find $topdir/out -mindepth 1 -maxdepth 10 -iname "*.ko" | sed ':a;N;$!ba;s/\n/ /g')"
if [ ! -d modules ]; then
        mkdir -p modules
fi
if [ -z "$kernel_modules" ]; then
	echo "No compiled modules found in $topdir/out"
	exit 1
fi
for m in $kernel_modules; do
        if [ -f $m ]; then
                cp $m $topdir/modules/
        else
                echo "Module $m not found"
        fi
done
cd $topdir/modules
module_tarball="$(echo Samsung-A51-Nethunter-$(date '+%Y%m%d-%H%M')-modules.tgz)"
tar czvf $topdir/out/$module_tarball *
if [ "$?" -eq 0 ]; then
        echo "Module tarball $module_tarball created in $topdir/out"
	cd $topdir
	rm -rf modules
else
        echo "Failed"
fi
