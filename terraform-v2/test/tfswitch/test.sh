#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function test_case() {
    local JOB=$1
    local VERSION=$2

    circleci local execute --job $JOB >/tmp/output #| tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
        echo "Job $JOB Success"
    else
        echo "Job $JOB Fail"
        exit 1
    fi

    if ! grep "Terraform v$VERSION" /tmp/output > /dev/null; then
        echo "Failed test $JOB"
        exit 2
    fi
}

test_case default_default "0.11.14"
test_case default_tfswitch "0.11.13"
test_case default_tfenv "0.11.12"

test_case terraform_11_default "0.11.14"
test_case terraform_11_tfswitch "0.11.13"
test_case terraform_11_tfenv "0.11.12"

test_case terraform_12_default "0.12.5"
test_case terraform_12_tfswitch "0.11.13"
test_case terraform_12_tfenv "0.11.12"

test_case ext_11_default "0.11.14"
test_case ext_11_tfswitch "0.11.14"
test_case ext_11_tfenv "0.11.14"

echo "All tests passed"
