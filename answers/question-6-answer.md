# Question 6 Answer

## validation
- A ValidatingAdmissionPolicy named `require-image-digest-secure` rejects images without `@sha256:`.
- Policy is bound **only** to namespace `secure` via namespace selector.
- `cosign verify` was run successfully against the specified image.
- Deployment in `secure` uses a digest-pinned image and label `cosign-verified=true`.

## solution
1) Create a ValidatingAdmissionPolicy named `require-image-digest-secure` with CEL expression:
   - Require all container images to contain `@sha256:`.

2) Bind the policy with `require-image-digest-secure-binding` using a namespace selector.
   - Example selector label: `cks-lab=question-6` on the `secure` namespace.

3) Verify the image signature:
   - `cosign verify registry.local/secure-app@sha256:...`

4) Create or update the deployment in `secure`:
   - Image uses the digest form.
   - Add label `cosign-verified=true` on the pod template.

5) Validate the deployment is admitted and running.
