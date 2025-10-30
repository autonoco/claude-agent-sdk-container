#!/bin/bash
set -e

echo "🚀 Claude Agent SDK Container - API Key Setup"
echo "=============================================="
echo ""
echo "This script will guide you through the setup process using"
echo "a standard Anthropic API key (recommended for most users)."
echo ""

# Check if running from correct directory
if [ ! -f "server.ts" ]; then
    echo "❌ Error: Please run this script from the repository root directory"
    exit 1
fi

# ============================================
# STEP 1: Get Anthropic API Key
# ============================================
echo "📋 Step 1: Anthropic API Key"
echo "-------------------------------------------"
echo ""
echo "You need an API key from Anthropic Console."
echo ""
echo "Get your API key at:"
echo "  https://console.anthropic.com/settings/keys"
echo ""
echo "Your API key should start with: sk-ant-api03-..."
echo ""
read -p "Enter your Anthropic API key: " ANTHROPIC_API_KEY

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ Error: API key is required"
    exit 1
fi

# Basic validation
if [[ ! "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
    echo "⚠️  Warning: API key doesn't start with 'sk-ant-'"
    echo "   Make sure you copied it correctly from Anthropic Console"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "✅ API key captured: ${ANTHROPIC_API_KEY:0:20}..."
echo ""

# ============================================
# STEP 2: Get Clerk Keys
# ============================================
echo "📋 Step 2: Clerk Authentication Keys"
echo "-------------------------------------------"
echo ""
echo "You need Clerk keys for authentication."
echo ""
echo "Get your keys at:"
echo "  https://dashboard.clerk.com/last-active?path=api-keys"
echo ""

echo "Enter your Clerk Secret Key (starts with sk_test_... or sk_live_...):"
read -p "> " CLERK_SECRET_KEY

if [ -z "$CLERK_SECRET_KEY" ]; then
    echo "❌ Error: Clerk Secret Key is required"
    exit 1
fi

echo ""
echo "Enter your Clerk Publishable Key (starts with pk_test_... or pk_live_...):"
read -p "> " CLERK_PUBLISHABLE_KEY

if [ -z "$CLERK_PUBLISHABLE_KEY" ]; then
    echo "❌ Error: Clerk Publishable Key is required"
    exit 1
fi

echo ""
echo "✅ Clerk keys captured"
echo ""

# ============================================
# STEP 3: Generate API Key for endpoint protection
# ============================================
echo "📋 Step 3: Generating API Key for endpoint protection"
echo "-------------------------------------------"
echo ""

API_KEY=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

echo "✅ Generated API key: ${API_KEY:0:16}..."
echo ""

# ============================================
# STEP 4: Write .env file
# ============================================
echo ""
echo "📋 Step 4: Writing .env file"
echo "-------------------------------------------"
echo ""

cat > .env << EOF
# Anthropic API Key
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# API Key for REST endpoint protection
CLAUDE_AGENT_SDK_CONTAINER_API_KEY=$API_KEY

# Clerk Authentication
CLERK_SECRET_KEY=$CLERK_SECRET_KEY
CLERK_PUBLISHABLE_KEY=$CLERK_PUBLISHABLE_KEY
EOF

echo "✅ Created .env file with all credentials"
echo ""

# ============================================
# COMPLETE!
# ============================================
echo "🎉 Setup Complete!"
echo "================================================"
echo ""
echo "All credentials have been configured in .env"
echo ""
echo "Your API key for REST access:"
echo "  $API_KEY"
echo ""

# Automatically run update.sh to build and start the container
echo "Building and starting container..."
echo ""
if [ -f ./update.sh ]; then
    ./update.sh
else
    echo "⚠️  update.sh not found. Please run ./test.sh manually to start the container."
fi
