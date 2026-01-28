# Question 6: Admission control and supply chain enforcement

## Scenario
Your cluster must only admit images pinned by digest and verified by the security team.

## Tasks
- Create a **namespace-scoped** ValidatingAdmissionPolicy named `require-image-digest-secure` that rejects pods with images lacking a digest (`@sha256:`).
- Bind the policy using a namespace selector (avoid cluster-wide `matchResources`) with a binding named `require-image-digest-secure-binding`.
- Verify the image signature for `registry.local/secure-app@sha256:...` using `cosign`.
- Only deploy the workload after verification, adding a label `cosign-verified=true` to the pod template.

## Constraints
- Use namespace `secure` and deployment name `secure-app`.
- Scope admission **only** to `secure` via namespace selector.
- Do not disable admission or bypass policy.

## Deliverables
- Admission policy in place, bound only to `secure`.
- Deployment created with digest-pinned image and verification label.
