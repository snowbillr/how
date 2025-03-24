#!/usr/bin/env bash
set -euo pipefail

# 🛠 Config
GEM_NAME="how"
GEM_VERSION=$(ruby -e "puts File.read('how.gemspec')[/spec.version\s*=\s*['\"]([^'\"]+)['\"]/, 1]")

GEM_FILE="${GEM_NAME}-${GEM_VERSION}.gem"

echo "🧹 Cleaning old files..."
rm -f "${GEM_FILE}"

echo "📦 Installing + Vendoring dependencies..."
bundle install
bundle package

echo "💎 Building gem..."
gem build "${GEM_NAME}.gemspec"

echo "✅ Built ${GEM_FILE}"

echo "🔐 SHA256:"
shasum -a 256 "${GEM_FILE}"

echo ""
echo "📤 Next steps:"
echo "1. Upload ${GEM_FILE} to your GitHub release: https://github.com/snowbillr/how/releases/tag/v${GEM_VERSION}"
echo "2. Update your Homebrew formula to use:"
echo "   url \"https://github.com/snowbillr/how/releases/download/v${GEM_VERSION}/${GEM_FILE}\""
echo "   sha256 <paste-sha256-here>"
echo ""
echo "✨ Done!"
