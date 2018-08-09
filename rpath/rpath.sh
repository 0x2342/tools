#!/bin/sh
#
# Identify files which have an DT_RPATH or DT_RUNPATH tag.
# This is particularly interesting in SUID/SGID binaries as it may allow
# hijacking library calls.
#

files=$(find / -type f \( -perm -4000 -o -perm -2000 \) );

for i in $files; do
	rpath=`objdump -p $i 2>/dev/null|grep RPATH`;
	runpath=`objdump -p $i 2>/dev/null grep RUNPATH`;
	if [ "$rpath" ]; then
		echo $i;
		echo "   RPATH: " $rpath;
	fi
	if [ "$runpath" ]; then
		echo $i;
		echo "   RUNPATH: " $runpath;
	fi
done

