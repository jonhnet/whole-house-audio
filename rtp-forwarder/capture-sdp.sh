#!/bin/bash
echo Waiting for SDP packet... >&2
nc -W 1 -u -l 9875 -O 5 | tr '\0' '\n' | awk 'f;/^v=/{f=1; print}'
