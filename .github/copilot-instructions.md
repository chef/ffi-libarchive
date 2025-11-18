# 1. Purpose
Authoritative operational workflow for AI assistants contributing to this repository. Defines required gating, planning, testing, DCO compliance, PR standards, safety, and idempotent re-entry rules. Audience: AI-only (NOT human onboarding).

# 2. Repository Structure
```
.                               # Root gem project (ffi binding to libarchive)
├── CHANGELOG.md                # Human-readable change log (managed partly by Expeditor)
├── CODE_OF_CONDUCT.md          # Delegated link to Chef community CoC (Protected)
├── CONTRIBUTING.md             # Contribution guidelines (delegated)
├── Gemfile                     # Dependency manifest (groups: test/style/debug)
├── LICENSE                     # Apache 2.0 license (Protected)
├── Rakefile                    # Rake tasks for style & tests
├── README.md                   # Project overview & usage
├── VERSION                     # Source of truth for gem version (bumped by Expeditor)
├── ffi-libarchive.gemspec      # Gem specification
├── ffi-libarchive-universal-mingw-ucrt.gemspec # Alt gemspec (Windows universal?)
├── .rubocop.yml                # Style & lint configuration (Cookstyle/Rubocop)
├── .yardopts                   # YARD documentation options
├── .gitattributes              # Git attributes
├── .gitignore                  # Ignore rules
├── .vscode/                    # Editor / tooling configs
│   └── mcp.json                # (If present) MCP client config
├── .github/                    # GitHub metadata & automation
│   ├── CODEOWNERS              # Ownership mapping (Protected)
│   ├── dependabot.yml          # Dependency update automation
│   ├── prompts/
│   │   └── generateinstructions.prompt.md # Source prompt spec for this file
│   ├── workflows/
│   │   └── lint.yml            # CI workflow for style/lint
│   └── ISSUE_TEMPLATE/         # Issue templates (bug, enhancement, design, support)
├── .expeditor/                 # Chef Expeditor release automation (Protected)
│   ├── config.yml              # Expeditor pipeline & version bump logic
│   └── update_version.sh       # Syncs VERSION into code after bump
├── distro/                     # Windows DLL distribution assets
│   └── ruby_bin_folder/
│       ├── libarchive.dll
│       ├── liblzma-5.dll
│       └── libxml2-2.dll
├── lib/                        # Runtime library source
│   ├── ffi-libarchive.rb       # Entry point, requires core components
│   └── ffi-libarchive/
│       ├── archive.rb          # Core FFI bindings (Archive module)
│       ├── reader.rb           # Reader API wrapper
│       ├── writer.rb           # Writer API wrapper
│       ├── entry.rb            # Archive entry wrapper
│       ├── stat.rb             # Stat struct wrapper (POSIX metadata)
│       └── version.rb          # VERSION constant binder
└── test/                       # Test suite (test-unit style + helper sets)
    ├── test_ffi-libarchive.rb  # Main test file
    ├── sets/
    │   ├── ts_read.rb          # Read tests grouping
    │   └── ts_write.rb         # Write tests grouping
    └── data/                   # Sample archive fixtures
        ├── test.tar.gz
        └── test.zip
```
(Initial recording – no prior structure to diff.)

# 3. Tooling & Ecosystem
- Language: Ruby (>= 3.0 required by gemspec; Rubocop target 2.7 – note divergence; treat 3.x runtime as canonical). 
- Package: RubyGems gem (ffi-libarchive).
- FFI Dependency: `ffi ~> 1.17`.
- Lint/Style: Cookstyle (Chefstyle) via Rubocop; CI workflow `lint.yml`.
- Test Frameworks: `test-unit` (configured in Rakefile) plus RSpec listed (not actively wired in default Rake tasks). Prefer extending test-unit unless explicitly migrating.
- Release Automation: Chef Expeditor handles version bump, changelog, gem build & publish.
- Continuous Integration: GitHub Actions (lint), Buildkite badge (external pipeline) suggests additional verify pipeline outside repo.
- Windows Support: Bundler copy of DLLs in `distro/ruby_bin_folder` into Ruby bindir on Windows platforms.
- Documentation: YARD (`.yardopts`).

# 4. Issue (Jira/Tracker) Integration
When an issue key (e.g., ABC-123) is provided:
1. Invoke external tracker (conceptually `atlassian-mcp-server:getIssue <ISSUE_KEY>`).
2. Extract fields: summary, description, acceptance criteria bullets, issue type, linked issues, labels/tags, story points (if any).
3. Draft Implementation Plan (no code yet) including:
   - Goal
   - Impacted Files
   - Public API/Interface Changes
   - Data/Integration Considerations
   - Test Strategy
   - Edge Cases (explicit list)
   - Risks & Mitigations
   - Rollback Strategy
4. Present plan for explicit user approval (“yes”). If acceptance criteria missing: propose inferred criteria; ask user to (provide/proceed).
5. Do NOT modify code before approval (Freeze point).

