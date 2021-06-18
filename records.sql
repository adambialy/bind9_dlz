# dev.nul domain
insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( 'dev.null', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );

insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'ns0', 'A', '192.168.1.2', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'ns1', 'A', '192.168.2.2', 3600 );
insert into dns_records ( zone, host, type, data, ttl, mx_priority ) VALUES ( 'dev.null', '@', 'MX', 'mail1.dev.null.', 3600, 5 );
insert into dns_records ( zone, host, type, data, ttl, mx_priority ) VALUES ( 'dev.null', '@', 'MX', 'mail2.dev.null.', 3600, 10 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'mail1', 'A', '192.168.1.3', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'mail2', 'A', '192.168.2.3', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'www', 'CNAME', 'mail2.dev.null.', 3600 );

# reverse

insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( '1.168.192.IN-ADDR.ARPA', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '1.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '1.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '1.168.192.IN-ADDR.ARPA', '2', 'PTR', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '1.168.192.IN-ADDR.ARPA', '3', 'PTR', 'mail1.dev.null.', 3600 );



insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( '2.168.192.IN-ADDR.ARPA', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '2.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '2.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '2.168.192.IN-ADDR.ARPA', '2', 'PTR', 'ns2.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '2.168.192.IN-ADDR.ARPA', '3', 'PTR', 'mail2.dev.null.', 3600 );


insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( '11.168.192.IN-ADDR.ARPA', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '11.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '11.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '11.168.192.IN-ADDR.ARPA', '2', 'PTR', 'internal.sys.dev.null.', 3600 );


insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( '12.168.192.IN-ADDR.ARPA', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '12.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '12.168.192.IN-ADDR.ARPA', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '12.168.192.IN-ADDR.ARPA', '11', 'PTR', 'node1.mysql.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '12.168.192.IN-ADDR.ARPA', '12', 'PTR', 'node2.mysql.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( '12.168.192.IN-ADDR.ARPA', '13', 'PTR', 'node3.mysql.dev.null.', 3600 );


# subdomains:

insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( 'sys.dev.null', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'sys', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'sys', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'sys.dev.null', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'sys.dev.null', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'sys.dev.null', 'internal', 'A', '192.168.11.2', 3600 );


insert into dns_records ( zone, host, type, data, ttl, refresh, retry, expire, minimum, serial, resp_person, primary_ns ) VALUES ( 'mysql.dev.null', '@', 'SOA', 'ns0.dev.null.', 3600, 10800, 3600, 604800, 3600, 2011071364, 'hostmaster.dev.null.', 'ns0.dev.null.' );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'mysql', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'dev.null', 'mysql', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', '@', 'NS', 'ns0.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', '@', 'NS', 'ns1.dev.null.', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', 'node1', 'A', '192.168.12.11', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', 'node2', 'A', '192.168.12.12', 3600 );
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', 'node3', 'A', '192.168.12.13', 3600 );



#test insert:
insert into dns_records ( zone, host, type, data, ttl ) VALUES ( 'mysql.dev.null', 'inserttest', 'A', '192.168.12.14', 3600 );
