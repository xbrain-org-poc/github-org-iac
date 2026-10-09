# GitHub organization IaC PoC: Task B

Manage **teams and direct team memberships in a sandbox organization** using Terraform. Organization invitations, organization roles/removal, repositories, and team-to-repository permissions are outside this implementation. Coordinate active organization membership with the separate `identity/` root before planning team memberships.

The provider documentation was checked again on **2026-10-01**. The configuration pins `integrations/github` **6.13.0**, with checksums in `.terraform.lock.hcl`. See [verified provider behavior and permissions](docs/provider-research.md) and [results / live test checklist](docs/team-poc-results.md).

The Vietnamese [Task B scope report](docs/task-b-scope-report-vi.md) separates verified live evidence, remaining work, Task A dependencies, and extensions. The [edge-case test plan](docs/edge-case-test-plan-vi.md) is optional follow-up work after the original Task B lifecycle is complete.

The [Jira live evidence](docs/jira-task-b-live-evidence-vi.md) records the completed create/update/delete and direct-membership add/role/remove flows, including final cleanup verification.

The [team-lead workbook](docs/github-org-iac-future-rollout-vi.xlsx) gives a compact view of Task B scope, verified evidence, IaC versus manual UI trade-offs, a provider/Terraform glossary, and a staged path from PoC to later adoption. Production rollout has not been proven.

## Files

| File | Purpose |
| --- | --- |
| `versions.tf`, `provider.tf` | Terraform/provider constraints and environment-based authentication |
| `variables.tf`, `terraform.tfvars.example` | Sandbox inputs with validated team properties and roles |
| `teams.tf` | Root teams and optional child teams |
| `team-memberships.tf` | Read existing org membership, require active status, manage direct team membership |
| `outputs.tf` | IDs, slugs, URLs, and managed memberships |
| `tests/task-b.tftest.hcl` | Mocked plan tests; no GitHub API calls |
| `docs/` | Research, lifecycle runbook, and evidence status |

