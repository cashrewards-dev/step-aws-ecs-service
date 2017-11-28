#!/bin/sh

###################################
# INPUT
#
# echo $STEP_AWS_ACCESS_KEY_ID
# echo $STEP_AWS_SECRET_ACCESS_KEY
# echo $STEP_AWS_DEFAULT_REGION

# #FOR AWS ECS SERVICE
# echo $STEP_CLUSTER_NAME
# echo $STEP_SERVICE_NAME
# echo $STEP_TASK_DEFINITION_NAME
# echo $STEP_DESIRED_COUNT
# echo $STEP_SERVICE_TEMPLATE

# echo $STEP_DIR

STEP_AWS_PROFILE=wercker-step-aws-ecs

aws configure set aws_access_key_id ${STEP_AWS_ACCESS_KEY_ID} --profile ${STEP_AWS_PROFILE}
aws configure set aws_secret_access_key ${STEP_AWS_SECRET_ACCESS_KEY} --profile ${STEP_AWS_PROFILE}
if [ -n "${STEP_AWS_DEFAULT_REGION}" ]; then
  aws configure set region ${STEP_AWS_DEFAULT_REGION} --profile ${STEP_AWS_PROFILE}
fi



####
#
# FROM https://github.com/wercker/step-bash-template
#
#
template() {
  local input=$1
  local output=$2

  if [ ! -s $input ]; then
    echo "template() : ${input} : No such file or directory"
    exit 1
  fi

  if [ -e /dev/urandom ]; then
      RANDO=$(LANG=C tr -cd 0-9 </dev/urandom | head -c 12)
  else
      RANDO=2344263247
  fi

  BASH_TEMPLATE_ERROR_ON_EMPTY=true
  source "$STEP_DIR/template.sh" "$input" > "$output" 2>$RANDO

  if [ ! -z "$BASH_TEMPLATE_ERROR_ON_EMPTY" ]; then
    if [ -s $RANDO ]; then
      cat $RANDO
      rm -f $RANDO
      exit 1
    fi
  fi
  rm -f $RANDO  
}

input=$STEP_SERVICE_TEMPLATE
output=$(echo "$input" | sed 's/\.template//')
#output=$(dirname $input)/output.json  
warn "Templating $input -> $output"

template $input $output

cat $output

services=$(aws ecs describe-services \
   --profile ${STEP_AWS_PROFILE} \
   --cluster ${STEP_CLUSTER} \
   --services ${STEP_SERVICE_NAME} \
   --query services[0].status \
   --output text)

if [ 'ACTIVE' == $services ]; then
warn "Update Service : $STEP_SERVICE_NAME"    
aws ecs update-service \
      --profile ${STEP_AWS_PROFILE} \
      --cluster ${STEP_CLUSTER} \
      --service ${STEP_SERVICE_NAME} \
      --desired-count ${STEP_DESIRED_COUNT} \
      --task-definition ${STEP_TASK_DEFINITION_NAME} \
      --query service.serviceArn
else
warn "Create Service : $STEP_SERVICE_NAME"        
aws ecs create-service \
      --profile ${STEP_AWS_PROFILE} \
      --cli-input-json file://$output \
      --query service.serviceArn
fi
