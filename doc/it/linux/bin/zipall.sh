#!/bin/bash

# zip the 1st level subdirectories under the current folder, for achiving stuff
# note that if a directory contains space, this script does work properly...to be fixed.

for d in $(ls -1Ap | grep /\$ | cut -d/ -f1); do
  zip -r $d.zip $d
  rm -rf $d
done
