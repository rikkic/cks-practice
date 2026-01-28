# Question 7: Image hardening pipeline

## Scenario
You must build a hardened image for a small web app and produce an SBOM.

## Tasks
- Build a minimal image for the app in `/home/ubuntu/q7/app`.
- Ensure the container runs as a non-root user and no package manager exists in the final image.
- Generate an SBOM for the built image and store it locally.

## Constraints
- Tag the image as `registry.local/hardened-web:1.0`.
- Keep the image minimal (multi-stage build recommended).

## Deliverables
- Hardened image built locally.
- SBOM saved to `/home/ubuntu/answers/q7-sbom.json`.
