#!/bin/bash

# Deploy Pipecat Traefik Configuration
# This script deploys the Pipecat-specific Traefik configuration

echo "🚀 Deploying Pipecat Traefik Configuration"
echo "=========================================="

# Step 1: Copy configuration files to server
echo ""
echo "📁 1. Copying configuration files..."
scp -i "$HOME/inti_docs/vast" ../traefik-pipecat.yml root@159.203.103.160:/root/
scp -i "$HOME/inti_docs/vast" ../swarm-deploy-pipecat.yml root@159.203.103.160:/root/

echo ""
echo "✅ Configuration files copied to server"

# Step 2: Deploy the stack
echo ""
echo "🐳 2. Deploying Pipecat stack..."
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "cd /root && docker stack deploy -c swarm-deploy-pipecat.yml unmute"

echo ""
echo "✅ Stack deployment initiated"

# Step 3: Check deployment status
echo ""
echo "📊 3. Checking deployment status..."
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service ls"

# Step 4: Test the endpoints
echo ""
echo "🧪 4. Testing endpoints..."
echo "API Health Check:"
curl -s https://inti.intellipedia.ai/api/v1/health
echo ""

echo "WebSocket Check:"
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" -H "Sec-WebSocket-Version: 13" https://inti.intellipedia.ai/v1/realtime | head -1
echo ""

# Step 5: Check Traefik logs
echo ""
echo "📋 5. Recent Traefik logs:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service logs unmute_traefik --tail 5"

echo ""
echo "🎉 Deployment complete! Check results above."
