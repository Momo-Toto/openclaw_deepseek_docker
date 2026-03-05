# Discord Bot Setup Guide for OpenClaw

This guide provides step-by-step instructions for setting up a Discord bot and connecting it to OpenClaw.

## 📋 Prerequisites

1. **Discord Account** (free)
2. **Discord Server** where you have administrator permissions
3. **OpenClaw** installed and running (see main README.md)

## 🚀 Step-by-Step Setup

### Step 1: Create Discord Application

1. **Go to Discord Developer Portal**:
   - https://discord.com/developers/applications
   - Log in with your Discord account

2. **Create New Application**:
   - Click "New Application" button
   - Enter name: `OpenClaw Assistant` (or your preferred name)
   - Click "Create"

3. **Application Dashboard**:
   - You'll see your new application dashboard
   - Note the "Application ID" - you'll need this later

### Step 2: Create Bot User

1. **Navigate to Bot Section**:
   - Click "Bot" in the left sidebar
   - Click "Add Bot"
   - Click "Yes, do it!"

2. **Configure Bot Settings**:
   - **Username**: `OpenClaw Assistant` (can be changed)
   - **Avatar**: Upload an icon (optional but recommended)
   - **Public Bot**: ✅ Enable (so it can join multiple servers)
   - **Require OAuth2 Code Grant**: ❌ Disable (simpler setup)

3. **Enable Privileged Gateway Intents**:
   - **Presence Intent**: ✅ Enable
   - **Server Members Intent**: ✅ Enable
   - **Message Content Intent**: ✅ Enable
   
   These are required for OpenClaw to function properly.

4. **Copy Bot Token**:
   - Click "Reset Token"
   - Click "Copy" to copy the token
   - **IMPORTANT**: This token is like a password - keep it secret!
   - Add to your `.env` file:
     ```
     DISCORD_TOKEN=your_copied_token_here
     ```

### Step 3: Invite Bot to Your Server

1. **Generate OAuth2 URL**:
   - Go to "OAuth2" → "URL Generator" in left sidebar
   
2. **Select Scopes**:
   - ✅ `bot`
   - ✅ `applications.commands`

3. **Select Bot Permissions**:
   Select the following permissions:
   - **General Permissions**:
     - ✅ `Read Messages/View Channels`
   
   - **Text Permissions**:
     - ✅ `Send Messages`
     - ✅ `Send Messages in Threads`
     - ✅ `Create Public Threads`
     - ✅ `Create Private Threads`
     - ✅ `Embed Links`
     - ✅ `Attach Files`
     - ✅ `Read Message History`
     - ✅ `Mention Everyone`
     - ✅ `Use External Emojis`
     - ✅ `Add Reactions`
     - ✅ `Use Slash Commands`
   
   - **Voice Permissions** (optional):
     - ✅ `Connect`
     - ✅ `Speak` (if you want voice features)

4. **Generate and Copy URL**:
   - Scroll down to see generated URL
   - Click "Copy"
   
5. **Add Bot to Server**:
   - Open the copied URL in your browser
   - Select your server from dropdown
   - Click "Continue"
   - Review permissions and click "Authorize"
   - Complete the CAPTCHA if prompted

### Step 4: Get Discord IDs

1. **Enable Developer Mode in Discord**:
   - Open Discord app
   - Go to Settings → Advanced
   - Enable "Developer Mode"

2. **Get Server ID**:
   - Right-click your server icon
   - Click "Copy ID"
   - Save this ID

3. **Get Channel ID**:
   - Right-click the channel where you want OpenClaw to respond
   - Click "Copy ID"
   - Save this ID

### Step 5: Configure OpenClaw for Discord

