#!/bin/bash

# ============================================================
# Flutter Web Deployment Script for GitHub Pages
# ============================================================

set -e  # Exit on any error

echo "🚀 Starting deployment to GitHub Pages..."
echo ""

# Step 1: Build Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release --base-href /equilend-auction/

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful!"
echo ""

# Step 2: Navigate to build directory
echo "📂 Preparing deployment..."
cd build/web

# Step 3: Initialize git and commit
git init
git add -A
git commit -m "Deploy Flutter web app - $(date '+%Y-%m-%d %H:%M:%S')"

# Step 4: Push to gh-pages branch
echo "🌐 Pushing to GitHub Pages..."
git push -f https://github.com/amanat-2003/equilend-auction.git main:gh-pages

if [ $? -ne 0 ]; then
  echo "❌ Deployment failed!"
  cd ../..
  rm -rf build/web/.git
  exit 1
fi

# Step 5: Clean up
cd ../..
rm -rf build/web/.git

echo ""
echo "✅ Deployment successful!"
echo "🎉 Your app will be live in ~30 seconds at:"
echo "   https://amanat-2003.github.io/equilend-auction/"
echo ""
