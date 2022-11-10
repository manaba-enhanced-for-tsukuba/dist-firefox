#!/usr/bin/env bash

new_version=$1

if [[ -z "$new_version" ]]; then
  echo "Pass version number." 1>&2
  exit 1
fi

sed -i "s@https://raw.githubusercontent.com/manaba-enhanced-for-tsukuba/dist-firefox/main/versions/manaba_enhanced_for_tsukuba-.*.xpi@https://raw.githubusercontent.com/manaba-enhanced-for-tsukuba/dist-firefox/main/versions/manaba_enhanced_for_tsukuba-$new_version.xpi@" README.md
