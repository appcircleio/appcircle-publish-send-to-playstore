#!/bin/bash
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  locale
  curl -o "./$AC_APP_FILE_NAME" -k "$AC_APP_FILE_URL"
  ls -lh

file_path="./$AC_APP_FILE_NAME"

  if [ -e "$file_path" ]; then
    file_size=$(du -h "$file_path" | cut -f1)
    file_hash=$(sha256sum "$file_path" | awk '{print $1}')
    echo "File exists: $file_path"
    echo "File size: $file_size"
    echo "File SHA-256 Hash: $file_hash"
else
    echo "File does not exist: $file_path"
fi

  bundle init
  echo "gem \"fastlane\"">>Gemfile
  bundle install
  mkdir fastlane
  touch fastlane/Appfile
  touch fastlane/Fastfile
   
  if [ -f "$AC_RELEASE_NOTES_FILE" ]; then
    echo "Found change log in AC_RELEASE_NOTES, copying to fastlane/metadata/android/en-us/changelogs/default.txt"
    mkdir -p "fastlane/metadata/android/en-us/changelogs"
    cp "$AC_RELEASE_NOTES_FILE" "fastlane/metadata/android/en-us/changelogs/default.txt"
  else
    echo "Warning: AC_RELEASE_NOTES_FILE is not found, changelog will be skipped."
  fi

  mv "$AC_FASTFILE_CONFIG" "fastlane/Fastfile"
  mv "$AC_APP_FILE_CONFIG" "fastlane/Appfile"
  mv "$AC_API_KEY" "$AC_API_KEY_FILE_NAME"
  
  bundle exec fastlane $AC_FASTLANE_PARAMS --verbose
  if [ $? -eq 0 ]
  then
  echo "PlayStore progress succeeded"
  exit 0
  else
  echo "PlayStore progress failed :" >&2
  exit 1
  fi