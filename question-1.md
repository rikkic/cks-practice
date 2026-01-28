# Question 1: API server hardening and authz validation

## Scenario
A security review found that the control plane allows anonymous requests and uses weak TLS defaults. You must harden the API server and prove RBAC is enforced.

## Tasks
- Disable anonymous authentication and ensure RBAC authorization is enabled.
- Enforce TLS minimum version 1.2 and a secure cipher suite list on the API server.
- Prove a restricted user cannot list secrets in `kube-system`.

## Constraints
- Work on the control-plane node.
- Do not change cluster certificates beyond what is required for TLS flags.
- Use the existing `auditor` kubeconfig at `/home/ubuntu/auditor.kubeconfig` for the authz check.

## Deliverables
- Update the API server manifest so the changes persist after restart.
- Save the result of the authorization check to `/home/ubuntu/answers/q1-authz.txt`.
