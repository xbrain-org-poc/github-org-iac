# Provider research for Task B

Verified **2026-10-01** against `integrations/github` **6.13.0** (Registry release date: 2026-07-08). The [Registry metadata](https://registry.terraform.io/v1/providers/integrations/github) identified this version as latest at verification time. Live Task B results are recorded separately.

## Resources and scope

| Resource | Verified behavior |
| --- | --- |
| [`github_team`](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/team.md) | Required `name`; optional `description`, `privacy`, `notification_setting`, `parent_team_id`; exports numeric `id`, `node_id`, and `slug`. Privacy defaults to `secret`; notifications default to enabled. This PoC explicitly chooses `closed`. `ldap_dn` is for Enterprise Server and is outside this sandbox exercise. |
| [`github_team_membership`](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/team_membership.md) | One team/user relationship with role `member` or `maintainer` (default `member`). Accepts a team ID or slug. Do not combine with authoritative `github_team_members` management for the same team. |
| [`github_membership`](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/resources/membership.md) | Organization roles are `member` and `admin` (owner). Apply sends an invitation for an unaffiliated GitHub username; destroy cancels a pending invite or removes an active member unless `downgrade_on_destroy` changes owner-removal behavior. It is feasible for Task A but is **not implemented** in Task B. |

The implementation uses read-only [`data.github_membership.existing`](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/data-sources/membership.md) once per distinct username. Its inputs are `username` and optional `organization`; it returns organization `role` (`admin`/`member`) and `state` (`active`/`pending`). A missing membership fails the lookup. A lifecycle postcondition requires `active`, blocking pending invitations before membership writes. A team-membership precondition requires an organization admin to have team role `maintainer`. This avoids Task A mutations and does not scan organization-wide members or repositories.

## Authentication and authorization

The [provider authentication documentation](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/docs/index.md) supports PAT/OAuth tokens through `GITHUB_TOKEN`, GitHub App installation authentication through `app_auth`, and a GitHub CLI fallback. App environment variables require an `app_auth {}` block; `GITHUB_APP_PEM_FILE` contains key contents, not a filename. Keep secrets outside Terraform configuration and committed files.

Version 6.13.0 documents an owner precedence bug: `GITHUB_OWNER`, and the deprecated `GITHUB_ORGANIZATION`/`organization` settings, can override the configured `owner`. Clear inherited organization/owner overrides before operating on the selected sandbox.

| Credential / operation | Required authorization |
| --- | --- |
| Classic PAT, full team lifecycle | `admin:org`; includes organization/team/membership administration. Repository scopes are unnecessary for this scope. |
| Fine-grained PAT or GitHub App, team and membership writes | Organization **Members: write**; these REST endpoints support App user tokens, App installation tokens, and fine-grained PATs. |
| Read teams and organization/team membership | Organization **Members: read** for fine-grained/App credentials. |
| User creates team | Org member or owner; org policy may restrict creation to owners. |
| User updates/deletes team or adds/updates membership | Org owner or team maintainer. Removal requires org owner or team administration permission. |

Sources: [scope definitions](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps#available-scopes), [team REST endpoints](https://docs.github.com/en/rest/teams/teams), [team membership REST endpoints](https://docs.github.com/en/rest/teams/members), [organization membership read endpoint](https://docs.github.com/en/rest/orgs/members#get-organization-membership-for-a-user).

## Inviting an external user

IaC invitation is feasible in two forms:

1. **Recommended boundary:** Task A owns `github_membership` with `username` and organization role. Apply sends the org invitation; subsequent reads report `pending` until the user accepts. Task B depends on the active membership before adding the user to a team.
2. **Coupled invitation:** GitHub's team-membership API also allows an organization owner to add a non-member to a team, which sends an organization invitation and leaves the team membership pending. This PoC intentionally blocks that implicit path with a read-only active-member prerequisite so Task B never owns organization invitations.

Both paths require an owner-capable credential and organization **Members: write** for a fine-grained PAT/GitHub App, or `admin:org` for a classic PAT. Email-only invitation is not exposed by provider 6.13.0 `github_membership`; it accepts an existing GitHub username.

Use an owner token for the initial sandbox run. Owner status is not universally required by GitHub's API. GitHub initially adds a creating user as team maintainer, but the [6.13.0 provider implementation](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/resource_github_team.go) removes the default creating membership during creation unless deprecated `create_default_maintainer` is true. This PoC omits that deprecated option and manages memberships explicitly. An owner retains administration rights after this removal.

## Lifecycle, hierarchy, and drift

- Team membership PUT can invite a non-org user when performed by an owner. Membership stays pending until acceptance. Org owners are reported as team `maintainer`, so use a normal org member for `member`/`maintainer` tests. IdP-synchronized memberships cannot be changed directly through these APIs. See [membership API behavior](https://docs.github.com/en/rest/teams/members).
- Parent and child teams must be `closed`; secret teams cannot be nested. Each child has one parent. Deleting a parent as an org owner also deletes its children. Review unmanaged children and existing repository access before deletion: Terraform's plan cannot describe resources outside its state. See [nested teams](https://docs.github.com/en/organizations/organizing-members-into-teams/about-teams#nested-teams) and [delete-team behavior](https://docs.github.com/en/rest/teams/teams#delete-a-team).
- Source inspection shows team property updates use the update endpoint, and refresh reads configured properties. A missing team clears its state ID, allowing a later plan to propose recreation. Renaming can change the slug; numeric IDs provide stable references. See [team implementation](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/resource_github_team.go).
- Membership role updates are in-place; changing the team or username replaces the relationship. Refresh reads role and detects a missing relationship. This resource manages only its specified user/team pair: extra manually added memberships remain unmanaged. The sandbox confirmed add, in-place role update, remove, API/state verification, and convergence for `phuc776`. See [membership implementation](https://github.com/integrations/terraform-provider-github/blob/v6.13.0/github/resource_github_team_membership.go).
- Team import accepts a numeric team ID or name; membership import accepts `teamid:username` or `teamname:username`. Prefer numeric IDs, configure matching attributes first, then review the resulting plan. Import itself does not prove the configuration matches the remote object. See the linked resource documentation above.

Live create/update/delete and membership evidence is recorded in `team-poc-results.md`. Drift, import, nested-team and production controls remain untested extensions. Show the saved Terraform plan before any destructive apply, including membership removal or replacement.
