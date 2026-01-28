# Question 8: Network security lockdown

## Scenario
The `netpol` namespace must be locked down. Only specific ingress and egress should be allowed.

## Tasks
- Implement default-deny for all ingress and egress in `netpol`.
- Allow ingress to the `api` deployment on TCP 8080 only from pods in the same namespace.
- Allow egress only to DNS and the external IP `203.0.113.10` on TCP 443.

## Constraints
- Use NetworkPolicy only.
- Do not modify the deployments or services.

## Deliverables
- NetworkPolicies applied and connectivity validated with test pods.
