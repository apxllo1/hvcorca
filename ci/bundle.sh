#!/bin/bash
# Run the compile and build
npm run compile
npm run build

# Generate the release version date
DATE=$(date +%Y%m%d-%H%M)
echo "🔥 Release v$DATE - Auto-build from src"

# Execute the bundle with the correct parameters
remodel run ci/bundle.lua Havoc.rbxm public/latest.lua
