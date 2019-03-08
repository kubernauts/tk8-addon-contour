#!/bin/sh

set -euo pipefail
#set -x

target="./main.yml"
rm "$target"
echo "# Derived from ./contour-config" >> "$target"
echo "Creating main.yaml"

for file in $(find ./contour-config -type f -name "*.yaml" | sort) ; do
  echo "add " $file
  cat "$file" >> "$target"
  echo " " >> "$target"
  echo "---" >> "$target"
done
