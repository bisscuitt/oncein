#!/bin/bash

seconds=$1
shift
cmd=`which $1`
shift

if [ x$seconds == 'x'  ] || [ x$cmd == 'x' ] || [ ! -x $cmd ] ; then
	echo 'Usage: oncein <seconds> <command> [args..]'
	exit 3
fi

timestampfile="/var/lock/oncein_`basename $cmd`.lock"

# Get an exclusive lock
exec 9>>$timestampfile
flock 9
{
	# seconds since lockfile was last touched
	age=$(( $(date +"%s") - $(stat -c "%Y" $timestampfile) ))

	# sleep if necessary to make up the correct number of seconds
	if [ $age -lt $seconds ] ; then
		sleep $(($seconds - $age))
	fi
	
	# we're done sleeping. update the timestamp before releasing the lock
	touch $timestampfile

# release the lock		
} 9<&-
exec 9<&-

# run the requested command
exec $cmd $@
