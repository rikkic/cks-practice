# Question 2 Answer

## validation
- Kubelet has `readOnlyPort: 0` (or equivalent flag) and authn/authz enabled.
- `/etc/kubernetes` owned by root and not world-readable (e.g., dir 700, files 600).
- Kubelet client certificate rotated (new mtime or new cert serial).
- Kubelet is healthy and node is `Ready`.

## solution
1) On `worker1`, check kubelet config (prefer `/var/lib/kubelet/config.yaml`):
   - Set `readOnlyPort: 0`
   - Ensure `authentication: {anonymous: {enabled: false}, webhook: {enabled: true}}`
   - Ensure `authorization: {mode: Webhook}`

2) If using systemd flags, update the drop-in under `/etc/systemd/system/kubelet.service.d/` with equivalent `--read-only-port=0`, `--anonymous-auth=false`, `--authentication-token-webhook=true`, `--authorization-mode=Webhook`.

3) Fix permissions:
   - `sudo chown -R root:root /etc/kubernetes`
   - `sudo chmod 700 /etc/kubernetes`
   - `sudo chmod 600 /etc/kubernetes/*`

4) Rotate kubelet client certs:
   - Remove the client cert symlink and restart kubelet:
     - `sudo rm -f /var/lib/kubelet/pki/kubelet-client-current.pem`
     - `sudo systemctl restart kubelet`
   - Confirm a new cert is created in `/var/lib/kubelet/pki/`.

5) Validate:
   - `kubectl get nodes` shows `worker1` is `Ready`.
