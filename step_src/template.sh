#!/bin/sh
if [ ! -z "$BASH_TEMPLATE_ERROR_ON_EMPTY" ]; then
  set -u
fi

eval "cat <<EOF
$(cat "$1")
EOF
"