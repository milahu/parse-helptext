#!/usr/bin/env bash

set -e # stop on error
#set -x # xtrace

cd "$(dirname "$0")/.."

for txt in test/cases/*.txt; do
  echo "txt: $txt"
  base=${txt%.*}
  cat $txt | ./help2comp.py --json >$base.json
  cat $txt | ./help2comp.py --gen-parse-sh >$base.sh
  chmod +x $base.sh
done
