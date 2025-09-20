# Inti Traefik - Pipecat Branch

Traefik configuration specifically adapted for the Pipecat backend migration. This branch contains experimental routing configurations to resolve service discovery issues.

## Overview

This is a **Pipecat-specific Traefik configuration** forked from the main Inti Traefik configuration to resolve routing issues with the Pipecat backend.

## Current Issues Being Addressed

### 🔴 Service Discovery Problem
- **Issue**: Traefik shows `ERR error="field not found, node: service"`
- **Impact**: PWA gets 404 errors on `/api/v1/health` despite working backend
- **Root Cause**: Service discovery failing to link router to backend service

### 🔴 Router-Service Linking
- **Issue**: `ERR Router ws cannot be linked automatically with multiple Services`
- **Impact**: WebSocket routing conflicts between different service configurations
- **Root Cause**: Multiple services competing for same router configuration

## Configuration Strategy

### Approach 1: Simplified Routing
```yaml
# Simple host-based routing
traefik.http.routers.backend.rule: "Host(inti.intellipedia.ai)"
traefik.http.services.backend.loadbalancer.server.service: "unmute_backend"
```

### Approach 2: Alternative Service Reference
```yaml
# Using container name format
traefik.http.services.backend.loadbalancer.server.service: "unmute_backend.1.1t0s3p79u3i31jx125bg3ufve"
```

### Approach 3: Direct Container Access
```yaml
# Bypass Swarm routing if needed
traefik.http.services.backend.loadbalancer.server.port: "8000"
```

## Files

- `traefik-pipecat.yml` - Static configuration with Pipecat-specific settings
- `swarm-deploy-pipecat.yml` - Swarm deployment with corrected routing labels
- `README.md` - This documentation
- `debug/` - Debugging configurations and test scripts

## Testing

### Health Check
```bash
curl -s https://inti.intellipedia.ai/api/v1/health
# Should return: {"ok": true, "stt_up": true, "llm_up": true, "tts_up": true}
```

### WebSocket Test
```bash
curl -I -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" -H "Sec-WebSocket-Version: 13" https://inti.intellipedia.ai/v1/realtime
# Should return 101 Switching Protocols
```

## Rollback Plan

If Pipecat branch causes issues:

1. **Stop Pipecat Services**: `docker service rm unmute_backend`
2. **Deploy Original**: Use original Traefik configuration
3. **Restore Original Backend**: Deploy original `inti-groq-backend:v2.0.17`

## Next Steps

1. **Test Approach 1**: Try simplified routing rules
2. **Test Approach 2**: Try alternative service references
3. **Test Approach 3**: Try direct container access if needed
4. **Document Results**: Update this README with findings
5. **Merge Back**: If successful, merge changes to main branch

---

**Branch Purpose**: Resolve Traefik routing issues for Pipecat backend
**Risk Level**: Low - can easily rollback to original configuration
**Timeline**: 1-2 days for testing and validation
**Success Criteria**: PWA can successfully connect to `/api/v1/health` and WebSocket
