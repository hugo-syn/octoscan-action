FROM ghcr.io/0x41gilecat/octoscan:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
