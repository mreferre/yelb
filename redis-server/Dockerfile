FROM eqalpha/keydb

COPY keydb.conf /etc/keydb/keydb-yelb.conf

ENTRYPOINT [ "keydb-server", "/etc/keydb/keydb-yelb.conf", "--server-threads 4" ]