#!/bin/sh

# pack
# 
# packing a application using nix
#
# what it do?
#
# 1. create a .build directory
# 2. get all the dependencies from "result"
# 3. pack it with a temp /usr/bin/{*apps}
# 4. clean up
#
set -e
cwd="$PWD"

list_to_copy() {
  nix-store -q --tree ${cwd}/result |\
    sed 's#^[^/]*\(/[^ ][^ ]*\).*#\1#' |\
    sort |\
    uniq 
}

mkdir -p "${cwd}/usr/bin" &&\
nix-build &&\
list_to_copy |\
xargs tar -cf "${cwd}/result.tar" $(for binary in $(readlink ${cwd}/result)/bin/*; do ln -s "$binary" "${cwd}/usr/bin/${binary##*/}"; echo "usr/bin/${binary##*/}"; done)

if [[ $? -eq 0 ]]; then
  echo "done"
  rm -rf "${cwd}/usr"
  exit 0
else
  echo "fail"
  rm -rf "${cwd}/usr"
  exit 1
fi

