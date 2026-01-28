# CKS Mock Exam Content

This repo contains a mock CKS exam set with:
- Question prompts
- Answer/solution guides (with validation criteria)
- Setup playbooks (Ansible, localhost)
- Validation scripts
- Supporting files used by playbooks

## Layout
- `question-<n>.md` — exam question text
- `answers/question-<n>-answer.md` — validation criteria + solution
- `question-<n>-setup.yml` — Ansible playbook to set up the lab state
- `question-<n>-validate.sh` — automated validation checks
- `supporting/question-<n>/` — playbook artifacts (YAML, templates, source files)

## Conventions
- Paths in questions/solutions assume `/home/ubuntu` (answers, work dirs).
- Setup playbooks run against **localhost** and may use `become: true` for system paths.
- Some setups intentionally weaken settings to create remediation tasks (e.g., API server/kubelet flags).

## Quick start
1) Run a setup playbook:

```bash
ansible-playbook question-1-setup.yml
```

2) Complete the question in `question-1.md`.
3) Run the validation script:

```bash
./question-1-validate.sh
```

## Notes / Cautions
- Q1, Q2, and Q9 touch system paths (`/etc`, `/var`) and should be run only in a disposable lab.
- Q6 enforces admission via namespace selector only, but misconfiguration can still block workload creation in the target namespace.
- Q8/Q9 use dedicated namespaces with `test-client` pods to keep network policy effects isolated.

## Optional: Batch run
You can run multiple setups manually, or add your own orchestration (e.g., a wrapper playbook).

## Requirements
- `ansible` on the host
- `kubectl` configured for the target cluster
- `cosign` for Q6 (optional)
- `docker` or `podman` + `syft` for Q7 (for building and SBOM)

