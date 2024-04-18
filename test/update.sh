#!/usr/bin/env bash

set -e # stop on error
#set -x # xtrace

parse_helptext=./parse_helptext.py

cd "$(dirname "$0")/.."

for txt in test/cases/*.txt; do
  echo "txt: $txt"
  base=${txt%.*}
  cat $txt | $parse_helptext --json >$base.json
  cat $txt | $parse_helptext --gen-argparse-sh >$base.sh
  chmod +x $base.sh
done
