# Question 5: Privileged workload incident response

## Scenario
A privileged container is running in the `prod` namespace and mounts host paths. Your task is to enforce policy and remediate the workload.

## Tasks
- Enforce Pod Security `restricted` for the `prod` namespace.
- Update the `legacy-logger` deployment to remove privileged mode and hostPath usage.
- Ensure the workload still runs and writes logs to a writable path.

## Constraints
- Do not delete the deployment; update in-place.
- Do not change the container image.

## Deliverables
- `prod` namespace enforces `restricted`.
- `legacy-logger` runs without privileged or hostPath settings and is available.
