# Question 10: Multi-tenant controls

## Scenario
Team A needs resource limits and separate identities for CI/CD and runtime access.

## Tasks
- Apply ResourceQuota and LimitRange to the `team-a` namespace.
- Create service accounts `cicd-sa` and `runtime-sa`.
- Grant least-privilege permissions: CI/CD can manage deployments and services; runtime can read pods and endpoints only.

## Constraints
- Namespace is `team-a`.
- Do not grant cluster-wide permissions.

## Deliverables
- Quota and limits enforced.
- RBAC configured for both service accounts.
- Validation commands show correct permissions.
