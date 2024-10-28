FROM ghcr.io/synacktiv/octoscan:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
