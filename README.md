# bind9 with dlz (dynamically loadable zones) in Debian10

This document is description ow to set up auth/cache dns server on debian10, bind 9.11.x with dlz and Mysql backend plus snort and fail2ban. Zone transfer is achieved by standard MySQL replication.

*In this example dnssec is not used.*

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

choose version you want (in the example 5.7), set root password

    apt update; apt upgrade
    apt install mysql-community-server apt install mysql-community-client libmysqld-dev libmysqlclient-dev

**create MySQL structure**

    mysql> create database dns_database
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
    }

example named.conf
    
    include "/usr/local/bind/etc/rndc.key";
    
    controls {
            inet 127.0.0.1 port 953
            allow { 127.0.0.1; } keys { "rndc-key"; };
    };
    
    
    acl blockednets { 0.0.0.0/8;
    		192.0.2.0/24;
    		224.0.0.0/3;
    		10.0.0.0/9;
    		10.128.0.0/10;
    		10.192.0.0/11;
    		10.224.0.0/12;
    		10.240.0.0/13;
    		10.248.0.0/14;
    		10.252.0.0/15;
    		10.254.0.0/16;
    		172.16.0.0/12;
    		192.168.0.0/16;
    		};
    	
    
    key "rndc-key" {
    	algorithm hmac-md5;
    	secret "2+mTfTxNhm3fI1NHuPMukQ==";
    	};
    
    controls {
    	inet 127.0.0.1 port 953
    		allow { 127.0.0.1; } keys { "rndc-key"; };
    	};
    
    
    options {
    
    statistics-file "/usr/local/bind/var/log/named.stats";
    directory "/usr/local/bind/var/named";
    zone-statistics yes;
    listen-on-v6 { any; };
    listen-on { any; };
    minimal-responses  no;
    additional-from-auth yes;
    additional-from-cache yes;
    version "PowerDNS 3.4.5";
    blackhole { blockednets; };
    
    
    rate-limit {
        ipv4-prefix-length 32;
        ipv6-prefix-length 56;
        window 10;
        responses-per-second 25;
        referrals-per-second 5;
        errors-per-second 5;
        nxdomains-per-second 25;
        slip 2;
        exempt-clients {
            192.168.4.0/23;
            192.168.50.0/24;
            };
    };
    
    
    };
    
    logging {
    
    	channel bind_syslog_l1 {
    	    syslog local1;
    	    severity dynamic;
    	    print-category yes;
    	    print-time no;
    	    print-severity yes;
    	    };
    
    	channel ratelimitlog {
    	    file "/var/log/bind/bind_ratelimit.log" versions 3 size 50m;
    	    severity dynamic;
    	    print-category yes;
    	    print-time yes;
    	    print-severity yes;
    	    };
    
    	channel transferlog {
    	    file "/var/log/bind/bind_transfer.log" versions 3 size 5m;
    	    severity dynamic;
    	    print-category yes;
    	    print-time yes;
    	    print-severity yes;
    	    };
    
    category security { bind_syslog_l1; };
    category xfer-out { transferlog; };
    category xfer-in { transferlog; };
    category rate-limit { ratelimitlog; };
    };
    
    
    view "external" {
    match-clients { !127.0.0.1; !91.151.6.28; any; };

    recursion no;
    
    #zone "." { type hint; file "/etc/namedb/named.root"; };
    
    dlz "outside" {
       database "mysql
       {host=localhost dbname=dns_database user=binduser pass=bind333##rr}
       {select zone from dns_records where zone = '$zone$' 
           and zone != '5.168.192.IN-ADDR.ARPA'
           and zone != '255.255.10.IN-ADDR.ARPA'
           and zone != 'sys.yourcompany.net'
           and zone != 'sys.other'}
       {select ttl, type, mx_priority, case when lower(type)='txt' then concat('\"', data, '\"')
           when lower(type) = 'soa' then concat_ws(' ', data, resp_person, serial, refresh, retry, expire, minimum)
           else data end from dns_records where zone = '$zone$' and host = '$record$'
           and zone != '5.168.192.IN-ADDR.ARPA'
           and zone != '255.255.10.IN-ADDR.ARPA'
           and zone != 'sys.yourcompany.net'
           and zone != 'sys.other'}
    
    {}
       {select ttl, type, host, mx_priority, case when lower(type)='txt' then concat('\"', data, '\"') else data end, 
       resp_person, serial, refresh, retry, expire, minimum from dns_records where zone = '$zone$' 
           and zone != '5.168.192.IN-ADDR.ARPA'
           and zone != '255.255.10.IN-ADDR.ARPA'
           and zone != 'sys.yourcompany.net'
           and zone != 'sys.other'}
       {select zone from xfr_table where zone = '$zone$' and client = '$client$' 
           and zone != '5.168.192.IN-ADDR.ARPA'
           and zone != '255.255.10.IN-ADDR.ARPA'
           and zone != 'sys.yourcompany.net'
           and zone != 'sys.other'}
    
    };
    };
    
    
    
    view "internal" {
    match-clients { 127.0.0.1; 91.151.6.28; };
    
    recursion yes;
    
    #zone "." { type hint; file "/etc/namedb/named.root"; };
    dlz "inside" {
       database "mysql
       {host=localhost dbname=dns_database user=binduser pass=bind333##rr}
       {select zone from dns_records where zone = '$zone$'}
       {select ttl, type, mx_priority, case when lower(type)='txt' then concat('\"', data, '\"')
            when lower(type) = 'soa' then concat_ws(' ', data, resp_person, serial, refresh, retry, expire, minimum)
            else data end from dns_records where zone = '$zone$' and host = '$record$'}
    {}
       {select ttl, type, host, mx_priority, case when lower(type)='txt' then concat('\"', data, '\"') else data end, 
       resp_person, serial, refresh, retry, expire, minimum from dns_records where zone = '$zone$'}
       {select zone from xfr_table where zone = '$zone$' and client = '$client$'}";
    };
    };

# Setup systemd

create /etc/systemd/system/named.service file

start and check if bind is running:

    systemctl daemon-reload

    systemctl start named.service 

    systemctl status named.service 


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

set rules (see conf files)

# Setup second server (mysql replication)

TODO




links:

  * [http://bind-dlz.sourceforge.net/](http://bind-dlz.sourceforge.net/)