# 5. Workflow Overview
Phases (must run sequentially):
1. Intake & Clarify
2. Repository Analysis
3. Plan Draft
4. Plan Confirmation (gate)
5. Incremental Implementation
6. Lint / Style
7. Test & Coverage Validation
8. DCO Commit
9. Push & Draft PR Creation
10. Label & Risk Application
11. Final Validation
Each phase output includes: Step, Summary, Checklist (phases with status), Prompt: “Continue to next step? (yes/no)”. Lack of explicit "yes" halts progress.

# 6. Detailed Step Instructions
Principles:
- Smallest cohesive changes per commit.
- Tests added/updated alongside each logic change.
- Provide Changed Logic → Test Assertions mapping before committing.
Template example:
```
Step: Add boundary guard in reader
Summary: Added nil check for entry; tests for nil & oversized input.
Checklist:
- [x] Plan
- [x] Implementation
- [ ] Tests
Proceed? (yes/no)
```
Non-affirmative user input => pause and clarify.

# 7. Branching & PR Standards
- Branch Name: If issue key present, exactly that. Else kebab-case concise slug ≤40 chars (e.g., `improve-reader-error-handling`).
- One logical change per branch.
- Keep PR in Draft until: lint passes, tests pass, coverage mapping ≥80% changed lines, DCO compliance ensured.
- PR Description (HTML sections): Summary, Issue, Changes, Tests & Coverage, Risk & Mitigations, DCO.
- Risk Classification: Low | Moderate | High (criteria in prompt). Include rollback (revert commit SHA or config toggle if any).

# 8. Commit & DCO Policy
Format:
```
TYPE(SCOPE): SUBJECT (ISSUE_KEY)

Rationale: what & why (narrative). If scope absent, omit parentheses.

Issue: ISSUE_KEY or none
Signed-off-by: Full Name <email@domain>
```
- Every commit MUST include a valid DCO sign-off line.
- Missing sign-off: halt, request contributor name & email.
- Conventional types recommended: feat, fix, chore, docs, test, refactor, perf, ci.

# 9. Testing & Coverage
Changed Logic → Test Assertions Mapping table required pre-commit:
| File | Method/Block | Change Type | Test File | Assertion Reference |
Coverage Expectations: ≥80% of changed lines executed (qualitative estimate acceptable if no tooling). If <80%: add tests or refactor until met.
Edge Cases (enumerate in plan):
- Large input / boundary size
- Empty / nil input
- Invalid / malformed data
- Platform differences (path, permissions, Windows vs POSIX)
- Concurrency/timing (rare here; note if applicable)
- External dependency failures (FFI load errors, missing DLL, libarchive version mismatch)
Optional coverage tooling (e.g., SimpleCov) only after user approval.

# 10. Labels Reference
Retrieved via GitHub API (date: 2025-09-30). Use typical mapping guidance; apply the most relevant labels.
| Name | Description | Typical Use |
| ---- | ----------- | ----------- |
| Aspect: Documentation | How do we use this project? | Docs improvements |
| Aspect: Integration | Works correctly with other projects or systems. | Cross-project concerns |
| Aspect: Packaging | Distribution of compiled artifacts. | Build/release packaging issues |
| Aspect: Performance | Works without negatively affecting the system running it. | Performance tuning |
| Aspect: Portability | Does this project work correctly on the specified platform? | Platform compatibility |
| Aspect: Security | Can an unwanted third party affect stability or view privileged info? | Security fixes/audits |
| Aspect: Stability | Consistent results. | Flakiness / reliability |
| Aspect: Testing | Coverage & CI health. | Test suite / infra |
| Aspect: UI | Interaction & visual design. | UI interface aspects (if any) |
| Aspect: UX | User experience feel. | Usability enhancements |
| dependencies | Pull requests that update a dependency file | Automated dependency updates |
| Expeditor: Bump Version Major | Triggers major version bump | Release labeling |
| Expeditor: Bump Version Minor | Triggers minor version bump | Release labeling |
| Expeditor: Skip All | Skip all merge actions | Exceptional merges |
| Expeditor: Skip Changelog | Skip changelog update | Changelog control |
| Expeditor: Skip Habitat | Skip habitat build | Release pipeline control |
| Expeditor: Skip Omnibus | Skip omnibus build | Release pipeline control |
| Expeditor: Skip Version Bump | Skip version bump | Prevent automated bump |
| hacktoberfest-accepted | Hacktoberfest credit | Seasonal participation |
| oss-standards | OSS standardization | Repo standards work |
| Platform: AWS | (none) | Cloud/platform-specific |
| Platform: Azure | (none) | Cloud/platform-specific |
| Platform: Debian-like | (none) | Debian family issues |
| Platform: Docker | (none) | Container environment |
| Platform: GCP | (none) | Cloud/platform-specific |
| Platform: Linux | (none) | Generic Linux platform |
| Platform: macOS | (none) | macOS-specific |
| Platform: RHEL-like | (none) | RHEL/CentOS derivatives |
| Platform: SLES-like | (none) | SUSE derivatives |
| Platform: Unix-like | (none) | Generic Unix concerns |
If a desired label is missing, request user confirmation for alternative or out-of-band creation.

