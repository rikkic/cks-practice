# Question 6: Admission control and supply chain enforcement

## Scenario
Your cluster must only admit images pinned by digest and verified by the security team.

## Tasks
- Create a ValidatingAdmissionPolicy that rejects pods with images lacking a digest (`@sha256:`).
- Verify the image signature for `registry.local/secure-app@sha256:...` using `cosign`.
- Only deploy the workload after verification, adding a label `cosign-verified=true` to the pod template.

## Constraints
- Use namespace `secure` and deployment name `secure-app`.
- Do not disable admission or bypass policy.

## Deliverables
- Admission policy in place.
- Deployment created with digest-pinned image and verification label.
