#!/usr/bin/env bash
set -e

if [ -f /tmp/checkpoint.log ]; then
  rm /tmp/checkpoint.log
fi

rm /tmp/test.partition.key*

if [ -f /tmp/kinesalite.pid ]; then
   cat /tmp/kinesalite.pid | xargs kill -SIGINT
   rm /tmp/kinesalite.pid
fi

if [ -f /tmp/seguir.pid ]; then
   cat /tmp/seguir.pid | xargs kill -SIGINT
   rm /tmp/seguir.pid
fi
