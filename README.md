
## oncein bash script

Ensure a command is only run once in N seconds.

### Example

    oncein 30 /usr/sbin/apache2ctl graceful


In this case, it creates a lock file called

    /var/lock/oncein_apache2ctl.lock

