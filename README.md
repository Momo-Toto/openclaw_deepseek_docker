# OpenClaw DeepSeek Configuration

This repository contains Docker and OpenClaw configuration files for running OpenClaw with DeepSeek AI models.

## 📁 Files Included

### Core Configuration
- `docker-compose.yml` - Docker Compose configuration for OpenClaw
- `Dockerfile` - Docker image definition
- `openclaw.json` - OpenClaw main configuration file
- `.env.example` - Environment variables template (copy to `.env` and fill in your values)

### Installation Scripts
- `install-ubuntu.sh` - Automated installation script for Ubuntu
- `DISCORD_SETUP.md` - Complete Discord bot setup guide

### Security Notes
- **Never commit `.env` file** - Contains sensitive API keys and tokens
- **Never commit `device.json` with private keys** - Contains cryptographic keys
- Use `.env.example` as a template for your environment variables

## 🚀 Complete Installation Guide

### Quick Installation (Recommended)
For automated installation on Ubuntu:
```bash
# Download and run installation script
curl -O https://raw.githubusercontent.com/Momo-Toto/openclaw_deepseek/main/install-ubuntu.sh
chmod +x install-ubuntu.sh
./install-ubuntu.sh
```

### Manual Installation

#### Prerequisites
- Ubuntu 20.04 LTS or newer
- Minimum 4GB RAM (8GB recommended)
- 20GB free disk space
- Stable internet connection

### Step 1: Ubuntu System Setup

#### 1.1 Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
```

#### 1.2 Install Docker and Docker Compose
```bash
# Install Docker
sudo apt install -y docker.io docker-compose

# Add your user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker $USER

# Apply group changes (log out and back in, or use this workaround)
newgrp docker

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker --version
docker-compose --version
```

#### 1.3 Install Git (if not already installed)
```bash
sudo apt install -y git
```

### Step 2: Clone and Setup OpenClaw

#### 2.1 Clone Repository
```bash
git clone https://github.com/Momo-Toto/openclaw_deepseek.git
cd openclaw_deepseek
```

#### 2.2 Create Environment File
```bash
cp .env.example .env
```

### Step 3: Configure API Keys and Tokens

#### 3.1 Get DeepSeek API Key
1. Go to: https://platform.deepseek.com/api-keys
2. Sign up or log in to DeepSeek
3. Create a new API key
4. Copy the key and add to `.env`:
   ```
   DEEPSEEK_API_KEY=sk-your-deepseek-api-key-here
   ```

#### 3.2 Generate Secure Gateway Token
```bash
# Generate a secure random token
openssl rand -base64 32
```
Add the generated token to `.env`:
```
OPENCLAW_GATEWAY_TOKEN="your-generated-secure-token-here"
```

#### 3.3 Set GitHub Token (Optional)
If you want GitHub integration:
1. Go to: https://github.com/settings/tokens
2. Generate new token with "repo" scope
3. Add to `.env`:
   ```
   GITHUB_TOKEN=your_github_token_here
   ```

### Step 4: Discord Bot Setup and Connection

For complete Discord setup instructions, see: [DISCORD_SETUP.md](DISCORD_SETUP.md)

#### Quick Discord Setup:
1. **Create Discord Bot**:
   - Go to: https://discord.com/developers/applications
   - Create new application → Add bot → Enable intents
   - Copy bot token to `.env` file

2. **Invite Bot to Server**:
   - Generate OAuth2 URL with `bot` and `applications.commands` scopes
   - Add required permissions
   - Authorize bot in your server

3. **Get Channel IDs**:
   - Enable Developer Mode in Discord settings
   - Right-click channel → "Copy ID"
   - Update `openclaw.json` with your server and channel IDs

#### Detailed Guide:
See [DISCORD_SETUP.md](DISCORD_SETUP.md) for step-by-step instructions with screenshots and troubleshooting.

### Step 5: Configure OpenClaw for Discord

#### 5.1 Update OpenClaw Configuration
Edit `openclaw.json` to configure Discord channels:

```json
"channels": {
  "discord": {
    "enabled": true,
    "token": "${DISCORD_TOKEN}",
    "groupPolicy": "allowlist",
    "streaming": "off",
    "guilds": {
      "YOUR_SERVER_ID_HERE": {
        "channels": {
          "YOUR_CHANNEL_ID_HERE": {
            "allow": true
          }
        }
      }
    }
  }
}
```

To find your server ID:
1. Right-click your server icon in Discord
2. Click "Copy ID"

#### 5.2 Test Discord Connection
After starting OpenClaw, the bot should:
- Appear online in your Discord server
- Respond to messages in allowed channels

### Step 6: Start OpenClaw

#### 6.1 Build and Start Containers
```bash
# Build Docker image
docker-compose build

# Start OpenClaw in background
docker-compose up -d

