#!/bin/sh

BINARY=/root/cloudbuster
SAMPLES=/root/samples
MIDI=1
RESTART_DELAY=2

while true; do
  echo "$(date): Starting cloudbuster" >>/var/log/cloudbuster.log
  $BINARY -f $SAMPLES -midi $MIDI 2>&1 | tee /dev/lcd /var/log/cloudbuster.log
  EXIT_CODE=$?
  echo "$(date): cloudbuster exited with code $EXIT_CODE" >>/var/log/cloudbuster.log

  if [ $EXIT_CODE -eq 0 ]; then
    echo "$(date): Clean exit, not restarting" >>/var/log/cloudbuster.log
    break
  fi

  echo "$(date): Restarting in ${RESTART_DELAY}s..." >>/var/log/cloudbuster.log
  sleep $RESTART_DELAY
done
