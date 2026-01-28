# Question 4: Pod Security restricted remediation

## Scenario
A deployment in namespace `payments` fails admission under the `restricted` Pod Security Standard. Remediate the workload to comply with restricted policy.

## Tasks
- Identify why the deployment fails under PSS `restricted`.
- Update the deployment to comply:
  - run as non-root
  - drop all Linux capabilities
  - use `RuntimeDefault` seccomp
  - set read-only root filesystem and add a writable volume for `/tmp`

## Constraints
- Do not change the container image.
- Keep the application functional on port 8080.

## Deliverables
- Deployment is admitted and available under PSS `restricted`.
