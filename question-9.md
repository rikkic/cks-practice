# Question 9: Suspicious egress investigation

## Scenario
Security monitoring reports pods in `finance` reaching `198.51.100.20`. You must investigate, document the suspected actor, and block the traffic.

## Tasks
- Identify the pod(s) in `finance` initiating outbound connections to `198.51.100.20`.
- Review the API audit log to identify the user who most recently modified those pods.
- Block outbound traffic to external IPs except DNS and internal services.

## Constraints
- Audit log is at `/var/log/kubernetes/audit.log` on the control-plane node.
- Do not delete the deployment.

## Deliverables
- Summary of the suspected actor saved to `/home/ubuntu/answers/q9-audit.txt`.
- NetworkPolicy in `finance` restricting egress as required.
