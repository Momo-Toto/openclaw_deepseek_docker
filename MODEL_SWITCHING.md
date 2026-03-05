# Model Switching Guide

Quick reference for switching between DeepSeek Chat and DeepSeek Reasoner models in OpenClaw.

## 📋 Available Models

| Model | ID | Reasoning | Context | Best For |
|-------|----|-----------|---------|----------|
| **DeepSeek Chat** | `deepseek/deepseek-chat` | No | 128K | General chat, quick responses |
| **DeepSeek Reasoner** | `deepseek/deepseek-reasoner` | Yes | 128K | Complex tasks, coding, reasoning |

## 🔄 Switching Methods

### Method 1: Change Default (Permanent)
Edit `openclaw.json`:
```json
"agents": {
  "defaults": {
    "model": "deepseek/deepseek-reasoner",  // Change from deepseek-chat to deepseek-reasoner
    // ... rest of config
  }
}
```
Then restart:
```bash
docker-compose restart
```

### Method 2: Command Switch (Temporary)

#### In Discord/Web UI:
```
/model deepseek/deepseek-reasoner
/model deepseek/deepseek-chat
/status  # Check current model
```

#### Via Docker:
```bash
# Switch to Reasoner
docker-compose exec openclaw openclaw session model deepseek/deepseek-reasoner

# Switch to Chat
docker-compose exec openclaw openclaw session model deepseek/deepseek-chat

# Check status
docker-compose exec openclaw openclaw session status
```

### Method 3: Per-Task Model Selection

```bash
# Sub-agent with specific model
docker-compose exec openclaw openclaw sessions spawn \
  --runtime subagent \
  --model deepseek/deepseek-reasoner \
  "Complex task requiring reasoning"

# ACP session with specific model
docker-compose exec openclaw openclaw sessions spawn \
  --runtime acp \
  --model deepseek/deepseek-reasoner \
  "Coding task"
```

## ⚡ Quick Commands Cheat Sheet

```bash
# One-liner to switch to Reasoner
docker-compose exec openclaw openclaw models set deepseek/deepseek-reasoner && echo "Switched to DeepSeek Reasoner"

# One-liner to switch to Chat (default)
docker-compose exec openclaw openclaw models set deepseek/deepseek-chat && echo "Switched to DeepSeek Chat (default)"

# Current model info
docker-compose exec openclaw openclaw models status | grep -i "Default\|model"
```

## 🎯 When to Use Each Model

### Use **DeepSeek Chat** (default) when:
- Casual conversation
- Quick answers
- Simple queries
- General information
- Cost-sensitive tasks
- Faster response needed
- **Default setting** - provides fast, efficient responses

### Use **DeepSeek Reasoner** when:
- Solving complex problems
- Writing or debugging code
- Mathematical calculations
- Logical reasoning tasks
- Detailed analysis
- Chain-of-thought needed
- When you need enhanced reasoning capabilities

## 🔧 Troubleshooting

### Model not switching?
1. Check model ID is correct: `deepseek/deepseek-reasoner` or `deepseek/deepseek-chat`
2. Verify the model is configured in `openclaw.json`
3. Restart OpenClaw if using permanent change: `docker-compose restart`

### Getting API errors?
1. Ensure your DeepSeek API key has access to both models
2. Check rate limits (Reasoner may have different limits)
3. Verify API endpoint in configuration

### Performance issues?
- Reasoner is slower but more accurate for complex tasks
- Chat is faster for simple queries
- Consider switching based on task complexity

## 📊 Monitoring Model Usage

```bash
# Check session logs for model usage
docker-compose logs openclaw | grep -i "model\|reasoner"

# Monitor API calls
docker-compose exec openclaw openclaw models status
```

## 🔄 Reverting Changes

To revert to original configuration:
```bash
# Restore original openclaw.json
git checkout openclaw.json

# Restart OpenClaw
docker-compose restart
```

## 🧪 Testing Model Switch

To verify your model switch worked:

1. **Check current model**:
   ```bash
   docker-compose exec openclaw openclaw models status
   ```

2. **Test with a reasoning question** (for Reasoner):
   ```bash
   docker-compose exec openclaw openclaw sessions spawn \
     --runtime subagent \
     --model deepseek/deepseek-reasoner \
     "Solve this math problem step by step: If a train travels 60 mph for 2 hours, then 40 mph for 3 hours, what is the average speed?"
   ```

3. **Compare responses** between models for the same question to see the difference in reasoning detail.

4. **Monitor logs** for model usage:
   ```bash
   docker-compose logs openclaw --tail=50 | grep -i "model\|using\|reason"
   ```

---

**Last Updated**: March 5, 2026  
**OpenClaw Version**: 2026.2.26  
**DeepSeek Models**: V3.2