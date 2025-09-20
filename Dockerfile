# Custom Traefik Image with Pipecat Configuration
FROM traefik:v3.3.1

# Copy static configuration
COPY traefik-pipecat.yml /etc/traefik/traefik-static.yml

# Copy dynamic configuration (if any)
COPY dynamic.yml /etc/traefik/dynamic.yml

# Set labels for identification
LABEL maintainer="Intellipedia <steve@intellipedia.ai>"
LABEL version="3.3.1-pipecat"
LABEL description="Traefik with Pipecat-specific configuration for Inti project"

# Expose ports
EXPOSE 80 443 8080
