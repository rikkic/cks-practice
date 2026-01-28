# Question 1 Answer

## validation
- `kube-apiserver` runs with `--anonymous-auth=false`.
- `kube-apiserver` runs with `--authorization-mode` including `RBAC`.
- TLS minimum version is set to `VersionTLS12` and cipher suites are explicitly set.
- `kubectl --kubeconfig=/home/ubuntu/auditor.kubeconfig auth can-i list secrets -n kube-system` returns `no` and is saved.
- API server is healthy after manifest update.

## solution
1) Edit `/etc/kubernetes/manifests/kube-apiserver.yaml` and set/ensure flags:
   - `--anonymous-auth=false`
   - `--authorization-mode=Node,RBAC`
   - `--tls-min-version=VersionTLS12`
   - `--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`

2) Save and exit. The kubelet will restart the API server automatically. Confirm it is healthy:
   - `kubectl get --raw /healthz`

3) Validate authz with the provided kubeconfig and capture output:
   - `kubectl --kubeconfig=/home/ubuntu/auditor.kubeconfig auth can-i list secrets -n kube-system | tee /home/ubuntu/answers/q1-authz.txt`

4) If the health check fails, re-open the manifest and fix flag syntax, then re-check.
