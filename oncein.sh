#!/bin/bash

seconds=$1
shift
cmd=$1
shift

if [ x$seconds == 'x'  ] || [ x$cmd == 'x' ] || [ ! -x $cmd ] ; then
    echo 'Usage: oncein <seconds> <command> [args..]'
    exit 3
fi

timestampfile="/var/lock/oncein_`basename $cmd`.lock"

# check the age of the lockfile before flock touches it
if [ -f $timestampfile ] ; then
    age=$(( $(date +"%s") - $(stat -c "%Y" $timestampfile) ))
else
    age=$seconds
fi

# Get an exclusive lock
exec 9>>$timestampfile
flock 9
{
    # sleep if necessary to make up the correct number of seconds
    if [ $age -lt $seconds ] ; then
        sleep $(($seconds - $age))
    fi

    # Update the timestamp before releasing the lock
    touch $timestampfile

# release the lock      
} 9<&-
exec 9<&-

# run the requested command
exec $cmd $@
