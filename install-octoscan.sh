#!/bin/sh
set -e

OCTOSCAN_ASSET_URL=$(curl -sS https://api.github.com/repos/synacktiv/octoscan/releases/latest | jq -r '.assets[] | select(.name == "octoscan") | .browser_download_url')
echo $OCTOSCAN_ASSET_URL
curl -sSL "$OCTOSCAN_ASSET_URL" -o ./octoscan
ls -asl ./octoscan
file ./octoscan
chmod +x ./octoscan
cp ./octoscan /usr/local/bin/