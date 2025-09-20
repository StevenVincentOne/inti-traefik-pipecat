# Pipecat Traefik Configuration - Setup Guide

This document describes the Pipecat-specific Traefik configuration created to resolve service discovery issues with the Pipecat backend.

## 📁 Directory Structure

```
inti-traefik-pipecat/
├── README.md                    # This documentation
├── traefik-pipecat.yml         # Static Traefik configuration
├── swarm-deploy-pipecat.yml    # Swarm deployment configuration
└── debug/
    ├── test-routing.sh         # Debug script for routing issues
    ├── deploy-pipecat-traefik.sh # Deployment script
    └── rollback-to-original.sh   # Rollback script
```

## 🎯 Problem Statement

**Issue**: PWA gets 404 errors on `/api/v1/health` despite working backend
**Root Cause**: Traefik service discovery failing with "field not found, node: service" errors
**Impact**: External API calls cannot reach the Pipecat backend

## 🔧 Configuration Strategy

### Approach 1: Simplified Routing (Current Implementation)
- **Router Rule**: `Host(inti.intellipedia.ai)` (simple host matching)
- **Service Reference**: `unmute_backend` (Docker service name)
- **WebSocket**: Separate router to avoid conflicts

### Approach 2: Alternative Service References (If Needed)
- **Container Name**: `unmute_backend.1.1t0s3p79u3i31jx125bg3ufve`
- **Direct Port**: Expose container port 8000 directly

### Approach 3: Network-Level Routing (Backup)
- **Bypass Swarm**: Direct container access if service discovery fails
- **Custom Network**: Isolated network for testing

## 🚀 Deployment

### Method 1: Using Debug Script (Recommended)
```bash
cd debug/
chmod +x deploy-pipecat-traefik.sh
./deploy-pipecat-traefik.sh
```

### Method 2: Manual Deployment
```bash
# Copy configuration files
scp -i "$HOME/inti_docs/vast" traefik-pipecat.yml root@159.203.103.160:/root/
scp -i "$HOME/inti_docs/vast" swarm-deploy-pipecat.yml root@159.203.103.160:/root/

# Deploy stack
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker stack deploy -c swarm-deploy-pipecat.yml unmute"
```

## 🧪 Testing

### 1. API Health Check
```bash
curl -s https://inti.intellipedia.ai/api/v1/health
# Expected: {"ok": true, "stt_up": true, "llm_up": true, "tts_up": true}
```

### 2. WebSocket Connection
```bash
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  -H "Sec-WebSocket-Version: 13" \
  https://inti.intellipedia.ai/v1/realtime
# Expected: 101 Switching Protocols
```

### 3. Debug Script
```bash
cd debug/
chmod +x test-routing.sh
./test-routing.sh
```

## 🔍 Debugging

### Check Service Labels
```bash
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 \
  "docker service inspect unmute_backend | grep -A10 'Labels'"
```

### Monitor Traefik Logs
```bash
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 \
  "docker service logs unmute_traefik --tail 20"
```

### Test Internal Connectivity
```bash
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 \
  "docker exec \$(docker ps --filter name=unmute_backend -q) curl -s http://localhost:8000/api/v1/health"
```

## 🔄 Rollback

### Quick Rollback (If Issues Occur)
```bash
cd debug/
chmod +x rollback-to-original.sh
./rollback-to-original.sh
```

### Manual Rollback
```bash
# Stop Pipecat services
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker service rm unmute_backend"

# Deploy original configuration
ssh -i "$HOME/inti_docs/vast" root@159.203.103.160 "docker stack deploy -c swarm-deploy.yml unmute"
```

## 📊 Success Criteria

### ✅ Routing Success
- `/api/v1/health` returns `{"ok": true, ...}` instead of 404
- PWA shows "Backend: Connected" instead of "Backend: Up, but with errors"
- WebSocket connections establish successfully
- No "field not found, node: service" errors in Traefik logs

### ✅ Service Discovery Success
- Traefik logs show successful service discovery
- Router-service linking works without conflicts
- No "Router ws cannot be linked automatically" errors

## 📈 Progress Tracking

### Current Status (September 2025)
- ✅ **Repository Setup**: Pipecat Traefik configuration created
- ✅ **Configuration Files**: Static and deployment configs ready
- ✅ **Debug Tools**: Test and deployment scripts created
- ✅ **Documentation**: Comprehensive setup and troubleshooting guide
- ⏳ **Deployment**: Ready for testing on production server
- ⏳ **Validation**: Need to test routing fixes

### Next Steps
1. **Deploy Configuration**: Use debug script to deploy Pipecat Traefik
2. **Test Endpoints**: Verify `/api/v1/health` and WebSocket connectivity
3. **Monitor Logs**: Check Traefik logs for service discovery success
4. **Troubleshoot**: If issues persist, try alternative service references
5. **Document Results**: Update this guide with findings and solutions

## 🆘 Troubleshooting

### Issue: Still Getting 404 Errors
**Possible Causes:**
1. Service labels not applied correctly
2. Traefik cache not refreshed
3. Network connectivity issues
4. Service discovery timing problems

**Solutions:**
1. Restart Traefik: `docker service update --force unmute_traefik`
2. Check service labels: Verify all routing labels are present
3. Test internal connectivity: Confirm backend responds to internal requests
4. Try alternative service reference: Use container name instead of service name

### Issue: WebSocket Connection Failed
**Possible Causes:**
1. Router conflicts between HTTP and WebSocket
2. Service reference mismatch
3. Port configuration issues
4. SSL/TLS certificate problems

**Solutions:**
1. Separate WebSocket router from HTTP router
2. Verify WebSocket service references same backend
3. Check WebSocket port configuration (8000)
4. Ensure SSL termination is working for WebSocket

### Issue: Traefik Service Discovery Errors
**Possible Causes:**
1. Label syntax errors
2. Service reference format issues
3. Timing problems with service startup
4. Docker Swarm configuration conflicts

**Solutions:**
1. Simplify routing rules (remove complex path matching)
2. Use different service reference formats
3. Add startup delays if timing is an issue
4. Check Docker Swarm network configuration

---

**Repository**: `inti-traefik-pipecat` (Pipecat-specific branch)
**Risk Level**: Low - easy rollback to original configuration
**Timeline**: 1-2 days for testing and validation
**Goal**: Resolve Traefik routing issues to enable PWA connectivity
