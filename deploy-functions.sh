#!/bin/bash
# Bash script to deploy Firebase Cloud Functions
# Run this from the project root directory

echo "Deploying Firebase Cloud Functions..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "Error: Firebase CLI not found. Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js not found. Please install Node.js 18 or higher."
    exit 1
fi

# Navigate to functions directory
cd functions || exit 1

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies"
        cd ..
        exit 1
    fi
fi

# Build TypeScript
echo "Building TypeScript..."
npm run build
if [ $? -ne 0 ]; then
    echo "Error: Failed to build TypeScript"
    cd ..
    exit 1
fi

# Go back to root
cd ..

# Deploy functions
echo "Deploying to Firebase..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo "Deployment successful!"
else
    echo "Deployment failed. Check the error messages above."
    exit 1
fi

