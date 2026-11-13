#!/bin/zsh
# Runs the App Store listing (and, with "submit", the App Review submission)
# from this Mac, using the key in ~/git/signing-keys. The price is only set
# PRICE_EUR defaults to the 14.99 one-time price (docs/PRICING_AND_SCOPE.md).
set -euo pipefail
cd ${0:A:h:h}
ASC=~/git/signing-keys/app-store-connect
export ASC_KEY_ID=G4VF7GLND7
export ASC_KEY_PATH=$ASC/AuthKey_$ASC_KEY_ID.p8
export ASC_ISSUER_ID=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['issuerId'], end='')" $ASC/nostavela-appstore.json)
export VERSION=${VERSION:-0.1.0} PRICE_EUR=${PRICE_EUR:-14.99}
export SUBMIT=$([[ ${1:-} == submit ]] && echo 1 || echo 0)
uv run --quiet --with "pyjwt[crypto]" python Scripts/asc_listing.py