# Check logs
docker-compose logs -f
```

#### 6.2 Verify Installation
```bash
# Check if container is running
docker-compose ps

# Check OpenClaw logs
docker-compose logs openclaw
```

#### 6.3 Access OpenClaw Web UI
- Open browser: http://localhost:18789
- Use gateway token from `.env` file
- You should see the OpenClaw control panel

### Step 7: Initial Setup and Testing

#### 7.1 Connect to OpenClaw
1. **Open Web UI**: http://localhost:18789
2. **Enter Gateway Token**: From your `.env` file
3. **You should see**: OpenClaw dashboard with agent status

#### 7.2 Test Discord Integration
1. **Go to your Discord server**
2. **Send a message** in the configured channel
3. **OpenClaw should respond** (may take a moment on first run)

#### 7.3 Test DeepSeek Integration
1. **In Discord**, mention the bot or send a direct message
2. **Ask a question**: "Hello, can you help me?"
3. **Bot should respond** using DeepSeek AI

### Step 8: Configure Automation (Optional)

#### 8.1 Set Up Cron Jobs
OpenClaw can run automated tasks. Example cron jobs are pre-configured in the system for:
- Daily sci-fi story generation
- Daily neuroscience updates
- Daily OpenClaw use cases fetching

#### 8.2 Monitor Automation
```bash
# View cron job status
docker-compose exec openclaw openclaw cron list

# Run a job manually
docker-compose exec openclaw openclaw cron run [job-id]
```

## 🔧 Configuration Details

### Docker Compose (`docker-compose.yml`)
- Runs OpenClaw in a secure container
- Maps port 18789 for web access
- Mounts configuration directory
- Uses environment variables from `.env` file
- Security features: no-new-privileges, dropped capabilities

### OpenClaw Configuration (`openclaw.json`)
- **Models**: Configured for DeepSeek Chat and DeepSeek Reasoner
- **Gateway**: Runs on port 18789, binds to LAN
- **Channels**: Discord integration enabled
- **Agents**: Default model set to DeepSeek Chat

### Docker Image (`Dockerfile`)
- Based on Node 24 Bookworm Slim
- Includes: git, curl, python3, scientific libraries
- Installs OpenClaw globally
- Runs as non-root `node` user for security

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Docker Permission Errors
```bash
# If you get "permission denied" for Docker:
sudo chmod 666 /var/run/docker.sock
# Or better, ensure user is in docker group:
sudo usermod -aG docker $USER
# Log out and back in, or run:
newgrp docker
```

#### 2. Port Already in Use
```bash
# Check what's using port 18789
sudo lsof -i :18789

# Change port in docker-compose.yml:
# ports:
#   - "18790:18789"  # Change first number
```

#### 3. Discord Bot Not Responding
1. **Check Bot Status**:
   - Is the bot online in Discord?
   - Does it have proper permissions in the channel?

2. **Verify Token**:
   ```bash
   # Check if token is set correctly
   grep DISCORD_TOKEN .env
   ```

3. **Check OpenClaw Logs**:
   ```bash
   docker-compose logs openclaw | grep -i discord
   ```

4. **Verify Channel Configuration**:
   - Ensure channel ID is correct in `openclaw.json`
   - Check server ID matches your Discord server

#### 4. DeepSeek API Errors
1. **Check API Key**:
   ```bash
   # Verify API key is set
   grep DEEPSEEK_API_KEY .env
   ```

2. **Test API Key**:
   ```bash
   curl -X POST https://api.deepseek.com/v1/chat/completions \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello"}]}'
   ```

3. **Check Rate Limits**:
   - DeepSeek has rate limits
   - Wait a few minutes if you get rate limit errors

#### 5. Container Won't Start
```bash
# Check Docker logs
docker-compose logs

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### 6. Web UI Not Accessible
1. **Check Container Status**:
   ```bash
   docker-compose ps
   ```

2. **Check Port Binding**:
   ```bash
   # Verify port is bound
   netstat -tulpn | grep 18789
   ```

3. **Check Firewall**:
   ```bash
   # If using UFW firewall
   sudo ufw allow 18789/tcp
   ```

#### 7. Environment Variables Not Loading
```bash
# Check if .env file exists and is readable
ls -la .env

# Check file permissions
chmod 600 .env

# Verify variables are loaded
docker-compose config | grep -A5 -B5 "environment:"
```

## 🔄 Maintenance and Updates

### Regular Maintenance Tasks

#### 1. Update OpenClaw
```bash
# Stop containers
docker-compose down

# Pull latest OpenClaw
docker-compose pull

# Start with new version
docker-compose up -d

# Check version
docker-compose exec openclaw openclaw --version
```

#### 2. Backup Configuration
```bash
# Create backup of important files
mkdir -p ~/openclaw-backup
cp -r .env docker-compose.yml openclaw.json ~/openclaw-backup/
tar -czf ~/openclaw-backup-$(date +%Y%m%d).tar.gz ~/openclaw-backup/
```

