#!/bin/bash	

if [[ $(aws secretsmanager describe-secret --secret-id "${PARAM_AWS_SECRET_NAME}" 2>&1 || true) =~ "ResourceNotFoundException" ]]; then
    echo "AWS secret not found"
    aws secretsmanager create-secret --name "${PARAM_AWS_SECRET_NAME}" --secret-string $"${!PARAM_CIRCLECI_VARIABLE}" --kms-key-id "${PARAM_AWS_KMS_KEY}"
    exit 0
fi

if [[ "$(aws secretsmanager get-secret-value --secret-id "${PARAM_AWS_SECRET_NAME}" | jq --raw-output .SecretString)" == $"${!PARAM_CIRCLECI_VARIABLE}" ]]; then
    echo "Variable is still the same on AWS"
    exit 0
else
    echo "Variable changed, updating on AWS"
    aws secretsmanager update-secret --secret-id "${PARAM_AWS_SECRET_NAME}" --secret-string $"${!PARAM_CIRCLECI_VARIABLE}" --kms-key-id "${PARAM_AWS_KMS_KEY}"
fi