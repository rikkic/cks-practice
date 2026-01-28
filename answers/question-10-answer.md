# Question 10 Answer

## validation
- `ResourceQuota` and `LimitRange` exist in `team-a` with specified limits.
- `cicd-sa` can create/update deployments and services in `team-a` only.
- `runtime-sa` can get/list/watch pods and endpoints only.
- `kubectl auth can-i` validates expected permissions and denies others.

## solution
1) Create ResourceQuota (example):
   - `cpu: 2`, `memory: 4Gi`, `pods: 10`.

2) Create LimitRange with defaults (example):
   - default request `cpu: 100m`, `memory: 128Mi`.
   - default limit `cpu: 500m`, `memory: 512Mi`.

3) Create service accounts:
   - `kubectl -n team-a create sa cicd-sa`
   - `kubectl -n team-a create sa runtime-sa`

4) Create Roles and RoleBindings:
   - CI/CD Role: verbs `get,list,watch,create,update,patch,delete` on `deployments,services`.
   - Runtime Role: verbs `get,list,watch` on `pods,endpoints`.

5) Validate:
   - `kubectl auth can-i create deployments -n team-a --as=system:serviceaccount:team-a:cicd-sa`
   - `kubectl auth can-i delete services -n team-a --as=system:serviceaccount:team-a:cicd-sa`
   - `kubectl auth can-i list pods -n team-a --as=system:serviceaccount:team-a:runtime-sa`
   - `kubectl auth can-i create deployments -n team-a --as=system:serviceaccount:team-a:runtime-sa` should be `no`.
