#!/bin/bash
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  locale
  curl -o "./$AndroidFileName" -k $AndroidFileUrl
  bundle init
  echo "gem \"fastlane\"">>Gemfile
  bundle install
  mkdir fastlane
  touch fastlane/Appfile
  touch fastlane/Fastfile
  mv "$FastFileConfig" "fastlane/Fastfile"
  mv "$AppFileConfig" "fastlane/Appfile"
  mv "$ApiKey" "$ApiKeyFileName"
  bundle exec fastlane $FastlaneParams --verbose
  if [ $? -eq 0 ]
  then
  echo "PlayStore progress succeeded"
  exit 0
  else
  echo "PlayStore progress failed :" >&2
  exit 1
  fi