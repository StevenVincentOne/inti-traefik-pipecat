#!/bin/bash

# Rollback to Original Traefik Configuration
# This script reverts to the original working Traefik configuration

echo "🔄 Rolling Back to Original Traefik Configuration"
echo "================================================"

# Step 1: Stop current services
echo ""
echo "🛑 1. Stopping current services..."
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service rm unmute_backend"
echo "✅ Backend service stopped"

# Step 2: Deploy original configuration
echo ""
echo "📦 2. Deploying original configuration..."
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "cd /root && docker stack deploy -c swarm-deploy.yml unmute"
echo "✅ Original stack deployed"

# Step 3: Check status
echo ""
echo "📊 3. Checking service status..."
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service ls"

# Step 4: Test original endpoints
echo ""
echo "🧪 4. Testing original endpoints..."
echo "Frontend:"
curl -s -I https://inti.intellipedia.ai/ | head -1
echo ""

echo "API Health (if original backend):"
curl -s https://inti.intellipedia.ai/api/health
echo ""

# Step 5: Check logs
echo ""
echo "📋 5. Traefik logs after rollback:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service logs unmute_traefik --tail 5"

echo ""
echo "✅ Rollback complete! Original configuration restored."
echo ""
echo "🔍 If issues persist, check:"
echo "   - Service discovery logs: docker service logs unmute_traefik"
echo "   - Container logs: docker service logs unmute_backend"
echo "   - Network connectivity: docker network inspect unmute-net"
