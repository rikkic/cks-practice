# Question 3: Namespace RBAC and service account hygiene

## Scenario
The `dev` namespace needs least-privilege access for the app team. Default service account token mounts must be disabled.

## Tasks
- Create a Role and RoleBinding that allows the `dev` team service account to read pods and services only.
- Disable auto-mounting of the default service account token in `dev`.
- Prove access using `kubectl auth can-i`.

## Constraints
- Use namespace `dev` and service account `app-sa`.
- Do not grant cluster-wide permissions.

## Deliverables
- RBAC objects created in `dev`.
- Default service account token auto-mount disabled.
- Save auth check output to `/home/ubuntu/answers/q3-can-i.txt`.
