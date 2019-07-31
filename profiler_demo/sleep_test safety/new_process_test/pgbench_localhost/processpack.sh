#!/bin/bash
# This script runs a test for 2 cpu bounded processes and a memory bounded process

echo "This is the start for testing..."
echo "The process: "
echo ""
echo 
echo
su - postgres
pgbench -c 4 -j 4 -T 600
