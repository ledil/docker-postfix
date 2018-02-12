#!/bin/bash
trap "service postfix stop" SIGINT
trap "service postfix stop" SIGTERM
trap "service postfix reload" SIGHUP

# start postfix
service postfix start

# lets give postfix some time to start
sleep 5

tail -F /var/log/mail.log /var/log/mail.err
# wait until postfix is dead (triggered by trap)
#while kill -0 "`cat /var/spool/postfix/pid/master.pid`"; do
#  sleep 5
#done
