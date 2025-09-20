#!/bin/bash

# Traefik Routing Debug Script for Pipecat Backend
# This script helps diagnose Traefik service discovery issues

echo "🔍 Pipecat Traefik Routing Debug"
echo "================================="

# Test 1: Check service status
echo ""
echo "📊 1. Service Status:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service ls"

# Test 2: Check service labels
echo ""
echo "🏷️  2. Backend Service Labels:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service inspect unmute_backend | grep -A20 'Labels'" | head -25

# Test 3: Check Traefik logs for errors
echo ""
echo "🚨 3. Recent Traefik Errors:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service logs unmute_traefik --tail 10" | grep -E "(error|ERROR|field not found|Router.*cannot be linked)"

# Test 4: Test API endpoint
echo ""
echo "🌐 4. API Endpoint Test:"
curl -s https://inti.intellipedia.ai/api/v1/health
echo ""

# Test 5: Check container connectivity
echo "🐳 5. Container Connectivity Test:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker exec \$(docker ps --filter name=unmute_backend -q | head -1) curl -s http://localhost:8000/api/v1/health"
echo ""

# Test 6: Check network configuration
echo "🔗 6. Network Configuration:"
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker network ls | grep unmute"
echo ""

echo "✅ Debug complete. Check results above for issues."
