# Question 5 Answer

## validation
- Namespace `prod` has Pod Security labels enforcing `restricted`.
- `legacy-logger` pods do not use `privileged: true`.
- No `hostPath` volumes exist in the deployment.
- Workload is running and available after changes.

## solution
1) Label the `prod` namespace for PSS enforcement:
   - `kubectl label ns prod pod-security.kubernetes.io/enforce=restricted --overwrite`

2) Edit the deployment to remove privileged and hostPath:
   - Remove `securityContext.privileged: true` from the container.
   - Replace `hostPath` with `emptyDir` or a PVC if required.
   - Ensure log path is writable (e.g., mount `emptyDir` at `/var/log/app`).

3) Apply changes and check rollout:
   - `kubectl -n prod rollout status deploy/legacy-logger`

4) Confirm pods are running under restricted policy.
