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

echo "AC_FASTLANE_VERSION: $AC_FASTLANE_VERSION"

bundle init

if [ -z "$AC_FASTLANE_VERSION" ] || [ "$AC_FASTLANE_VERSION" = "latest" ]; then
    echo 'gem "fastlane"' >> Gemfile
    echo "Using latest fastlane version"
else
    echo "Using fastlane version: $AC_FASTLANE_VERSION"
    echo "gem \"fastlane\", \"$AC_FASTLANE_VERSION\"" >> Gemfile
fi
  
bundle install
mkdir fastlane
touch fastlane/Appfile
touch fastlane/Fastfile
     
CHANGELOG_FILE="$AC_RELEASE_NOTES_FILE"
FASTLANE_DIR="fastlane/metadata/android"

if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "Warning: AC_RELEASE_NOTES_FILE not found, changelog will be skipped."
else

  if grep -qE "<[a-z]{2}(-[A-Za-z0-9]+)?>" "$CHANGELOG_FILE"; then
    echo "Multi-language changelog detected. Splitting into Fastlane format..."

    if [ -n "$AC_PUBLISH_APP_VERSION_CODE" ]; then
      VERSION="$AC_PUBLISH_APP_VERSION_CODE"
    else
      VERSION="default"
    fi

    current_lang=""
    current_text=""

    while IFS= read -r line || [ -n "$line" ]; do

      if [[ $line =~ \<([a-z]{2}(-[A-Za-z0-9]+)?)\> ]]; then
        current_lang="${BASH_REMATCH[1]}"
        current_text=""
        continue
      fi

      if [[ $line =~ \<\/([a-z]{2}(-[A-Za-z0-9]+)?)\> ]]; then
        closing_lang="${BASH_REMATCH[1]}"
        if [[ "$closing_lang" != "$current_lang" ]]; then
          echo "Error: Mismatched language tags <$current_lang> ... </$closing_lang> in $CHANGELOG_FILE" >&2
          exit 1
        fi
        mkdir -p "$FASTLANE_DIR/$current_lang/changelogs"
        printf '%s\n' "$current_text" > "$FASTLANE_DIR/$current_lang/changelogs/$VERSION.txt"
        echo "Created changelog for $current_lang"
        current_lang=""
        current_text=""
        continue
      fi

      if [ -n "$current_lang" ]; then
        current_text+="$line"$'\n'
      fi

    done < "$CHANGELOG_FILE"

  else

    echo "No language tags found. Using single changelog."
    mkdir -p "$FASTLANE_DIR/en-US/changelogs"

    if [ -n "$AC_PUBLISH_APP_VERSION_CODE" ]; then
      VERSION="$AC_PUBLISH_APP_VERSION_CODE"
    else
      VERSION="default"
    fi

    cp "$CHANGELOG_FILE" "$FASTLANE_DIR/en-US/changelogs/$VERSION.txt"
    echo "Created default changelog."
  fi

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
