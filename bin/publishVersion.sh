#!/usr/bin/env bash

version=$1
xpi_file_path=$2

if ! command -v jq &> /dev/null; then
  echo "jq must be installed." 1>&2
  exit 1
fi

if [[ -z "$version" ]]; then
  echo "Pass version number." 1>&2
  exit 1
fi

if [[ ! -f "$xpi_file_path" ]]; then
  echo "Pass xpi file path." 1>&2
  exit 1
fi

xpi_file=$(basename "$xpi_file_path")

existing_release=$(jq -r --arg version "$version" \
  '.addons."{9FD229B7-1BD6-4095-965E-BE30EBFAD42E}".updates[] | select(.version == $version) | .version' \
  updates.json)
if [[ "$existing_release" ]]; then
  echo "Version $version is already published."
  exit 0
fi

mkdir -p versions
cp "$xpi_file_path" versions

# update update manifests
jq --arg version "$version" \
  --arg xpi_file "https://raw.githubusercontent.com/manaba-enhanced-for-tsukuba/dist-firefox/main/versions/$xpi_file" \
  '.addons."{9FD229B7-1BD6-4095-965E-BE30EBFAD42E}".updates += [
    {
      "version": $version,
      "update_link": $xpi_file
    }
  ]' \
  updates.json > updated.json
mv updated.json updates.json

# update docs
sed -i "s@https://raw.githubusercontent.com/manaba-enhanced-for-tsukuba/dist-firefox/main/versions/manaba_enhanced_for_tsukuba-.*.xpi@https://raw.githubusercontent.com/manaba-enhanced-for-tsukuba/dist-firefox/main/versions/manaba_enhanced_for_tsukuba-$version.xpi@" docs/latest/index.html

git add -N .

if ! git diff --exit-code; then
  version_name="v$version"

  git checkout -B "$version_name"
  git add .
  git commit -m "Release: $version_name"
  git pull origin "$version_name"
  git push origin "$version_name"

  echo "Please create PR from branch $version_name and merge it for publication."
fi
