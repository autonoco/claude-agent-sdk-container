#!/bin/bash
set -e

echo "🚀 Claude Agent SDK Container - OAuth Setup"
echo "==========================================="
echo ""
echo "⚠️  IMPORTANT: OAuth Token Requires Anthropic Permission"
echo "This setup uses Claude Code OAuth tokens which require"
echo "prior approval from Anthropic."
echo ""
echo "For most users, use ./setup-api-key.sh instead (simpler, no approval needed)"
echo ""
read -p "Do you have permission to use OAuth tokens? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please use ./setup-api-key.sh for standard API key setup"
    exit 0
fi
echo ""
echo "This script will guide you through the complete setup process:"
echo "  1. Get your Claude OAuth token"
echo "  2. Create a GitHub App (one click!)"
echo "  3. Configure access control"
echo "  4. Generate all necessary credentials"
echo ""

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found"
    echo ""
    echo "Please install Claude Code first:"
    echo "  https://docs.claude.com/en/docs/claude-code/overview"
    exit 1
fi

echo "✅ Claude CLI detected"
echo ""

# ============================================
# STEP 1: Get Claude OAuth Token
# ============================================
echo "📋 Step 1: Getting your Claude OAuth Token"
echo "-------------------------------------------"
echo ""
echo "This will open your browser to authenticate with Anthropic."
echo "After login, you'll see your OAuth token in the terminal."
echo ""
read -p "Press ENTER to continue..."

# Run claude setup-token and capture output
echo ""
echo "Running: claude setup-token"
echo ""

# Run the command and capture output
CLAUDE_OUTPUT=$(claude setup-token 2>&1 || true)

# Try to extract token from output (format: sk-ant-oat01-...)
CLAUDE_TOKEN=$(echo "$CLAUDE_OUTPUT" | grep -oE 'sk-ant-oat01-[A-Za-z0-9_-]+' | head -n 1 || true)

if [ -z "$CLAUDE_TOKEN" ]; then
    echo ""
    echo "⚠️  Could not automatically extract token from output."
    echo ""
    echo "Please paste your Claude OAuth token here:"
    echo "(It starts with sk-ant-oat01-...)"
    read -r CLAUDE_TOKEN
fi

if [ -z "$CLAUDE_TOKEN" ]; then
    echo "❌ Error: No token provided"
    exit 1
fi

echo ""
echo "✅ Claude token captured: ${CLAUDE_TOKEN:0:20}..."
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
# STEP 3: Generate API Key
# ============================================
echo "📋 Step 3: Generating API Key"
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
# Claude OAuth Token
CLAUDE_CODE_OAUTH_TOKEN=$CLAUDE_TOKEN

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
