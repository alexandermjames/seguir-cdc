#!/usr/bin/env bash
set -e

EXEC_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG="${EXEC_DIRECTORY}/../conf/seguir-kinesis.json"

kinesalite --port 4567 --createStreamMs 10 &
KINESALITE_PID=`echo $!`
echo "${KINESALITE_PID}" > /tmp/kinesalite.pid

cat "${CONFIG}" | jq -r '.outputs[] | select(.module == "seguir-kinesis") | .streams[].streamName' | while IFS="" read STREAM_NAME; do
  AWS_ACCESS_KEY_ID="awsAccessKeyId" AWS_SECRET_ACCESS_KEY="awsSecretAccessKey" aws kinesis create-stream --region us-east-1 --stream-name "${STREAM_NAME}" --shard-count 1 --endpoint-url "http://localhost:4567"
done

cat "${CONFIG}" | jq -r '.files[]' | while IFS="" read FILE; do
  echo -n > "${FILE}"
done

if [ -f /tmp/checkpoint.log ]; then
  echo -n > /tmp/checkpoint.log
fi

seguir -c "${CONFIG}" &
SEGUIR_PID=`echo $!`
echo "${SEGUIR_PID}" > /tmp/seguir.pid
