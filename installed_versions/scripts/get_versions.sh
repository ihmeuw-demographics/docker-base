#!/bin/bash

VERSION_TAG=$1
echo $VERSION_TAG
mkdir installed_versions/$VERSION_TAG

# output the version of R installed
docker run ihmeuwdemographics/base:$VERSION_TAG R --version >> installed_versions/$VERSION_TAG/R_version.txt

# output all R packages installed
docker run -v ${PWD}/installed_versions:/tmp ihmeuwdemographics/base:$VERSION_TAG Rscript /tmp/scripts/get_R_packages.R $VERSION_TAG

# output all Python packages installed
docker run ihmeuwdemographics/base:$VERSION_TAG pip list >> installed_versions/$VERSION_TAG/Python_packages.txt

# output all apt packages manually installed
# perl command to remove colour codes https://superuser.com/questions/380772/removing-ansi-color-codes-from-text-stream
docker run ihmeuwdemographics/base:$VERSION_TAG bash -c "apt list --manual-installed --verbose | perl -pe 's/\e\[[0-9;]*m//g'" >> installed_versions/$VERSION_TAG/apt_packages.txt
