# PowerShell script to deploy Firebase Cloud Functions
# Run this from the project root directory

Write-Host "Deploying Firebase Cloud Functions..." -ForegroundColor Green

# Check if Firebase CLI is installed
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Firebase CLI not found. Install it with: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Node.js not found. Please install Node.js 18 or higher." -ForegroundColor Red
    exit 1
}

# Navigate to functions directory
Set-Location functions

# Install dependencies if node_modules doesn't exist
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to install dependencies" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
}

# Build TypeScript
Write-Host "Building TypeScript..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to build TypeScript" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Go back to root
Set-Location ..

# Deploy functions
Write-Host "Deploying to Firebase..." -ForegroundColor Yellow
firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment successful!" -ForegroundColor Green
} else {
    Write-Host "Deployment failed. Check the error messages above." -ForegroundColor Red
    exit 1
}