1. **Update `openclaw.json`**:
   Open `openclaw.json` and update the Discord configuration:

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
             },
             "ANOTHER_CHANNEL_ID_HERE": {
               "allow": true
             }
           }
         }
       }
     }
   }
   ```

   Replace:
   - `YOUR_SERVER_ID_HERE` with your server ID
   - `YOUR_CHANNEL_ID_HERE` with your channel ID
   - Add more channels as needed

2. **Restart OpenClaw**:
   ```bash
   docker-compose restart
   ```

### Step 6: Test Discord Connection

1. **Check Bot Status**:
   - Go to your Discord server
   - Check if "OpenClaw Assistant" is online in member list

2. **Send Test Message**:
   - In the configured channel, type: `@OpenClaw Assistant hello`
   - Or just: `hello` (if bot is configured to respond to all messages)
   
3. **Expected Response**:
   - Bot should respond within a few seconds
   - First response might be slower as models load

### Step 7: Advanced Configuration (Optional)

#### Multiple Channels Configuration
To allow bot in multiple channels:
```json
"channels": {
  "YOUR_CHANNEL_ID_1": {
    "allow": true
  },
  "YOUR_CHANNEL_ID_2": {
    "allow": true
  },
  "YOUR_CHANNEL_ID_3": {
    "allow": false  // Explicitly deny
  }
}
```

#### Direct Messages Configuration
To allow bot to respond to DMs:
```json
"groupPolicy": "allowlist",
"dmPolicy": "allow"  // Allow direct messages
```

#### Rate Limiting Configuration
To adjust rate limits:
```json
"rateLimits": {
  "messagesPerMinute": 60,
  "burstSize": 10
}
```

## 🐛 Troubleshooting Discord Issues

### Bot Not Appearing Online
1. **Check Token**:
   ```bash
   # Verify token in .env file
   grep DISCORD_TOKEN .env
   ```

2. **Check OpenClaw Logs**:
   ```bash
   docker-compose logs openclaw | grep -i discord
   ```

3. **Verify Bot is Added to Server**:
   - Check server member list
   - Re-invite bot if necessary

### Bot Not Responding to Messages
1. **Check Channel Configuration**:
   - Verify channel ID in `openclaw.json`
   - Ensure channel is in the allowlist

2. **Check Permissions**:
   - Bot needs "Read Messages" and "Send Messages" permissions
   - Check channel-specific permissions

3. **Check Intents**:
   - Ensure "Message Content Intent" is enabled in Developer Portal

### Bot Responding Slowly
1. **Check OpenClaw Resources**:
   ```bash
   docker stats
   ```

2. **Check DeepSeek API**:
   - API might be experiencing high load
   - Check DeepSeek status page

3. **Adjust Rate Limits**:
   - Reduce message frequency if needed

### Error Messages in Logs
Common errors and solutions:

1. **"Invalid token"**:
   - Regenerate bot token in Developer Portal
   - Update `.env` file

2. **"Missing permissions"**:
   - Re-invite bot with correct permissions
   - Check channel-specific permissions

3. **"Rate limited"**:
   - Wait a few minutes
   - Adjust rate limits in configuration

## 🔒 Security Best Practices

### Token Security
1. **Never share your bot token**
2. **Never commit `.env` file to version control**
3. **Regenerate token if compromised**
4. **Use different tokens for development and production**

### Permission Management
1. **Use minimal required permissions**
2. **Regularly audit bot permissions**
3. **Remove bot from unused servers**
4. **Monitor bot activity logs**

### Server Security
1. **Limit bot to specific channels**
2. **Use allowlist instead of blocklist**
3. **Monitor for unusual bot activity**
4. **Set up audit logs for bot actions**

## 🔄 Maintenance

### Regular Tasks
1. **Update Bot Token** (every 90 days recommended)
2. **Review Bot Permissions** (monthly)
3. **Check Rate Limits** (as needed)
4. **Monitor Discord API Changes**

### Bot Token Rotation
1. **Generate new token** in Developer Portal
2. **Update `.env` file**
3. **Restart OpenClaw**:
   ```bash
   docker-compose restart
   ```

### Backup Configuration
```bash
# Backup Discord configuration
cp .env ~/openclaw-backup/.env-discord-backup-$(date +%Y%m%d)
cp openclaw.json ~/openclaw-backup/openclaw-discord-backup-$(date +%Y%m%d).json
```

## 📚 Additional Resources

### Discord Developer Resources
- [Discord Developer Portal](https://discord.com/developers)
- [Discord API Documentation](https://discord.com/developers/docs)
- [Discord Developer Server](https://discord.gg/discord-developers)

### OpenClaw Discord Integration
- [OpenClaw Discord Documentation](https://docs.openclaw.ai/channels/discord)
- [OpenClaw Discord Examples](https://github.com/openclaw/openclaw/tree/main/examples/discord)

### Community Support
- [OpenClaw Discord Community](https://discord.gg/clawd)
- [Discord Developers Community](https://discord.gg/discord-developers)

## 🆘 Getting Help

If you encounter issues:

1. **Check Logs**:
   ```bash
   docker-compose logs openclaw --tail=100
   ```

2. **Verify Configuration**:
   - Check `.env` file has correct token
   - Check `openclaw.json` has correct server/channel IDs

3. **Ask for Help**:
   - OpenClaw Discord: https://discord.gg/clawd
   - Create GitHub issue: https://github.com/Momo-Toto/openclaw_deepseek/issues

Include in your help request:
- Error messages from logs
- Your configuration (redact tokens)
- Steps to reproduce the issue