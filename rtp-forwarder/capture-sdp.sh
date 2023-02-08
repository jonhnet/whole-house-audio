#!/bin/bash
nc -u -l 9875 -O 5 | tr '\0' '\n'