# 11. CI / Release Automation Integration
- GitHub Actions: `lint.yml` (Triggers: push to main, pull_request). Job: cookstyle linting.
- External CI: Buildkite (badge in README) for broader verification (not configured here).
- Release Automation: Chef Expeditor (`.expeditor/config.yml`) handles version bump, changelog, gem build & publish to Rubygems.
- Version Bump Mechanism: Auto bump via labels -> Expeditor bump -> update `VERSION` file -> script syncs `lib/ffi-libarchive/version.rb`.
Statement: AI MUST NOT directly edit release automation configs without explicit user instruction.

# 12. Security & Protected Files
Protected (require explicit user approval to modify): LICENSE, CODE_OF_CONDUCT.md, CODEOWNERS, `.expeditor/*`, GitHub workflow files under `.github/workflows`, release automation configs, binary artifacts, any security policy docs. Prohibited actions: exfiltrating secrets, adding opaque binaries, force-pushing default, merging autonomously, removing license headers, fabricating label or issue data.

# 13. Prompts Pattern (Interaction Model)
Every step output MUST include:
```
Step: <STEP_NAME>
Summary: <Outcome>
Checklist:
- [ ] Intake & Clarify
- [ ] Repository Analysis
- [ ] Plan Draft
- [ ] Plan Confirmation
- [ ] Incremental Implementation
- [ ] Lint / Style
- [ ] Test & Coverage Validation
- [ ] DCO Commit
- [ ] Push & Draft PR Creation
- [ ] Label & Risk Application
- [ ] Final Validation
Continue to next step? (yes/no)
```
Use [x] for completed, maintain order. Proceed only on explicit "yes".

# 14. Validation & Exit Criteria
Completion ONLY IF:
1. Feature/fix branch exists & pushed.
2. Lint/style passes.
3. Tests pass.
4. Coverage mapping ≥80% changed lines.
5. Draft or ready PR open with required HTML sections.
6. Proper labels applied.
7. All commits DCO-compliant.
8. No unauthorized Protected File edits.
9. User explicitly confirms completion.
10. Revision History updated (after initial creation).
Otherwise list unmet criteria.

# 16. Issue Planning Template
```
Issue: ABC-123
Summary: <from issue>
Acceptance Criteria:
- ...
Implementation Plan:
- Goal:
- Impacted Files:
- Public API Changes:
- Data/Integration Considerations:
- Test Strategy:
- Edge Cases:
- Risks & Mitigations:
- Rollback:
Proceed? (yes/no)
```

# 17. PR Description Canonical Template
If no existing PR template:
```
<h2>Summary</h2>
<p>WHAT + WHY.</p>
<h2>Issue</h2>
<p><a href="https://tracker.example/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul><li>Modified: ...</li><li>Added: ...</li></ul>
<h2>Tests & Coverage</h2>
<p>Changed lines: N; Estimated covered: ~X%; Mapping complete.</p>
<h2>Risk & Mitigations</h2>
<p>Risk: Low | Mitigation: revert commit SHA</p>
<h2>DCO</h2>
<p>All commits signed off.</p>
```

# 18. Idempotency Rules
Re-entry detection order:
1. Branch existence (`git rev-parse --verify <branch>`)
2. PR existence (`gh pr list --head <branch>`)
3. Uncommitted changes (`git status --porcelain`)
4. Existing Revision History block in this file.
On update produce Delta Summary:
- Added Sections:
- Modified Sections:
- Deprecated Sections:
- Rationale:
Add entry to Revision History with timestamp (UTC ISO8601) summarizing deltas.

# 19. Failure Handling
Decision Tree:
- Labels fetch fails → Abort; prompt: “Provide label list manually or fix auth. Retry? (yes/no)”.
- Issue fetch incomplete → Ask: “Missing acceptance criteria—provide or proceed with inferred? (provide/proceed)”.
- Coverage < threshold → Add tests; re-run; block commit.
- Missing DCO → Request contributor name/email.
- Protected file modification attempt → Reject & restate policy.
Abort responses MUST include reason, required user action, and “Retry? (yes/no)”.

# 20. Glossary
- Changed Lines Coverage: Portion of modified lines executed by assertions.
- Implementation Plan Freeze Point: No code changes until plan approval.
- Protected Files: Policy-restricted assets needing explicit authorization.
- Idempotent Re-entry: Resume without duplication or conflict.
- Risk Classification: Low/Moderate/High impact tiers.
- Rollback Strategy: Specific reversal action (revert commit or disable feature).
- DCO: Developer Certificate of Origin sign-off.

# 21. Quick Reference Commands
```bash
# Start feature work
git checkout -b <BRANCH>

# Install dependencies
bundle install

# Run style
bundle exec rake style

# Run tests
bundle exec rake test

# Stage & commit
git add .
git commit -m "feat(scope): concise summary (ABC-123)" -m "Rationale: ..." -m "Issue: ABC-123" -m "Signed-off-by: Full Name <email@domain>"

# Push & draft PR
git push -u origin <BRANCH>
gh pr create --base main --head <BRANCH> --title "ABC-123: Short summary" --draft

# Label (example)
gh pr edit <PR_NUMBER> --add-label "Aspect: Testing"
```

## 22. AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant
