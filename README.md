# bind9 with dlz (dynamically loadable zones) in Debian10

This document is description ow to set up auth/cache dns server on debian10, bind 9.11.x with dlz and Mysql backend plus snort and fail2ban. Zone transfer is achieved by standard MySQL GTID replication .

Theoretical situation for this example as follow:

Company dev.null has got domain dev.null registered and two subdomains *sys.dev.null* in 192.168.11.0/24 - for internal communication and *mysql.dev.null* specifically separated network for mysql communication in 192.168.12.0/24.

The two subdomains can not be queried from outside of company as contains information about internal infrastructure, therefore bind "views" has been configured internal/external. Also server can act as caching dns but only for specific/trusted ip addresses.

As an addition basic ips/ids has been setup based on snort and fail2ban.

*In this example dnssec is not used or compiled.*

# OS prep

    apt update; apt upgrade -y

**basic packages/utils install:**

    apt install dnsutils build-essential wget curl net-tools fping nmap ufw

**firewll config**

    ufw allow from {your_ip_address}
    ufw enable

allow dns traffic and switch off logging (unless you want to)

    ufw allow 53/udp
    ufw logging off

# MySQL install

    wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb
    apt install ./mysql-apt-config_0.8.13-1_all.deb
    dpkg-reconfigure mysql-apt-config

choose version you want (in the example 5.7)

    apt update; apt upgrade
    apt install mysql-community-server apt install mysql-community-client libmysqld-dev libmysqlclient-dev

default installation is not using GTID so scrap it

    systemctl stop mysql

then cleanup

    rm -rf /var/lib/mysql/*

edit /etc/mysql/my.cnf

    !includedir /etc/mysql/conf.d/
    !includedir /etc/mysql/mysql.conf.d/

copy *mysqld.cnf* into */etc/mysql/mysql.conf.d/*

initialize empty db:

    mysqld --initialize

change files ownership

    chown -R mysql:mysql /var/lib/mysql

get temp passwd:

    grep pass /var/log/mysql/error.log 
    2021-06-18T16:37:53.386622Z 1 [Note] A temporary password is generated for root@localhost: qHWy.WcO&1vt

login to mysql and change default root pass:

    alter user root@localhost identified by 'S3cureP##swd';
    flush privileges;

check if GTID is on

    mysql> show global variables like '%gtid%';
    +----------------------------------+--------------------------------------------+
    | Variable_name                    | Value                                      |
    +----------------------------------+--------------------------------------------+
    | binlog_gtid_simple_recovery      | ON                                         |
    | enforce_gtid_consistency         | ON                                         |
    | gtid_executed                    | 7abf04e0-d050-11eb-9b09-42077e7fca18:1-182 |
    | gtid_executed_compression_period | 1000                                       |
    | gtid_mode                        | ON                                         |
    | gtid_owned                       |                                            |
    | gtid_purged                      |                                            |
    | session_track_gtids              | OFF                                        |
    +----------------------------------+--------------------------------------------+


**create MySQL structure**

create database

    mysql> create database dns_database

create tables

    mysql> CREATE TABLE `dns_records` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `zone` varchar(255) DEFAULT NULL,
    `host` varchar(255) DEFAULT NULL,
    `type` varchar(255) DEFAULT NULL,
    `data` varchar(255) NOT NULL DEFAULT '',
    `ttl` int(11) DEFAULT NULL,
    `mx_priority` varchar(255) DEFAULT NULL,
    `refresh` int(11) DEFAULT NULL,
    `retry` int(11) DEFAULT NULL,
    `expire` int(11) DEFAULT NULL,
    `minimum` int(11) DEFAULT NULL,
    `serial` bigint(20) DEFAULT NULL,
    `resp_person` varchar(255) DEFAULT NULL,
    `primary_ns` varchar(255) DEFAULT NULL,
    `created_at` datetime DEFAULT NULL,
    `create_id` varchar(255) DEFAULT NULL,
    `updated_at` datetime DEFAULT NULL,
    `update_id` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `zone_index` (`zone`),
    KEY `type_index` (`type`(8)),
    KEY `host_index` (`host`(10))
    ) ENGINE=MyISAM AUTO_INCREMENT=8562 DEFAULT CHARSET=latin1

*this one is not actually needed as to for transfer zones we'll using mysql replication.*

    mysql> CREATE TABLE `xfr_table` (
    `zone` varchar(255) NOT NULL,
    `client` varchar(255) NOT NULL,
    KEY `zone` (`zone`),
    KEY `client` (`client`),
    KEY `zone_client_index` (`zone`(30),`client`(30))
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8

add users

    mysql> GRANT SELECT, USAGE ON dns_database.* TO 'binduser'@'localhost' IDENTIFIED BY 'bind333##rr';
    mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.2.2' IDENTIFIED BY 'R3p#R3pl';
    mysql> flush privileges;


# bind install

[https://ftp.isc.org/isc/bind9/cur/9.11/](https://ftp.isc.org/isc/bind9/cur/9.11/)

    wget https://ftp.isc.org/isc/bind9/cur/9.11/bind-9.11.33.tar.gz

    {
    export CPPFLAGS="-I/usr/lib/x86_64-linux-gnu $CPPFLAGS";
    export LDFLAGS="-L/usr/lib/x86_64-linux-gnu $LDFLAGS";
    export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu";
    }

configure

    ./configure --prefix=/usr/local/bind --without-openssl --with-dlz-mysql=yes --with-make-clean --without-python

check for errors and make:

    make && make install

create directiories

    {
    groupadd -r -g 250 named ;
    useradd -r -u 250 -s /bin/nologin -d /usr/local/named -g named named ;
    mkdir /var/cache/bind ;
    chown named:named /var/cache/bind ;
    mkdir /var/log/bind/ ;
    chown named:named /var/log/bind/ ;
    mkdir /usr/local/bind/var/run/named ;
    chown named:named /usr/local/bind/var/run/named ;
    chown named:named /usr/local/bind ;
    mkdir /usr/local/bind/var/named ;
    chown named:named /usr/local/bind/var/named ;
    mkdir /etc/named ;
    ln -s /usr/local/bind/etc/named.conf /etc/named/named.conf ;
    }


see example [named.conf](https://github.com/adambialy/bind9_dlz/blob/main/named.conf)


# Setup systemd

create [/etc/systemd/system/named.service](https://github.com/adambialy/bind9_dlz/blob/main/named.service)

reload systemctl, start and check if bind is running:

    systemctl daemon-reload

    systemctl start named.service

    systemctl status named.service

note:

two scripts are optional:

    ExecStartPost=-/bin/bash -c "/usr/bin/sysadminmsg $(hostname) dns start"
    ExecStopPost=-/bin/bash -c "/usr/bin/sysadminmsg $(hostname) dns stop"

They're added to send notification to sysadmin when daemon is stopped or started.

You have to create your own */usr/bin/sysadminmsg* scripts mail, slack, whatever...

