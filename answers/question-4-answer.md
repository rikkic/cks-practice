# Question 4 Answer

## validation
- Namespace `payments` enforces PSS `restricted` (or admission is configured accordingly).
- Deployment pods run as non-root with `runAsNonRoot: true` and `runAsUser` set.
- `securityContext.capabilities.drop` includes `ALL` and `allowPrivilegeEscalation: false`.
- `seccompProfile.type` is `RuntimeDefault`.
- Root filesystem is read-only and `/tmp` is writable via a volume.

## solution
1) Inspect the failing deployment events to identify violations:
   - `kubectl -n payments describe deploy payments`

2) Patch or edit the deployment pod spec:
   - `securityContext` on the container:
     - `runAsNonRoot: true`
     - `runAsUser: 10001`
     - `allowPrivilegeEscalation: false`
     - `readOnlyRootFilesystem: true`
     - `capabilities: { drop: ["ALL"] }`
     - `seccompProfile: { type: RuntimeDefault }`

3) Add a writable volume for `/tmp`:
   - `volumes: [{ name: tmp, emptyDir: {} }]`
   - `volumeMounts: [{ name: tmp, mountPath: /tmp }]`

4) Apply the change and wait for rollout:
   - `kubectl -n payments rollout status deploy/payments`

5) Confirm pods are running and admitted.
