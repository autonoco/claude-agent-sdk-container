# Claude Agent SDK Container

**Deploy Claude Agent SDK to your favorite cloud provider so that it runs using your Anthropic Max Plan tokens rather than API tokens!**

This repository containerizes the Claude Agent SDK, allowing you to run it with your Anthropic subscription on AWS, Google Cloud, Azure, or any cloud platform that supports Docker. Once deployed, you can interact with Claude through a web-based CLI or a REST API from any application or service!

**🤖 Multi-Agent Feature:** The `/query` endpoint includes a built-in example of multi-agent collaboration where a Canadian 🍁 and Australian 🇦🇺 agent discuss user requests and provide their unique perspectives. This demonstrates how to use the Claude Agent SDK's Task tool for subagent delegation. [See examples below](#examples) or customize the agents in `server.ts`.

Since you're here, we expect you already have Claude Code installed and are loving it as much as we are. But if you haven't installed it yet, you can get started here: [Claude Code Installation Guide](https://docs.claude.com/en/docs/claude-code/overview)

> 🔒 **Security Note**: This container exposes Claude AI with tools through an HTTP API. Like any AI integration, be mindful of prompt injection when handling untrusted input. Learn more about this important topic from [Simon Willison's articles on prompt injection](https://simonwillison.net/tags/prompt-injection/).

## ✨ Features

### 🌐 **Dual Access Modes**
- **Web CLI Interface**: Interactive browser-based terminal with real-time streaming
- **REST API**: Programmatic access for applications and integrations

### 🔐 **Security & Access Control**
- **GitHub OAuth Authentication**: Simple one-click GitHub login for web CLI
- **API Key Protection**: Secure REST API access with configurable API keys
- **GitHub Allowlisting**: Control web CLI access by GitHub usernames or organizations
- **JWT Session Management**: Secure cookie-based sessions with expiration

### 🔧 **GitHub Integration**
- **OAuth2 Flow**: Standard GitHub OAuth for seamless authentication
- **Organization Support**: Restrict access by GitHub organization membership
- **User Allowlists**: Fine-grained control with specific GitHub usernames

### 🚀 **Production Ready**
- **Docker-First**: Optimized multi-stage build for cloud deployment
- **Health Monitoring**: Built-in health checks and status endpoints
- **Graceful Shutdown**: Proper signal handling for container orchestration
- **Comprehensive Logging**: Detailed startup and access control logging

### 🔒 **Security First**
- **Automated Security Audit**: First-run scan for malicious code and vulnerabilities
- **Supply Chain Protection**: Detects compromised npm packages and Dockerfile attacks
- **Secret Detection**: Prevents hardcoded credentials in containers
- **Best Practices**: Follows security patterns (non-root user, minimal attack surface)

### 🛠️ **Developer Experience**
- **Real-time Streaming**: Character-by-character CLI response streaming
- **Multiple Models**: Support for Claude Sonnet 4.5 and Opus 4.1
- **Multi-Agent System**: Built-in example with Canadian 🍁 and Australian 🇦🇺 agents
- **Backward Compatible**: Preserves existing REST API functionality
- **Auto-testing**: Comprehensive test script validates full functionality

## 🚀 Quick Setup (4 Steps!)

### Step 1: Clone and Open with Claude Code
```bash
git clone https://github.com/receipting/claude-agent-sdk-container
cd claude-agent-sdk-container
claude
```

**🔒 First-Time Security Check:**

When you first open this repository, Claude Code will prompt you to run a security audit:

```
🔒 SECURITY AUDIT RECOMMENDED

You've just opened a repository from GitHub.

⚠️ IMPORTANT: Before running 'npm install' or 'docker build', it's
   recommended to check this repository for security issues.

💡 To perform the security audit, ask Claude Code:
   "Please perform the security audit for this repository"
```

**Tell Claude**: `Please perform the security audit for this repository`

Claude will spawn an AI-powered agent that intelligently analyzes:
- ✅ `package.json` for malicious install scripts and obfuscated code
- ✅ `Dockerfile` for security antipatterns (curl | bash, hardcoded secrets)
- ✅ Source code for hardcoded secrets, backdoors, and suspicious patterns
- ✅ `.claude/` configuration for malicious hooks

**Why AI-powered?** Unlike regex patterns, Claude understands context and intent, catches novel attack patterns, and explains WHY something is suspicious.

Once the security audit completes, you're safe to proceed with setup!

### Step 2: Run Automated Setup

Claude will tell you to run the setup script in a **separate terminal window**:

```bash
./setup-tokens.sh
```

**The script automatically handles:**
1. ✅ Getting your Claude OAuth token (opens browser to Anthropic)
2. ✅ Creating a unique GitHub App with one click (opens browser to GitHub)
   - Auto-generates unique name like `claude-agent-sdk-202510052056`
   - Or reuses existing credentials if found in `.env`
3. ✅ Configuring access control (your GitHub username auto-added!)
4. ✅ Generating a secure random API key
5. ✅ Writing all credentials to `.env` file

**What you'll do:**
- Click "Authorize" in browser to login to Anthropic (for Claude token)
- Click "Create GitHub App" in browser (literally one click!)
- Press Enter to accept your username in allowlist (or add more users)
- That's it - all credentials automatically saved!

**Traditional 15-step GitHub App setup reduced to ONE CLICK!**

### Step 3: Return to Claude Code

After `./setup-tokens.sh` completes, go back to Claude Code and tell it:

```
Please run ./test.sh
```

Claude will:
- ✅ Build the Docker container
- ✅ Run the container with your `.env` credentials
- ✅ Test all endpoints
- ✅ Confirm everything works

### Step 4: Open the Web CLI

Once Claude confirms the application is running, open your browser to:

**http://localhost:8080**

- Sign in with your GitHub account
- Use the real-time streaming CLI interface
- Ask Claude anything!

**That's it!** You're now running your own private Claude instance with OAuth security.

---

**🛠️ Smart Setup Detection:**

This repository includes an intelligent Claude Code hook that guides you through setup:

**Setup Status Hook** (`UserPromptSubmit`) - Runs until setup complete:
- Reminds you to run the security audit (optional but recommended)
- Checks if `.env` is configured
- Verifies Docker image is built
- Confirms container is running
- Shows clear status and next steps
- Creates `.claude/.setup-complete` marker when done

Claude automatically sees your setup state and guides you - no manual checks needed!

### Manual Setup

<details>
<summary>Click here if you prefer to set things up manually (or if automated setup fails)</summary>

### Manual Step 1: Get Your Claude OAuth Token

```bash
claude setup-token
```

This opens a browser to login to Anthropic. After login, the token appears in your terminal.

COPY IT NOW - you can't get it again!

### Manual Step 2: Create GitHub App

Go to [GitHub Settings > Developer settings > GitHub Apps](https://github.com/settings/apps/new) and create a new GitHub App:

> 💡 **Note**: Use a unique timestamped name like `claude-agent-sdk-202510052056` to avoid conflicts. If you want to reuse the same app across multiple machines/deployments, you can reuse the same GitHub App credentials by using the same Client ID and Client Secret in your `.env` file.

- **GitHub App name**: `claude-agent-sdk-YYYYMMDDHHMM` (use a unique timestamped name)
- **Homepage URL**: `http://localhost:8080`
- **Callback URL**: `http://localhost:8080/auth/github`
- **Request user authorization (OAuth) during installation**: ✅ **Check this box**
- **Webhook**: Uncheck "Active" (we don't need webhooks)
- **Permissions**:
  - Account permissions > Email addresses: **Read**
  - Account permissions > Profile: **Read**

After creating the app, copy the **Client ID** and generate a **Client Secret** for the next step.

**If the name is already taken:** You (or your organization) already have this app! Just use the existing app's credentials instead of creating a new one. Find it at [GitHub Settings > Apps](https://github.com/settings/apps).

### Manual Step 3: Create .env File in This Directory

```bash
cat > .env << 'EOF'
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-YOUR-TOKEN-HERE
CLAUDE_AGENT_SDK_CONTAINER_API_KEY=pick-any-random-string-as-your-api-key

# GitHub App Configuration (Required for web CLI)
GITHUB_CLIENT_ID=your_github_app_client_id
GITHUB_CLIENT_SECRET=your_github_app_client_secret

# Required: GitHub access control for web CLI (choose one or both)
ALLOWED_GITHUB_USERS=user1,user2,user3
# ALLOWED_GITHUB_ORG=yourcompany
EOF
```

**Required:**
- **CLAUDE_CODE_OAUTH_TOKEN**: Your Claude Code OAuth token
- **CLAUDE_AGENT_SDK_CONTAINER_API_KEY**: API key for REST endpoint protection
- **GITHUB_CLIENT_ID**: GitHub OAuth App Client ID
- **GITHUB_CLIENT_SECRET**: GitHub OAuth App Client Secret

**Required GitHub Access Control (for security):**
- **ALLOWED_GITHUB_USERS**: Comma-separated list of GitHub usernames allowed to access web CLI
- **ALLOWED_GITHUB_ORG**: GitHub organization name (users from this org can access web CLI)

**GitHub Access Behavior:**
- **At least one allowlist must be configured** - the container will not start without proper access control
- You must set either `ALLOWED_GITHUB_USERS` or `ALLOWED_GITHUB_ORG` (or both)
- This prevents unauthorized access to your Claude instance

### Manual Step 4: Run the app

Tell Claude Code:
```
Please build the Docker container, run it, and verify it's working
```

Or run manually:
```bash
./test.sh
```

**Note:** All scripts automatically sanitize directory names (lowercase, alphanumeric only) for Docker compatibility.

</details>

## 🎯 What You Get After Setup

Once setup completes, you'll have:

**🌐 Web CLI Interface** at `http://localhost:8080`
- Sign in with your GitHub account (one-click OAuth)
- Real-time streaming terminal interface
- Full conversational context maintained across messages

**🔧 REST API** at `http://localhost:8080/query`
- Secure API key authentication
- Built-in multi-agent collaboration system
- Easy integration with any application

### Try the Multi-Agent System

Test the built-in Canadian 🍁 and Australian 🇦🇺 agents:
```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{"prompt": "Help me plan a vacation"}'
```

You'll see both agents discuss your request and provide their unique perspectives!

---

<details>

<summary>☁️ Deployment Options - Let Claude Code deploy this for you!</summary>

| Platform             | Service                              | “Deploy a Dockerized app” docs                                                                                                                                                                                                                  |
| -------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AWS                  | App Runner                           | [Getting started with App Runner](https://docs.aws.amazon.com/apprunner/latest/dg/getting-started.html)                                                                                                                                         |
| AWS                  | Amazon ECS (Fargate)                 | [Getting started with Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/getting-started-fargate.html)                                                                                                                        |
| AWS                  | Elastic Beanstalk (Docker)           | [Deploying with Docker containers](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html)                                                                                                                            |
| AWS                  | Lightsail Containers                 | [Deploy and manage containers](https://docs.aws.amazon.com/lightsail/latest/userguide/amazon-lightsail-container-services.html)                                                                                                                 |
| Google Cloud         | Cloud Run                            | [Deploying container images to Cloud Run](https://cloud.google.com/run/docs/deploying)                                                                                                                                                          |
| Google Cloud         | Google Kubernetes Engine (GKE)       | [Quickstart: Deploy an app to a GKE cluster](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster)                                                                                                                                |
| Google Cloud         | App Engine Flexible (custom runtime) | [Build custom runtimes (Dockerfile)](https://cloud.google.com/appengine/docs/flexible/custom-runtimes/build)                                                                                                                                    |
| Azure                | Container Apps                       | [Quickstart: Deploy your first container app](https://learn.microsoft.com/en-us/azure/container-apps/get-started) • [Deploy existing image](https://learn.microsoft.com/en-us/azure/container-apps/get-started-existing-container-image-portal) |
| Azure                | App Service (Web App for Containers) | [Quickstart: Run a custom container on App Service](https://learn.microsoft.com/en-us/azure/app-service/quickstart-custom-container)                                                                                                            |
| Azure                | Container Instances (ACI)            | [Quickstart: Deploy a container instance](https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart-portal)                                                                                                    |
| Azure                | AKS (Kubernetes)                     | [Quickstart: Deploy an AKS cluster & app (CLI)](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli)                                                                                                                  |
| Fly.io               | Machines / Launch                    | [Deploy with a Dockerfile](https://fly.io/docs/languages-and-frameworks/dockerfile/)                                                                                                                                                            |
| Railway              | Services                             | [Build from a Dockerfile](https://docs.railway.com/guides/dockerfiles)                                                                                                                                                                          |
| Render               | Web Services                         | [Docker on Render](https://render.com/docs/docker)                                                                                                                                                                                              |
| DigitalOcean         | App Platform                         | [How to deploy from container images](https://docs.digitalocean.com/products/app-platform/how-to/deploy-from-container-images/)                                                                                                                 |
| Heroku               | Container Registry & Runtime         | [Container Registry & Runtime (Docker Deploys)](https://devcenter.heroku.com/articles/container-registry-and-runtime)                                                                                                                           |
| Kubernetes (generic) | —                                    | [Using kubectl to create a Deployment](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)                                                                                                                         |


</details>

<details>
<summary>📚 Full Manual Instructions (if you really want to do it yourself)</summary>

## Manual Setup

### Prerequisites
- Docker installed on your machine
- Claude Code OAuth token from setup above

### Clone and Run

```bash
# Clone the repository
git clone <repository-url>
cd claude-code-sdk-container

# Copy and edit the .env file (NO QUOTES in values!)
cp .env.example .env
# Edit .env and add your actual tokens (without quotes)

# Build the Docker image (uses directory name for uniqueness)
docker build -t claude-code-$(basename "$(pwd)") .

# Run the container (use --env-file for .env file)
docker run -d --name claude-code-$(basename "$(pwd)") -p 8080:8080 --env-file .env claude-code-$(basename "$(pwd)")

# IMPORTANT: Check if container is actually running!
docker ps | grep claude-code-$(basename "$(pwd)")
# If not visible, check logs:
docker logs claude-code-$(basename "$(pwd)")
```

### Test It's Working

```bash
# Easy way - run the test script:
./test.sh

# Check for SDK updates:
./update.sh

# Or manually test:
# 1. First check health (no auth required) - should return JSON
curl http://localhost:8080/health

# 2. Test query endpoint (WORKING EXAMPLE - copy exactly!)
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{"prompt": "Say hello"}'

# Common mistakes to avoid:
# ❌ Missing quotes around JSON
# ❌ Smart quotes instead of straight quotes
# ❌ Missing -X POST
# ❌ Wrong header format
```

## API Usage

### Authentication
The `/query` endpoint requires an API key. You can provide it in two ways:

```bash
# Option 1: X-API-Key header
curl -H "X-API-Key: your-api-key-here"

# Option 2: Authorization Bearer header
curl -H "Authorization: Bearer your-api-key-here"
```

The health check endpoint (`/health`) is public and doesn't require authentication.

### Health Check (No Auth Required)
```bash
GET http://localhost:8080/health
```

Returns:
```json
{
  "status": "healthy",
  "hasToken": true,
  "sdkLoaded": true,
  "message": "Claude Code SDK API",
  "timestamp": "2025-09-18T23:30:00.000Z"
}
```

### Query Claude (Auth Required)
```bash
POST http://localhost:8080/query
Content-Type: application/json
X-API-Key: your-api-key-here

{
  "prompt": "Your question here",
  "options": {
    "model": "claude-sonnet-4-5"  // optional
  }
}
```

Returns:
```json
{
  "success": true,
  "response": "Claude's response",
  "messageCount": 3,
  "timestamp": "2025-09-18T23:30:00.000Z"
}
```

## Deployment

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  claude-api:
    image: claude-code-$(basename "$(pwd)")
    container_name: claude-code-$(basename "$(pwd)")
    ports:
      - "8080:8080"
    environment:
      - CLAUDE_CODE_OAUTH_TOKEN=${CLAUDE_CODE_OAUTH_TOKEN}
    restart: unless-stopped
```

Then run:
```bash
docker-compose up -d
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `CLAUDE_CODE_OAUTH_TOKEN` | Yes | Your Claude Code OAuth token |
| `CLAUDE_AGENT_SDK_CONTAINER_API_KEY` | No* | API key for endpoint authentication |
| `GITHUB_CLIENT_ID` | Yes** | GitHub App Client ID |
| `GITHUB_CLIENT_SECRET` | Yes** | GitHub App Client Secret |
| `ALLOWED_GITHUB_USERS` | Yes*** | Comma-separated list of allowed GitHub usernames |
| `ALLOWED_GITHUB_ORG` | Yes*** | GitHub organization name for access control |
| `SESSION_SECRET` | No | JWT signing secret (generate with: `openssl rand -hex 32`) |
| `PORT` | No | Server port (default: 8080) |

*If `CLAUDE_AGENT_SDK_CONTAINER_API_KEY` is not set, the `/query` endpoint will be publicly accessible.
**Required only for web CLI access. REST API works without GitHub App authentication.
***At least one of `ALLOWED_GITHUB_USERS` or `ALLOWED_GITHUB_ORG` must be set for security.

### GitHub Access Control

Control who can access the web CLI interface by configuring GitHub allowlists:

```bash
# Allow specific GitHub usernames
ALLOWED_GITHUB_USERS=user1,user2,admin

# Allow users from a GitHub organization
ALLOWED_GITHUB_ORG=mycompany

# Combine both (user must match either usernames OR organization)
ALLOWED_GITHUB_USERS=admin,specialuser
ALLOWED_GITHUB_ORG=mycompany
```

**Access Control Behavior:**
- **At least one allowlist must be configured** - the container will not start without proper access control
- **Case insensitive**: GitHub usernames are normalized to lowercase
- **Organization check**: Currently checks user's public company field (basic implementation)
- **Error response**: Unauthorized users receive `GitHub user not authorized`

**Examples:**
```bash
# Organization-only access
ALLOWED_GITHUB_ORG=mycompany

# Specific users only
ALLOWED_GITHUB_USERS=alice,bob,charlie

# Mixed access (admin + entire organization)
ALLOWED_GITHUB_USERS=admin
ALLOWED_GITHUB_ORG=mycompany
```

**Container Naming**: Each deployment automatically gets a unique container name based on the directory name (e.g., `claude-code-my-project`). This allows multiple deployments without conflicts.

**Note**: For production use with organization membership, consider implementing proper GitHub API calls to check organization membership instead of relying on the public company field.

## Examples

### Multi-Agent Discussion (Built-in Feature)

The `/query` endpoint includes a built-in multi-agent system where two specialized agents discuss user requests:

- **Canadian Agent** 🍁: Friendly, polite, optimistic perspective with Canadian warmth
- **Australian Agent** 🇦🇺: Laid-back, practical, easy-going perspective with Aussie charm

The coordinator agent uses Claude's Task tool to delegate to each subagent, gather their perspectives, and synthesize a comprehensive response.

```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{"prompt": "Help me plan a vacation"}'
```

**Example Response:**
The agents will discuss the request, each providing their unique cultural perspective, followed by a synthesized recommendation combining both viewpoints.

### Python
```python
import requests

response = requests.post('http://localhost:8080/query',
    headers={'X-API-Key': 'your-api-key-here'},
    json={'prompt': 'Explain quantum computing in simple terms'})
print(response.json()['response'])
```

### JavaScript
```javascript
const response = await fetch('http://localhost:8080/query', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': 'your-api-key-here'
  },
  body: JSON.stringify({ prompt: 'Write a haiku about coding' })
});
const data = await response.json();
console.log(data.response);
```

### cURL
```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "prompt": "What is the meaning of life?",
    "options": {
      "model": "claude-sonnet-4-5"
    }
  }' | jq .response
```

### Customizing the Multi-Agent System

The multi-agent implementation is in `server.ts` (lines 197-220). To customize:

1. **Modify agent personalities**: Edit the `prompt` field in each agent definition
2. **Add more agents**: Add new entries to the `agents` object
3. **Change coordination strategy**: Modify the `coordinatedPrompt` to change how agents collaborate
4. **Disable multi-agent**: Remove the `agents` and `coordinatedPrompt` for single-agent responses

**Example: Adding Your Own Agent**

Edit `server.ts` and add to the `agents` object:
```typescript
agents: {
  canadian_agent: { /* existing */ },
  australian_agent: { /* existing */ },
  your_custom_agent: {
    description: "Provides a [personality] perspective on the user's request",
    prompt: `You are a [personality description]. Use expressions like "[phrase1]", "[phrase2]".
Be [characteristics]. Give [type of advice].
Keep your responses concise (2-3 sentences) and always make it clear you're the [name] perspective.`,
    model: 'sonnet' as const
  }
}
```

Then update the `coordinatedPrompt` to include your new agent:
```typescript
const coordinatedPrompt = `The user has sent this request: "${prompt}"

Please coordinate with the canadian_agent, australian_agent, and your_custom_agent subagents...`;
```

**How It Works:**
- The coordinator agent receives the user's query
- Uses Claude's Task tool to delegate to each subagent
- Each subagent provides their unique perspective
- Coordinator synthesizes all responses into a comprehensive answer

**Example Personalities to Try:**
- 🇬🇧 British agent (proper, witty, tea-enthusiast)
- 🇩🇪 German agent (efficient, precise, engineering-focused)
- 🇮🇹 Italian agent (passionate, expressive, food-oriented)
- 🇯🇵 Japanese agent (respectful, detail-oriented, harmony-focused)
- 🤠 Texan agent (bold, entrepreneurial, BBQ-loving)

## Troubleshooting

### Quick Debug Checklist
```bash
# 1. Is container running?
docker ps | grep claude-code

# 2. Check container logs
docker logs claude-code-$(basename "$(pwd)")

# 3. Test health endpoint (should work without auth)
curl http://localhost:8080/health

# 4. Test with your actual API key
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_ACTUAL_KEY_HERE" \
  -d '{"prompt": "test"}'
```

### Common Issues

| Issue | Solution |
|-------|----------|
| **Container exits immediately** | Check logs: `docker logs claude-code-$(basename "$(pwd)")`. Usually bad OAuth token |
| **"Unauthorized - Invalid or missing API key"** | Your API key doesn't match. Check: `docker exec claude-code-$(basename "$(pwd)") env | grep CLAUDE_AGENT_SDK_CONTAINER` |
| **Connection refused on port 8080** | Container not running. Check: `docker ps`. Restart: `docker start claude-code-$(basename "$(pwd)")` |
| **Quotes in environment variables** | Remove ALL quotes from .env file. Docker doesn't strip them! |
| **"unhealthy" status** | OAuth token is wrong. Get correct one with: `claude setup-token` |
| **Works locally but not from other container** | Use `host.docker.internal:8080` instead of `localhost:8080` |
| **Changes to .env not working** | Must restart container: `docker restart claude-code-$(basename "$(pwd)")` |

## Updating Claude Agent SDK

The container includes a specific version of the Claude Agent SDK. To update to the latest version:

```bash
# Run the update script
./update.sh

# This will:
# 1. Check for SDK updates
# 2. Update package if needed
# 3. Rebuild the container
# 4. Restart with new version
```

The update script handles everything automatically, including graceful container restart.

## Technical Details

- **Base Image**: Node.js 22 Alpine (optimized for size)
- **Container Size**: ~331MB
- **Memory Usage**: ~256MB
- **Supported Models**: All Claude Agent SDK models
- **SDK Version**: Locked at build time (use `./update.sh` to update)

## License

MIT

## Credits

Thanks to [cabinlab/claude-code-sdk-docker](https://github.com/cabinlab/claude-code-sdk-docker) for examples on implementing `setup-token` authentication flow.

</details>
