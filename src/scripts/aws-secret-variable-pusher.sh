#!/bin/bash	

for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ $(aws secretsmanager describe-secret --secret-id "${CIRCLE_PROJECT_REPONAME}-${i}" 2>&1 || true) =~ "ResourceNotFoundException" ]]; then
    echo "AWS secret not found"
    aws secretsmanager create-secret --name "${CIRCLE_PROJECT_REPONAME}-${i}" --secret-string $"${!i}" --kms-key-id "${PARAM_AWS_KMS_KEY}"
    exit 0
fi
done

for i in ${PARAM_CIRCLECI_VARIABLE//,/ }
do
if [[ "$(aws secretsmanager get-secret-value --secret-id "${CIRCLE_PROJECT_REPONAME}-${i}" | jq --raw-output .SecretString)" == $"${!i}" ]]; then
    echo "Variable is still the same on AWS"
    exit 0
else
    echo "Variable changed, updating on AWS"
    aws secretsmanager update-secret --secret-id "${CIRCLE_PROJECT_REPONAME}-${i}" --secret-string $"${!i}" --kms-key-id "${PARAM_AWS_KMS_KEY}"
fi
done