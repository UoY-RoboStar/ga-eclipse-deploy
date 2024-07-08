#!/bin/bash
# Expects to receive inputs:
# eg: circus.robocalc.robochart.textual.repository/target/repository/ branch version user@host remote
dir=$1
override=$2
symlink=$3
version=$4
url=$5
remote=$6
branch=${GITHUB_REF_NAME}

# Use the branch name to choose the name of the branch. This assumes
# no branch of name 'update' will ever be used.
if [[ $override = true ]];
then
  update=$symlink
else
  if [[ $branch = master || $branch = main ]];
  then
    update=update
  else
    update=$branch
  fi
fi

dest=${update}_${version}

echo "Current version: " $version;
echo "Branch: " $branch;
echo "Target dir:" $dest;

rm -rf tmp
mkdir tmp && cd tmp
mkdir $dest
cp -r ../$dir/* $dest

# In the new host, it is not possible to generate a symlink that points to
# a non-existent target, such as 'update', before it is actually created.
# So here we first transfer the update folder, then create the symlink and
# finally transfer that too.
rsync -a -e "ssh" -rtzh . $url:$remote
ln -s $dest ${update}
rsync -a -e "ssh" -rtzh . $url:$remote

if [[ $? -ne 0 ]];
then
  echo "::error ::Unable to deploy using rsync."
  exit 1;
fi

echo "::set-output name=dest::${dest}"
