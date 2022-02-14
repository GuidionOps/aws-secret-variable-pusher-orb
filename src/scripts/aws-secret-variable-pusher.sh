#!/bin/bash	

for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ $(aws secretsmanager describe-secret --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" 2>&1 || true) =~ "ResourceNotFoundException" ]]; then
    echo "AWS secret not found"
    aws secretsmanager create-secret --name "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --secret-string $"${!i}" --kms-key-id "${PARAM_AWS_KMS_KEY}"

    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Enviroment,Value="${AWS_ACCOUNT_NAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Owner,Value="${CIRCLE_PROJECT_USERNAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=GitRepository,Value="${CIRCLE_PROJECT_REPONAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=DeploymentTool,Value="CircleCI"

    continue
fi
done

for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ "$(aws secretsmanager get-secret-value --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" | jq --raw-output .SecretString)" == $"${!i}" ]]; then
    echo "Variable is still the same on AWS"
    continue
else
    echo "Variable changed, updating on AWS"
    aws secretsmanager update-secret --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --secret-string $"${!i}" --kms-key-id "${PARAM_AWS_KMS_KEY}"

    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Enviroment,Value="${AWS_ACCOUNT_NAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=Owner,Value="${CIRCLE_PROJECT_USERNAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=GitRepository,Value="${CIRCLE_PROJECT_REPONAME}"
    aws secretsmanager tag-resource --secret-id "/${CIRCLE_PROJECT_REPONAME}/${PARAM_AWS_ENVIROMENT}/${i}" --tags Key=DeploymentTool,Value="CircleCI"

fi
done