#!/bin/bash
# Development server for Terrarium UI with mock/real mode support
#
# Usage:
#   ./dev.sh         # Use mock mode (default)
#   ./dev.sh --mock  # Use mock mode explicitly
#   ./dev.sh --real  # Use real WebSocket connection

cd "$(dirname "$0")"
export PATH="$PATH:$HOME/flutter/bin"

# Parse command line arguments
USE_MOCK=true
if [ "$1" = "--real" ]; then
  USE_MOCK=false
  echo "Starting Terrarium UI in REAL mode..."
  echo "Connect to: ws://192.168.50.200:8765"
else
  echo "Starting Terrarium UI in MOCK mode..."
  echo "Using simulated WebSocket data"
  echo ""
  echo "To use real backend, run: ./dev.sh --real"
fi
echo ""

flutter run -d chrome --web-port=8080 --dart-define=USE_MOCK=$USE_MOCK
