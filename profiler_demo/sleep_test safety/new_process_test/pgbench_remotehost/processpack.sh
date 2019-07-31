#!/bin/bash
# This script runs a test for 2 cpu bounded processes and a memory bounded process

echo "This is the start for testing..."
echo "The process: "
echo ""
echo 
echo
su - postgres
pgbench -c 16 -j 16 -T 600
