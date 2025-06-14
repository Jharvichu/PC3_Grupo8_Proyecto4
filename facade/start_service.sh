#!/bin/bash

mkdir -p ../logs
nohup python3 "$(dirname "$0")/service_dummy.py" > ../logs/facade_service.log 2>&1 &