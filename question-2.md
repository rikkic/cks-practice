# Question 2: Kubelet hardening end-to-end

## Scenario
A worker node was found with weak kubelet settings and overly permissive file permissions. You must harden the kubelet and rotate client credentials.

## Tasks
- Verify and set secure kubelet flags (read-only port disabled, auth enabled, webhook authorization).
- Fix ownership and permissions for `/etc/kubernetes` and its contents.
- Rotate kubelet client certificates after suspected exposure.

## Constraints
- Work on node `worker1`.
- Use the kubelet config file if present; otherwise use the systemd drop-in.
- Avoid disrupting running workloads beyond the kubelet restart.

## Deliverables
- Kubelet secure settings applied and active.
- `/etc/kubernetes` permissions hardened.
- Kubelet client certs rotated and kubelet healthy.
