# step-aws-ecs-service
Wercker Step to register service in aws ecs

## wecker.yml

```
deploy:
    steps:
    - steven-rho/aws-ecs-service:
        name: sample scheduled task
        key: $STEP_AWS_ACCESS_KEY_ID
        secret: $STEP_AWS_SECRET_ACCESS_KEY
        region: $STEP_AWS_DEFAULT_REGION
        cluster-name: $STEP_CLUSTER
        service-name: $STEP_SERVICE_NAME
        task-definition-name: $STEP_TASK_DEFINITION_NAME        
        task-count: $STEP_DESIRED_COUNT
        service-template: ecs_service.json.template

```

## Teamplate (ie. example/ecs_service.json.template)
```
{
    "cluster": "${STEP_CLUSTER}",
    "serviceName": "${STEP_SERVICE_NAME}",
    "taskDefinition": "${STEP_TASK_DEFINITION_NAME}",
    "desiredCount": ${STEP_DESIRED_COUNT},
    "clientToken": "",
    "role": "",
    "deploymentConfiguration": {
        "maximumPercent": 200,
        "minimumHealthyPercent": 50
    }
}
```

