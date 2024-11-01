#!/bin/bash

# Start lsproxy in the workspace directory
cd /mnt/workspace
/lsproxy &
LSPROXY_PID=$!

# Start marimo in the app directory
cd /app
marimo run tutorial.py --host 0.0.0.0 --port 7860 &
MARIMO_PID=$!

# Handle shutdown gracefully
cleanup() {
    echo "Shutting down processes..."
    kill $LSPROXY_PID
    kill $MARIMO_PID
    exit 0
}

trap cleanup SIGTERM SIGINT

# Wait for either process to exit
wait $LSPROXY_PID $MARIMO_PID