#### 3. Monitor Resource Usage
```bash
# Check container resource usage
docker stats

# Check disk usage
docker system df

# Clean up unused containers and images
docker system prune -a
```

#### 4. Log Management
```bash
# View recent logs
docker-compose logs --tail=100

# Follow logs in real-time
docker-compose logs -f

# Clear old logs (if growing too large)
docker-compose logs --tail=0
```

### Security Maintenance

#### 1. Rotate API Tokens
- **Discord Token**: Regenerate every 90 days
- **Gateway Token**: Change periodically
- **DeepSeek API Key**: Monitor for unusual usage

#### 2. Update Docker Images
```bash
# Update base images
docker-compose pull

# Rebuild with security updates
docker-compose build --no-cache
```

#### 3. Audit Permissions
```bash
# Check file permissions
ls -la .env docker-compose.yml openclaw.json

# Ensure .env is not world-readable
chmod 600 .env
```

### Performance Optimization

#### 1. Increase Resources (if needed)
Edit `docker-compose.yml`:
```yaml
services:
  openclaw:
    # Add resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

#### 2. Optimize Docker Performance
```bash
# Clean Docker cache
docker system prune -a --volumes

# Check for large images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

## 📊 Monitoring and Alerts

### Basic Monitoring Setup

#### 1. Health Check Script
Create `health-check.sh`:
```bash
#!/bin/bash
# Check if OpenClaw is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ OpenClaw is running"
else
    echo "❌ OpenClaw is not running"
    # Send alert (example with curl to webhook)
    # curl -X POST YOUR_WEBHOOK_URL -d "OpenClaw is down"
fi
```

#### 2. Log Monitoring
```bash
# Monitor for errors in logs
docker-compose logs --tail=100 | grep -i "error\|fail\|exception"

# Set up log rotation in docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

#### 3. Resource Monitoring
```bash
# Monitor CPU and memory
docker stats --no-stream

# Check disk space for logs
df -h /var/lib/docker
```

## 🆘 Getting Help

### Common Support Channels

1. **OpenClaw Documentation**: https://docs.openclaw.ai
2. **Discord Community**: https://discord.gg/clawd
3. **GitHub Issues**: https://github.com/openclaw/openclaw/issues

### Diagnostic Information to Provide
When asking for help, include:
```bash
# System information
docker --version
docker-compose --version
uname -a

# OpenClaw information
docker-compose exec openclaw openclaw --version

# Configuration (redact sensitive info)
cat docker-compose.yml
cat openclaw.json | head -50

# Logs (last 100 lines)
docker-compose logs --tail=100
```

### Emergency Recovery

#### 1. Complete Reset
```bash
# Stop and remove everything
docker-compose down -v
docker system prune -a --volumes

# Start fresh
docker-compose up -d
```

#### 2. Restore from Backup
```bash
# Stop current instance
docker-compose down

# Restore configuration
cp ~/openclaw-backup/.env .
cp ~/openclaw-backup/openclaw.json .

# Restart
docker-compose up -d
```

## 🔐 Security Considerations

### Environment Variables
- Store all sensitive data in `.env` file
- Never commit `.env` to version control
- Use different tokens for development and production

### Docker Security
- Container runs with minimal privileges
- Capabilities dropped except CHOWN, SETGID, SETUID
- No new privileges allowed
- Runs as non-root user

### OpenClaw Security
- Gateway requires authentication token
- Device pairing uses public-key cryptography
- Channel access controlled via allowlists

## 📊 Cron Jobs Configuration

The system includes automated cron jobs for:
1. **Daily Sci-Fi Novel Generation** - 13:00 UTC (7:00 AM local)
2. **Daily Neuroscience Updates** - 13:30 UTC (7:30 AM local)
3. **Daily OpenClaw Use Cases** - 12:00 UTC (6:00 AM local)

Cron jobs are configured in `cron/jobs.json` and automatically post to Discord channels.

## 🔄 Updates

To update OpenClaw:
```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Change port in docker-compose.yml
   ports:
     - "18790:18789"  # Change first number
   ```

2. **Missing environment variables**
   - Ensure `.env` file exists and is properly formatted
   - Check all required variables are set

3. **Docker permission issues**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   ```

4. **API key errors**
   - Verify API keys are valid and have correct permissions
   - Check rate limits on DeepSeek API

## 📝 License

This configuration is provided as-is for educational and personal use.

## 🙏 Acknowledgments

- [OpenClaw](https://openclaw.ai) - Automation platform
- [DeepSeek](https://deepseek.com) - AI models
- [Docker](https://docker.com) - Container platform

---

**Maintained by**: Momo-Toto  
**Last Updated**: March 5, 2026