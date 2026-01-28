# Question 8 Answer

## validation
- Default-deny NetworkPolicy exists for ingress and egress in `netpol`.
- Ingress to `api` allowed only from same namespace on 8080.
- Egress allowed only to kube-dns and `203.0.113.10:443`.
- Test pods confirm allowed and denied traffic as specified.

## solution
1) Create a default-deny policy:
   - `policyTypes: [Ingress, Egress]` with empty ingress/egress.

2) Create an ingress-allow policy targeting `api` pods:
   - `podSelector` matching `app=api`.
   - `from` with `podSelector: {}` (same namespace).
   - `ports: 8080/TCP`.

3) Create an egress-allow policy:
   - Allow DNS to kube-system `k8s-app=kube-dns` on 53/UDP and 53/TCP.
   - Allow egress to `203.0.113.10/32` on 443/TCP.

4) Validate using a temporary test pod in `netpol` (e.g., `kubectl run tmp --rm -it --image=busybox -- sh`).
