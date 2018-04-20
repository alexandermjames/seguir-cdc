#!#!/usr/bin/env bash

EXEC_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"${EXEC_DIRECTORY}"/../pretest/seguir-kinesis.sh

RC=$?
if [ "${RC}" -ne 0 ]; then
  echo "seguir-kinesis startup script failed to run successfully."
  "${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh
  exit 1
fi

"${EXEC_DIRECTORY}"/../node_modules/mocha/bin/mocha test/seguir-kinesis.js -R spec

RC=$?
if [ "${RC}" -ne 0 ]; then
  echo "seguir-kinesis tests failed to run successfully."
  "${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh
  exit 1
fi

"${EXEC_DIRECTORY}"/../posttest/seguir-kinesis.sh

RC=$?
if [ "${RC}" -ne 0 ]; then
  echo "seguir-kinesis cleanup script failed to run successfully."
  exit 1
fi
