# Question 6 Answer

## validation
- A ValidatingAdmissionPolicy exists that rejects images without `@sha256:`.
- Policy is bound to namespace `secure`.
- `cosign verify` was run successfully against the specified image.
- Deployment in `secure` uses a digest-pinned image and label `cosign-verified=true`.

## solution
1) Create a ValidatingAdmissionPolicy with CEL expression:
   - Require all container images to contain `@sha256:`.

2) Bind the policy to namespace `secure` using a ValidatingAdmissionPolicyBinding.

3) Verify the image signature:
   - `cosign verify registry.local/secure-app@sha256:...`

4) Create or update the deployment in `secure`:
   - Image uses the digest form.
   - Add label `cosign-verified=true` on the pod template.

5) Validate the deployment is admitted and running.
