From ubuntu:xenial
MAINTAINER Leonardo Di Lella

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Start editing
# Install package here for cache
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools dovecot-core dovecot-imapd dovecot-lmtpd dovecot-managesieved dovecot-pop3d dovecot-sieve rsyslog

# Add files
ADD assets/install.sh /opt/install.sh

# Configures Dovecot
# Configures Dovecot
COPY target/dovecot/auth-passwdfile.inc target/dovecot/??-*.conf /etc/dovecot/conf.d/
RUN sed -i -e 's/include_try \/usr\/share\/dovecot\/protocols\.d/include_try \/etc\/dovecot\/protocols\.d/g' /etc/dovecot/dovecot.conf && \
  sed -i -e 's/#mail_plugins = \$mail_plugins/mail_plugins = \$mail_plugins sieve/g' /etc/dovecot/conf.d/15-lda.conf && \
  sed -i -e 's/^.*lda_mailbox_autocreate.*/lda_mailbox_autocreate = yes/g' /etc/dovecot/conf.d/15-lda.conf && \
  sed -i -e 's/^.*lda_mailbox_autosubscribe.*/lda_mailbox_autosubscribe = yes/g' /etc/dovecot/conf.d/15-lda.conf && \
  sed -i -e 's/^.*postmaster_address.*/postmaster_address = '${POSTMASTER_ADDRESS:="postmaster@domain.com"}'/g' /etc/dovecot/conf.d/15-lda.conf && \
  sed -i 's/#imap_idle_notify_interval = 2 mins/imap_idle_notify_interval = 29 mins/' /etc/dovecot/conf.d/20-imap.conf && \
  # stretch-backport of dovecot needs this folder
  mkdir /etc/dovecot/ssl && \
  chmod 755 /etc/dovecot/ssl  && \
  cd /usr/share/dovecot && \
  mkdir /usr/lib/dovecot/sieve-pipe && \
  chmod 755 /usr/lib/dovecot/sieve-pipe  && \
  mkdir /usr/lib/dovecot/sieve-filter && \
  chmod 755 /usr/lib/dovecot/sieve-filter

# Workaround for log error
# https://bugs.launchpad.net/ubuntu/+source/rsyslog/+bug/830046
RUN rm -rf /etc/rsyslog.d/50-default.conf

# TODO: Disable imklog for now, re-enable it later! Will be important to debug OOM
ADD target/rsyslog.conf /etc/rsyslog.conf

# Run
ADD target/postfix.sh /opt/postfix.sh
RUN chmod +x /opt/postfix.sh
CMD /opt/install.sh;/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

EXPOSE 25 587 143 465 993 110 995 4190
