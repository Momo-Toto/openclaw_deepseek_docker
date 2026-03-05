#!/bin/bash

# OpenClaw DeepSeek Ubuntu Installation Script
# This script automates the installation of OpenClaw with DeepSeek on Ubuntu

set -e  # Exit on error

echo "========================================="
echo "OpenClaw DeepSeek Ubuntu Installation"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please do not run this script as root/sudo."
    echo "   Run as a regular user and use sudo when prompted."
    exit 1
fi

# Check Ubuntu version
echo "🔍 Checking system requirements..."
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "20.04" && "$UBUNTU_VERSION" != "22.04" && "$UBUNTU_VERSION" != "24.04" ]]; then
    echo "⚠️  Warning: This script is tested on Ubuntu 20.04, 22.04, and 24.04."
    echo "   Your version: Ubuntu $UBUNTU_VERSION"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check RAM
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 4 ]; then
    echo "⚠️  Warning: Minimum 4GB RAM recommended. You have ${TOTAL_RAM}GB."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ System check passed"
echo ""

# Step 1: Update system packages
echo "📦 Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y
echo "✅ System updated"
echo ""

# Step 2: Install Docker
echo "🐳 Step 2: Installing Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt install -y docker.io
else
    echo "Docker already installed: $(docker --version)"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose already installed: $(docker-compose --version)"
fi

# Add user to docker group
if ! groups $USER | grep -q '\bdocker\b'; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "⚠️  You need to log out and back in for group changes to take effect."
    echo "   For now, we'll use newgrp as a workaround..."
    newgrp docker << EOF
    echo "Continuing in new shell..."
EOF
fi

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
echo "✅ Docker installed and configured"
echo ""

# Step 3: Install Git
echo "📚 Step 3: Installing Git..."
if ! command -v git &> /dev/null; then
    sudo apt install -y git
else
    echo "Git already installed: $(git --version)"
fi
echo "✅ Git installed"
echo ""

# Step 4: Clone repository
echo "📥 Step 4: Cloning OpenClaw repository..."
if [ -d "openclaw_deepseek" ]; then
    echo "Repository already exists. Updating..."
    cd openclaw_deepseek
    git pull
else
    git clone https://github.com/Momo-Toto/openclaw_deepseek.git
    cd openclaw_deepseek
fi
echo "✅ Repository cloned/updated"
echo ""

# Step 5: Setup environment
echo "⚙️  Step 5: Setting up environment..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "Created .env file from template"
        echo ""
        echo "========================================="
        echo "⚠️  IMPORTANT: You need to edit .env file"
        echo "========================================="
        echo ""
        echo "Required changes:"
        echo "1. Get DeepSeek API key from: https://platform.deepseek.com/api-keys"
        echo "2. Generate secure gateway token: openssl rand -base64 32"
        echo "3. Get Discord bot token from: https://discord.com/developers/applications"
        echo ""
        echo "Edit .env file with: nano .env"
        echo ""
        read -p "Press Enter when you've updated .env file..."
    else
        echo "❌ Error: .env.example not found!"
        exit 1
    fi
else
    echo ".env file already exists"
fi
echo "✅ Environment setup complete"
echo ""

# Step 6: Generate secure tokens if needed
echo "🔐 Step 6: Generating secure tokens..."
if grep -q "your-secure-gateway-token-here" .env 2>/dev/null; then
    echo "Generating secure gateway token..."
    NEW_TOKEN=$(openssl rand -base64 32)
    sed -i "s|your-secure-gateway-token-here|$NEW_TOKEN|g" .env
    echo "✅ Generated new gateway token"
fi
echo "✅ Token generation complete"
echo ""

# Step 7: Build and start OpenClaw
echo "🚀 Step 7: Building and starting OpenClaw..."
echo "This may take a few minutes on first run..."
docker-compose build
docker-compose up -d
echo "✅ OpenClaw started"
echo ""

# Step 8: Verify installation
echo "🔍 Step 8: Verifying installation..."
sleep 10  # Give containers time to start

echo "Checking container status..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Containers are running"
else
    echo "❌ Containers are not running. Checking logs..."
    docker-compose logs --tail=20
    exit 1
fi

echo "Checking OpenClaw logs..."
if docker-compose logs openclaw 2>&1 | grep -q "Gateway listening"; then
    echo "✅ OpenClaw gateway is running"
else
    echo "⚠️  OpenClaw may still be starting up. Check logs with: docker-compose logs -f openclaw"
fi
echo ""

# Step 9: Display access information
echo "========================================="
echo "🎉 Installation Complete!"
echo "========================================="
echo ""
echo "📊 Access Information:"
echo "----------------------"
echo "🌐 Web UI: http://localhost:18789"
echo "🔑 Gateway Token: Check your .env file (OPENCLAW_GATEWAY_TOKEN)"
echo ""
echo "📝 Next Steps:"
echo "-------------"
echo "1. Open browser to: http://localhost:18789"
echo "2. Enter your gateway token"
echo "3. Configure Discord bot in your server"
echo "4. Test the system by sending a message in Discord"
echo ""
echo "🛠️  Useful Commands:"
echo "------------------"
echo "• View logs: docker-compose logs -f"
echo "• Stop OpenClaw: docker-compose down"
echo "• Start OpenClaw: docker-compose up -d"
echo "• Restart OpenClaw: docker-compose restart"
echo "• Check status: docker-compose ps"
echo ""
echo "📚 Documentation:"
echo "---------------"
echo "• Full guide: README.md in this directory"
echo "• OpenClaw docs: https://docs.openclaw.ai"
echo "• Discord setup: See README.md for detailed instructions"
echo ""
echo "⚠️  Important Security Notes:"
echo "---------------------------"
echo "• Keep your .env file secure (contains API keys)"
echo "• Never commit .env to version control"
echo "• Regularly update OpenClaw: docker-compose pull"
echo "• Monitor logs for unusual activity"
echo ""
echo "💝 Need Help?"
echo "------------"
echo "• Check troubleshooting section in README.md"
echo "• Join OpenClaw Discord: https://discord.gg/clawd"
echo "• Create GitHub issue: https://github.com/Momo-Toto/openclaw_deepseek/issues"
echo ""
echo "========================================="
echo "Installation script completed successfully!"
echo "========================================="