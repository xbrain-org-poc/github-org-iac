# Task B results: teams and team membership

Date: **2026-10-01**. Scope: completed live lifecycle required by Task B in sandbox organization `xbrain-org-poc`: create/update/delete team and add/update-role/remove direct team membership. Drift, import, nesting, remote state, and production automation remain extensions.

## Scope boundary

This is the result record for **Task B – Org Teams**. It manages teams and direct team memberships only. Organization invitation, organization-role update, and organization-member removal belong to **Task A – Org Members (Hoàng)** and are not implemented here. `data.github_membership.existing` is a read-only prerequisite check; it is not an organization-member lifecycle resource.

See the concise Vietnamese [scope and result report](task-b-scope-report-vi.md) for the original ownership split, verified evidence, overclaim corrections, and remaining completion steps.

## Local evidence

| Check | Result |
| --- | --- |
| Current provider documentation | Verified official Registry/provider and GitHub API docs; [research and sources](provider-research.md) |
| Terraform runtime | 1.16.4, Windows amd64; downloaded into ignored `.tools/` and SHA256 checked against HashiCorp release checksums |
| Provider initialization | Passed: `terraform init -backend=false -input=false`; integrations/github 6.13.0, partner signature verified; `.terraform.lock.hcl` generated |
| Formatting | Passed: `terraform fmt -check -recursive` |
| Schema validation | Passed: `terraform validate` |
| Mocked safety tests | Passed: `terraform test -no-color` reported **12 passed, 0 failed**; every run uses `command = plan` and a mocked GitHub provider |
| Git exclusions | Verified local tfvars, state/backups, saved plans, token/key files, tooling, and raw local evidence are ignored; source example and lock file remain trackable |
| Live plan/apply | Passed create, in-place update, membership add/role/remove, delete, API/state verification, and no-change plans after every flow |

The Terraform ZIP SHA256 was `5c736ed6b0f13e98bc5029fe159574cca33634c3477466c56442c28b513a7054`. Tool downloads and Terraform init did not mutate a GitHub organization. Mocked tests verify Terraform behavior only and are not live lifecycle evidence.

The 12 tests cover active/pending membership, both owner-role outcomes, distinct addresses for a shared username across teams with one org lookup, invalid roles/privacy, secret parents/children, missing parents, unsupported deeper nesting, and an empty desired configuration. [Test source](../tests/task-b.tftest.hcl).

## Live run record

Recorded sandbox fields follow. Use the [runbook procedure](../RUNBOOK.md) for any repeat run and attach redacted evidence rather than credentials, state, or saved plan files. This historical evidence came from [the source PoC](https://github.com/phuc-do-v2/github-org-iac-po/tree/85a99fb); consolidation did not perform a new live apply.

- Sandbox organization: `xbrain-org-poc`
- Runner login / authorization method and permission names (no token): `phuc-do-v2`, active organization owner (`admin`); Git Credential Manager credential injected into process-local `GITHUB_TOKEN`; exact token scopes not recorded
- Ordinary active test member: `phuc776`, organization role `member`
- Tested source revision: [`722938e` in the source repo](https://github.com/phuc-do-v2/github-org-iac-po/commit/722938e); ignored local tfvars represented each reviewed lifecycle step
- Team identity: created as `poc-devops`, updated in place to `poc-infra-maintainers`, numeric ID remained `19806617`, then deleted; no import performed

For every applied step, record the date, plan summary, reviewer/approval, redacted plan/apply output, UI/API observation, and subsequent no-change plan. A failed step should include the error and recovery without marking later dependent steps successful.

| Flow | Expected result | Actual result / evidence |
| --- | --- | --- |
| Create team + direct membership | Example: 2 adds; team/member visible; follow-up plan has no changes | Passed: saved plan showed 2 adds/0 changes/0 destroys; apply created team `19806617` and owner membership; GitHub API returned privacy `closed`, membership `active`, role `maintainer`; follow-up plan had no changes |
| Update description/name/notifications | In-place update; numeric team ID preserved | Passed: plan 0 add/1 change/0 destroy; apply preserved ID `19806617`, changed slug and notification setting; API/state matched; next plan exit `0` |
| Privacy change on standalone team | `closed`/`secret` update; expected visibility | Not run |
| Add existing active member | One new direct membership; org lookup precedes membership operation | Passed: `phuc776` added with team role `member`; API kept organization role `member`; next plan exit `0` |
| Change ordinary member role | `member` -> `maintainer`; stable org membership | Passed: relationship updated in place; API returned team role `maintainer` and organization role `member`; next plan exit `0` |
| Same user in two independent teams | Two distinct direct memberships | Not run |
| Parent/child creation | Child created with managed parent's ID; both closed | Not run |
| Remove direct membership | One membership destroy; org membership remains active | Passed: plan/apply destroyed only `devops:phuc776`; team lookup returned 404 while org membership stayed `active/member`; next plan exit `0` |
| Delete disposable team | Team/memberships removed; descendants/access reviewed first | Passed after reviewed fresh plan: 0 add/0 change/2 destroy; owner direct membership removed before team ID `19806617` |
| Manual team drift | Normal plan detects changed description and proposes restoration | Not run |
| Manual membership drift | Normal plan detects changed role or removal | Not run |
| Team import | Reviewed import only, no unintended update/replacement; then no-change plan | Not run |
| Direct membership import | Reviewed pair import only; then no-change plan | Not run |
| Pending invitee / outsider | Plan fails safely; no invitation is sent by this configuration | Partially passed live: outsider lookup returned 404 and plan exit `1` without mutation; pending state was not tested |
| Owner role guard | Owner requested as member is rejected; maintainer is allowed | Partially passed live: GitHub confirmed org role `admin`, and configured `maintainer` applied successfully; rejected `member` path remains mock-tested only |
| Final cleanup | Only approved PoC resources removed; state empty and org members retained | Passed: team API returned 404; state list empty; `phuc-do-v2` remained `active/admin`; `phuc776` remained `active/member`; final plan exit `0` |

## Limitations and conclusion

Current docs and provider source support the required team lifecycle. This implementation adds read-only active-org-member checks, owner-role validation, explicit parent/team dependencies, and additive direct membership management. The required live create/update/delete and direct-membership add/role/remove flows succeeded.

**Can the lifecycle be safely and predictably managed?** Yes for the tested Task B minimum lifecycle in this sandbox, provided every destructive plan is reviewed and each apply is followed by API/state and no-change verification. This evidence does not cover nested-team side effects, import, drift recovery, IdP-synchronized teams, concurrent admins, or production controls.

Plan-time membership checks have a race with later org changes; regenerate plans promptly. Extra unconfigured memberships remain unmanaged, inherited access may persist after direct removal, parent deletion can cascade beyond state, and root/child address changes require deliberate state migration. IdP-synchronized teams and organization-member lifecycle are outside scope. See [verified behavior](provider-research.md).

Authentication observation: applying a saved plan still requires provider credentials. An initial apply attempt without `GITHUB_TOKEN` failed with HTTP 401 before creating resources. Git Credential Manager is not an automatic authentication source for the Terraform provider; injecting its credential into process-local `GITHUB_TOKEN` allowed the approved plan to apply. No token was written to configuration, state documentation, or Git.

Conclusion for the original task: Task B's required team lifecycle is complete in the sandbox. Organization-member invitation/removal belongs to Task A. Production controls remain future recommendations outside this PoC result. See [Jira evidence](jira-task-b-live-evidence-vi.md).
