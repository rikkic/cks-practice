# Question 9 Answer

## validation
- Summary file `/home/ubuntu/answers/q9-audit.txt` exists with user identity and action.
- NetworkPolicy restricts egress from `finance-q9` to DNS and internal cluster only.
- External egress to `198.51.100.20` is blocked.

## solution
1) Identify suspect pods:
   - `kubectl -n finance-q9 get pods -o wide`
   - Check logs or sidecar configs to confirm egress target.

2) Audit log review:
   - On control-plane: `rg 'finance-q9' /var/log/kubernetes/audit.log | rg 'patch|update|create' | tail -n 50`
   - Extract user info for the most recent change.
   - Save a brief summary to `/home/ubuntu/answers/q9-audit.txt`.

3) Apply an egress-restricting NetworkPolicy in `finance-q9`:
   - Default-deny egress.
   - Allow only kube-dns (UDP/TCP 53) and in-cluster destinations as required.

4) Validate the block by attempting to connect to `198.51.100.20` from a pod and confirm it fails.
