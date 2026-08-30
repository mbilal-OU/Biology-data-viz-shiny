# Deployment guide

## Hosted platforms

Use `rsconnect::deployApp()` for shinyapps.io or Posit Connect after configuring
credentials outside the repository. Set memory limits, instance counts,
idle-timeout policy, and access control for the expected data sensitivity.

## Container

```bash
docker compose up --build
```

The application is then available at `http://localhost:3838`. The compose file
uses a read-only container filesystem with temporary writable mounts.

## Production checklist

- Terminate TLS at a trusted reverse proxy.
- Add authentication before accepting non-public data.
- Store secrets in the platform secret manager or environment variables.
- Define request, upload, CPU, memory, and session limits.
- Emit structured operational logs without identifiers or sensitive values.
- Monitor startup, latency, error rate, saturation, and dependency health.

