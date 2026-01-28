# Question 7 Answer

## validation
- Image `registry.local/hardened-web:1.0` exists locally.
- Image runs as non-root (USER set to a non-root uid).
- No package manager present in the final image layers.
- SBOM file exists at `/home/ubuntu/answers/q7-sbom.json`.

## solution
1) Create a multi-stage Dockerfile:
   - Build stage uses a full base image to compile/bundle.
   - Final stage uses a minimal base (distroless/scratch) and copies artifacts only.

2) Ensure the final stage sets a non-root USER (e.g., `USER 10001`).

3) Build the image:
   - `docker build -t registry.local/hardened-web:1.0 /home/ubuntu/q7/app`

4) Verify no package manager:
   - `docker run --rm registry.local/hardened-web:1.0 which apt || true`

5) Generate SBOM (tool provided, e.g., syft):
   - `syft registry.local/hardened-web:1.0 -o json > /home/ubuntu/answers/q7-sbom.json`
