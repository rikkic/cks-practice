# Question 8: Network security lockdown

## Scenario
The `netpol-q8` namespace is dedicated to this task and contains only test workloads. It must be locked down so only specific ingress and egress are allowed.

## Tasks
- Implement default-deny for all ingress and egress in `netpol-q8`.
- Allow ingress to the `api` deployment on TCP 8080 only from pods in the same namespace.
- Allow egress only to DNS and the external IP `203.0.113.10` on TCP 443.
- A `test-client` pod already exists in the namespace for connectivity checks.

## Constraints
- Use NetworkPolicy only.
- Do not modify the deployments or services.

## Deliverables
- NetworkPolicies applied and connectivity validated with the `test-client` pod.
