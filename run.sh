#!/bin/bash
set +e
set -o noglob

#
# Headers and Logging
#

error() { printf "✖ %s\n" "$@"
}
warn() { printf "➜ %s\n" "$@"
}

type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

STEP_PREFIX="WERCKER_AWS_ECS_SERVICE"
step_var() {
  echo $(tmp=${STEP_PREFIX}_$1 && echo ${!tmp}) 
}

# Check python is installed
if ! type_exists 'python3'; then
  error "Please install python 3.x"
  exit 1
fi

# Check pip is installed
if ! type_exists 'pip'; then
  error "Please install pip"
  exit 1
fi


# Check variables
if [ -z "$(step_var 'KEY')" ]; then
  error "Please set the 'key' variable"
  exit 1
fi

if [ -z "$(step_var 'SECRET')" ]; then
  error "Please set the 'secret' variable"
  exit 1
fi

if [ -z "$(step_var 'REGION')" ]; then
  error "Please set the 'region' variable"
  exit 1
fi

if [ -z "$(step_var 'CLUSTER_NAME')" ]; then
  error "Please set the 'cluster-name' variable"
  exit 1
fi

if [ -z "$(step_var 'SERVICE_NAME')" ]; then
  error "Please set the 'service-name' variable"
  exit 1
fi

if [ -z "$(step_var 'TASK_DEFINITION_NAME')" ]; then
  error "Please set the 'task-definition-name' variable"
  exit 1
fi

if [ -z "$(step_var 'DESIRED_COUNT')" ]; then
  error "Please set the 'desired-count' variable"
  exit 1
fi

if [ -z "$(step_var 'SERVICE_TEMPLATE')" ]; then
  error "Please set the 'service-template' variable"  
fi

# INPUT Variables for main.sh

#FOR AWS CONFIGURE
STEP_AWS_ACCESS_KEY_ID=$(step_var 'KEY')
STEP_AWS_SECRET_ACCESS_KEY=$(step_var 'SECRET')
STEP_AWS_DEFAULT_REGION=$(step_var 'REGION')

#FOR AWS ECS SERVICE
STEP_CLUSTER=$(step_var 'CLUSTER_NAME')
STEP_SERVICE_NAME=$(step_var 'SERVICE_NAME')
STEP_TASK_DEFINITION_NAME=$(step_var 'TASK_DEFINITION_NAME')
STEP_DESIRED_COUNT=$(step_var 'DESIRED_COUNT')
STEP_SERVICE_TEMPLATE=$(step_var 'SERVICE_TEMPLATE')

STEP_DIR=$WERCKER_STEP_ROOT/step_src

source $STEP_DIR/main.sh




