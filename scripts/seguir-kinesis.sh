#!#!/usr/bin/env bash

EXEC_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"${EXEC_DIRECTORY}"/../pretest/seguir-kinesis.sh

RC=$?
if [ "${RC}" -ne 0 ]; then
  "${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh
  exit 1
fi

"${EXEC_DIRECTORY}"/../node_modules/mocha/bin/mocha test/seguir-kinesis.js -R spec

RC=$?
if [ "${RC}" -ne 0 ]; then
  "${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh
  exit 1
fi

"${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh

RC=$?
if [ "${RC}" -ne 0 ]; then
  exit 1
fi
