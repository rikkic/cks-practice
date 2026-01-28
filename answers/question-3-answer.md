# Question 3 Answer

## validation
- A `Role` in `dev` grants only `get,list,watch` on `pods` and `services`.
- A `RoleBinding` binds the role to `system:serviceaccount:dev:app-sa`.
- The `default` service account in `dev` has `automountServiceAccountToken: false`.
- `kubectl auth can-i` for the app SA returns `yes` for read-only and does not have write permissions.

## solution
1) Create the role:
   - `kubectl -n dev create role app-readonly --verb=get,list,watch --resource=pods,services`

2) Bind it to `app-sa`:
   - `kubectl -n dev create rolebinding app-readonly-binding --role=app-readonly --serviceaccount=dev:app-sa`

3) Disable token auto-mount on the default SA:
   - `kubectl -n dev patch serviceaccount default -p '{"automountServiceAccountToken": false}'`

4) Validate access and save output:
   - `kubectl auth can-i list pods -n dev --as=system:serviceaccount:dev:app-sa | tee /home/ubuntu/answers/q3-can-i.txt`

5) Optional sanity check:
   - `kubectl auth can-i create deployments -n dev --as=system:serviceaccount:dev:app-sa` should be `no`.
