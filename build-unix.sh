#!/usr/bin/env bash

dir=`pwd`
mkdir -p $dir/bin

cat > "$dir/bin/warfare" <<EOF
#! /bin/sh
exec swipl -q -t main -s "${dir}/src/main.pl" "\$@"
EOF

chmod a+x "$dir/bin/warfare"