This Terraform root was copied from [github-org-iac-po at 85a99fb](https://github.com/phuc-do-v2/github-org-iac-po/tree/85a99fb). Run the commands below from `live/xbrain-org-poc/access/`. Task A now lives in the separate `identity/` root; no Task A resources belong to this state. State is local; modules, CI/CD and a remote backend are not implemented. Keep `.terraform.lock.hcl` in version control; keep state, local variables, plans, tokens, keys, and unredacted evidence out of Git.

## Prerequisites and authentication

- Terraform **1.7+ and below 2.0**; tested locally with 1.16.4. The initial implementation downloaded a checksum-verified copy into ignored `.tools/terraform-1.16.4/`; future clones must install Terraform themselves.
- An existing **sandbox organization**, an owner account to run this PoC, and an existing **active ordinary member** for role tests. A personal repository is insufficient. Accept any org invitation outside this Task B state first.
- A short-lived fine-grained PAT whose resource owner is the sandbox, with organization **Members: read and write**, approved by the organization if required. A classic PAT with **`admin:org`** is the alternative. These permissions can also manage organization membership, so the code deliberately uses only a read-only membership lookup. Repository permissions are unnecessary.
- Prefer an owner for this exercise. GitHub permits some operations by members/maintainers, but creation policy can restrict access; the provider also removes the creating user's default team membership. Organization owners retain administration access.

Permissions were checked against the [team API](https://docs.github.com/en/rest/teams/teams), [membership API](https://docs.github.com/en/rest/teams/members), and [scope definitions](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes). Organization token policies and SSO may require approval/authorization. Do not use a team synchronized from an identity provider for these tests.

PowerShell setup (enter the token at the hidden prompt, never in a command or file):

```powershell
# Only if using the local binary created during implementation:
# $env:Path = (Resolve-Path .tools/terraform-1.16.4).Path + ';' + $env:Path

# Provider 6.x documents that these can override the owner in provider.tf.
Remove-Item Env:GITHUB_OWNER, Env:GITHUB_ORGANIZATION -ErrorAction SilentlyContinue
# This PoC targets github.com, not an inherited Enterprise endpoint.
Remove-Item Env:GITHUB_BASE_URL -ErrorAction SilentlyContinue

$pocToken = Read-Host 'Sandbox GitHub PAT' -AsSecureString
$env:GITHUB_TOKEN = [System.Net.NetworkCredential]::new('', $pocToken).Password
Remove-Variable pocToken

Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit both placeholders in `terraform.tfvars`. Use lowercase usernames. Keep the sandbox organization fixed for the lifetime of this state; never repoint populated state at another organization. Do not print environment variables or enable provider debug logs containing credentials.

## Local checks

These commands do not require GitHub credentials. Initialization downloads the provider; the tests use a mocked provider and run plans only.

```powershell
terraform init -backend=false -input=false
terraform fmt -check -recursive
terraform validate
terraform test
```

Mocked tests verify configuration and guard behavior. They do not establish that a token works, that GitHub accepts changes, or that live drift/import/cleanup works.

## First live plan and apply

```powershell
terraform init -input=false
terraform plan -input=false -out=task-b.tfplan
# Run only after plan succeeds:
terraform show -no-color task-b.tfplan
```

With the single-team example, an empty state, and an active member, the expected changes are **1 team + 1 direct membership**, with no changes or deletions. The historical create flow recorded this result; a new run must verify the target sandbox, exact names, roles, and all resource actions from its own actual output.

**Show and review the plan before every apply. Do not execute destructive changes until their actual plan has been shown and approved.** This includes membership removal, team deletion, and replacements. Applying a saved plan executes it without another interactive confirmation, so it is a separate, deliberate step:

```powershell
# Only after reviewing/approving the exact saved plan above:
terraform apply task-b.tfplan
terraform output
terraform plan -detailed-exitcode
```

Authentication is required again during `apply`, even when using a saved plan. Git Credential Manager credentials are not consumed directly by this provider: ensure `GITHUB_TOKEN` is set in the same terminal before both `plan` and `apply`. A missing token can make the provider fall back to anonymous access and return HTTP 401. Do not persist the token in `terraform.tfvars`, Git configuration, or repository files.

The final plan should exit `0` with no changes (`2` means changes; `1` means an error). Verify the team and direct membership in GitHub UI using the output URL. Keep plans fresh: the org membership guard runs during planning, and a saved plan cannot protect against a user being removed from the org afterward. Do not use `-target` or `-refresh=false` to bypass normal dependencies/checks.

## Task B lifecycle exercise

For each row: edit `terraform.tfvars`, create a fresh saved plan, show it, record the expected/actual actions, and only then apply an approved plan. Verify the UI/API and run a second plan to check convergence. Record outcomes in [team-poc-results.md](docs/team-poc-results.md).

| Flow | Configuration or manual action | Expected plan / verification |
| --- | --- | --- |
| Create | Start with `devops` in the example | Add team and membership; ID/slug/URL visible afterward |
| Update properties | Change description, name, or notification setting while keeping the `devops` key | In-place team update; renaming may change its slug |
| Change visibility | Change a standalone root's privacy between `closed` and `secret` | Team update; nested teams must remain `closed` |
| Add member | Add a second active org login to `members` | Add one direct membership after its read-only org lookup |
| Change team role | Change the ordinary member from `member` to `maintainer`, then back | In-place membership updates; org role unchanged |
| Multiple teams | Uncomment `qa` and use the same ordinary member | Add another team/membership; independent direct memberships |
| Parent/child | Uncomment `tooling` with `parent_key = "devops"` | Parent ID dependency orders child creation; both closed |
| Remove member | Remove one entry from a team's `members` map | Destroy that team membership only; org membership remains |
| Delete team | Remove its map entry (children first if present) | Destroy owned memberships, then team; inspect descendants/access first |
| Team drift | Manually edit a managed team's description in GitHub UI | Normal plan proposes restoring the configured description |
| Membership drift | Manually change/remove a managed ordinary member's direct team role/membership | Plan proposes restoring its configured role/membership |
| Dependency failure | Configure a pending invitee or non-member | Pending fails postcondition; missing user fails lookup; no apply |

Teams use stable map keys. Changing a key changes its Terraform address. Moving a team between root and child categories also changes its address; use a reviewed `moved` block to preserve state identity instead of accepting accidental destroy/create. This PoC supports one child level; arbitrary nested hierarchies are deliberately excluded.

Membership management is additive: manually added, unconfigured users are not removed. Child members inherit access from ancestors and can appear in ancestor membership reads; use two independent roots for the multi-team test and verify **direct** memberships. Do not manage an inherited-only relationship as a separate direct membership. Removing a direct entry may leave inherited access intact. Owners must use `maintainer`; the precondition rejects `member` for an owner.

## Import an existing sandbox team

Choose a disposable existing team. First configure matching name, description, privacy, notification setting, hierarchy, and any direct memberships you intend to own. Obtain its numeric ID from the GitHub REST API (`GET /orgs/ORG/teams/SLUG`) or prior Terraform output; a numeric ID survives renaming.

Create a temporary `imports.tf` with the actual IDs/logins. Import blocks allow reviewing the import and any proposed remote changes together before writing state:

```hcl
import {
  to = github_team.root["devops"]
  id = "1234567" # Replace with the existing team ID.
}

# Include only if this direct membership ALREADY exists and is configured.
import {
  to = github_team_membership.member["devops:existing-test-user"]
  id = "1234567:existing-test-user"
}
```

```powershell
terraform plan -out=task-b-import.tfplan
terraform show -no-color task-b-import.tfplan
# After review: expect only imports, with 0 add/change/destroy.
terraform apply task-b-import.tfplan
terraform plan -detailed-exitcode
```

Stop and reconcile any unexpected update or replacement before applying. Child imports target `github_team.child["tooling"]`; configure/import their parents too. Remove the temporary import blocks after success. Importing a team does not automatically import its memberships; the membership block above handles one explicit pair. Never import the same object into two states.

## Cleanup and evidence

Review live child teams, inherited access, and repository relationships **before** deleting a team. GitHub can cascade parent deletion into unmanaged child teams, which do not appear in Terraform's plan. Team deletion can revoke repository access even though this repo manages no repository resources.

Prefer removing PoC entries from `teams` (use `teams = {}` to remove all owned entries), then plan/show/review/apply as above. If state contains imported teams, they are now owned too: do not delete them just because the PoC is ending.

To retain an imported team while relinquishing management, first back up state outside Git and identify its exact team and direct-membership addresses using `terraform state list`. Remove the corresponding configuration, preview those exact addresses with `terraform state rm -dry-run`, review them, then run the same state command without `-dry-run`. This forgets ownership without deleting the remote objects. Include any managed descendants being relinquished; do not leave a child configured with a missing parent key. Before any apply, make a fresh normal plan and confirm it proposes neither deleting nor recreating the retained objects. Removing configuration alone would propose deletion. Terraform `removed` blocks with `destroy = false` are an alternative for a whole resource declaration, not individual `for_each` instances; see [state removal documentation](https://developer.hashicorp.com/terraform/language/state/remove).

Only when every resource in this local state is approved for deletion:

```powershell
terraform plan -destroy -out=task-b-cleanup.tfplan
terraform show -no-color task-b-cleanup.tfplan
# Only after displaying and approving this destructive plan:
terraform apply task-b-cleanup.tfplan
terraform state list
Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
```

After cleanup, verify the PoC teams are gone and test users still belong to the org. Set `teams = {}` before a final normal plan, otherwise Terraform proposes recreating the deleted resources. No `prevent_destroy` is set because deletion is an explicit PoC flow; the saved-plan review is an operational gate, not an automated approval mechanism.

Keep raw output/screenshots in ignored `docs/evidence/local/` and save only redacted summaries in the results document. Do not commit state, plan binaries/JSON, secrets, or unreviewed logs. Preserve state until cleanup or deliberate handoff is verified.

For production, first complete the live checks. Then evaluate a scoped GitHub App (Members write, approved installation, `app_auth {}` with secrets outside Git), protected shared state and locking, and reviewed changes. Those additions are outside this PoC.
