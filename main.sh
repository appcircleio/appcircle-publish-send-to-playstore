#!/bin/bash
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  locale
  curl -o "./$AC_APP_FILE_NAME" -k $AC_APP_FILE_URL
  ls -lh

file_path="./$AC_APP_FILE_NAME"

  if [ -e "$file_path" ]; then
    file_size=$(du -h "$file_path" | cut -f1)
    echo "File exists: $file_path"
    echo "File size: $file_size"
else
    echo "File does not exist: $file_path"
fi

  bundle init
  echo "gem \"fastlane\"">>Gemfile
  bundle install
  mkdir fastlane
  touch fastlane/Appfile
  touch fastlane/Fastfile

  mv "$AC_FASTFILE_CONFIG" "fastlane/Fastfile"
  mv "$AC_APP_FILE_CONFIG" "fastlane/Appfile"
  mv "$AC_API_KEY" "$AC_API_KEY_FILE_NAME"
  
  if [[ "$AC_BINARY_FILE_TYPE" == "apk" ]] ; then
      bundle exec fastlane upload_apk --verbose
  fi

  if [[ "$AC_BINARY_FILE_TYPE" == "aab" ]] ; then
      bundle exec fastlane upload_aab --verbose
  fi
  
  if [ $? -eq 0 ]
  then
  echo "Google Play Console progress succeeded"
  exit 0
  else
  echo "Google Play Console progress failed :" >&2
  exit 1
  fi
