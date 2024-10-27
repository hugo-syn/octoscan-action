FROM ghcr.io/0x41gilecat/octoscan:master

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
