#!/bin/bash

echo "Starting stress-ng test..."
stress-ng --cpu 4 --cpu-method fft --cpu-ops 8000
echo "Stress-ng ends."
 