Bear in mind that you have to control somehow timeout on the script.


# Setup snort

    apt install snort

    wget https://rules.emergingthreats.net/open/snort-2.9.0/rules/emerging-dns.rules

edit snort.conf and remove (if you want to) unnecessary stuff:

    sed -i '/web-/d' snort.conf 
    sed -i '/browser-/d' snort.conf 
    sed -i '/file-/d' snort.conf 

add logging:

    # syslog
    # output alert_syslog: LOG_AUTH LOG_ALERT
    output alert_syslog:LOG_ALERT

    systemctl restart snort

test snort with nmap 

# Setup fail2ban

change fail2ban /etc/fail2ban/jail.local to use ufw instead iptables:

    banaction = ufw

set rules and config:

[snort.conf](https://github.com/adambialy/bind9_dlz/blob/main/snort.conf)

[snort_dns_p1](https://github.com/adambialy/bind9_dlz/blob/main/snort_dns_p1.conf)

[snort_dns_p2](https://github.com/adambialy/bind9_dlz/blob/main/snort_dns_p1.conf)

# Setup second server (mysql replication)

**on master - first dns server**

allow mysql communication from slave server:

    ufw allow from {slave_ip} to any port 3306 proto tcp

add replication user:

    mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'{slave_ip}' identified by 'R3pl##R3pl##';

create backup:

    mysqldump --all-databases --single-transaction --triggers --routines  -u root -p > /home/repldump.sql

transfer backup to slave:

    scp /home/repldump.sql {slave_ip}:/home

**on slave**

allow port 22/tcp on firewall

    ufw allow from {master_ip} to any port 22 proto tcp

Install mysql as before.

restore backup:

    mysql -u root -p < /home/repldump.sql


    mysql> reset master

    mysql> CHANGE MASTER TO MASTER_HOST='{master_ip}', MASTER_USER='replication', MASTER_PASSWORD='R3pl##R3pl##', MASTER_PORT=3306, MASTER_AUTO_POSITION = 1;

    mysql> start slave;

check replication status:

    mysql> SHOW SLAVE STATUs \G
    ...
    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes
    ...
    Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
    ...
    Retrieved_Gtid_Set: 7abf04e0-d050-11eb-9b09-42077e7fca18:180-182
    Executed_Gtid_Set: 7abf04e0-d050-11eb-9b09-42077e7fca18:1-182
    ...

**on master**

check if slave is connected

    mysql> mysql> show slave hosts;
    +-----------+------+------+-----------+--------------------------------------+
    | Server_id | Host | Port | Master_id | Slave_UUID                           |
    +-----------+------+------+-----------+--------------------------------------+
    |       102 |      | 3306 |       101 | 8669c7e7-d053-11eb-845d-1abe49ba7455 |
    +-----------+------+------+-----------+--------------------------------------+


on master insert test host and check if is synced with slave:

    mysql> insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', 'inserttest', 'A', '192.168.12.14', 3600 );


check if both resolving name:

    dig +short @localhost inserttest.mysql.dev.null
    192.168.12.14

    dig +short @{slave_ip} inserttest.mysql.dev.null
    192.168.12.14

    dig +short @{master_ip} inserttest.mysql.dev.null
    192.168.12.14

#TODO

**ansible playbook to follow**

**scripts**

add/remove records A, AAAA, PTR, CNAME


#Links

  * [http://bind-dlz.sourceforge.net/](http://bind-dlz.sourceforge.net/)
