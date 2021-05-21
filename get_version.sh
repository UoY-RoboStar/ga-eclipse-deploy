#!/bin/bash
dir=$1

# Logic adapted from existing upload.sh
file=$(ls $dir/features | grep -m 1 jar)
version=${file#*_}
version=${version%.jar}

if [[ $version = *[!\ ]* ]];
then
  # Sets the version to be consumed by a GitHub action.
  echo "::set-output name=version::${version}"
else
  # Reports an error instead if not able to find the version.
  echo "::error ::Unable to find version."
  exit 1;
fi
