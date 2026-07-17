# Declined.io Official SDKs

All language SDKs live in one monorepo: **[Enoros/declined-sdk](https://github.com/Enoros/declined-sdk)**

| Directory | Package name | Install | Fallback name |
|-----------|--------------|---------|---------------|
| `declined-node` | `declined` | `npm install declined` | `@declined/node` |
| `declined-python` | `declined` | `pip install declined` | `declined-io` |
| `declined-ruby` | `declined` | `gem install declined` | `declined-io` |
| `declined-php` | `declined/sdk` | `composer require declined/sdk` | `declined-io/sdk` |
| `declined-go` | `declined-go` module | `go get github.com/Enoros/declined-sdk/declined-go` | `github.com/declined-io/declined-go` |
| `declined-java` | `io.declined:declined` | Maven `io.declined:declined` | `io.declined:declined-java` |

**Documentation:** [https://docs.declined.io](https://docs.declined.io) (local: `npm run dev:docs` → http://localhost:3003)

---

## Production checklist

### 1. Test locally

```powershell
cd declined-io
.\scripts\test-all-sdks.ps1
```

All 6 SDKs must pass before uploading.

### 2. Upload to GitHub

```powershell
$env:GITHUB_ORG = "Enoros"
$env:GITHUB_REPO = "declined-sdk"
.\scripts\create-github-repos.ps1
```

Creates or updates **https://github.com/Enoros/declined-sdk** with the full monorepo (`declined-node/`, `declined-python/`, etc.).

Preview first:

```powershell
$env:DRY_RUN = "1"
.\scripts\create-github-repos.ps1
```

### 3. Verify GitHub copy

```powershell
$env:TEST_FROM_GITHUB = "1"
$env:VERIFY_GITHUB = "1"
$env:GITHUB_ORG = "Enoros"
$env:GITHUB_REPO = "declined-sdk"
.\scripts\test-all-sdks.ps1 -FromGithub
```

### 4. Deploy platform API

Deploy `apps/web` and point `api.declined.io` at `/api/v1/*`. SDKs default to `https://api.declined.io/api`.

### 5. Deploy docs

Deploy `apps/docs` to `docs.declined.io`. Set production env:

```
NEXT_PUBLIC_DOCS_URL=https://docs.declined.io
NEXT_PUBLIC_SDK_GITHUB_ORG=Enoros
NEXT_PUBLIC_SDK_GITHUB_REPO=declined-sdk
NEXT_PUBLIC_SDK_GITHUB_BASE=https://github.com/Enoros/declined-sdk
```

### 6. Publish packages

Bump version in each SDK, commit, push to `Enoros/declined-sdk`, then publish:

```powershell
$env:NEXT_PUBLIC_SDK_GITHUB_BASE = "https://github.com/Enoros/declined-sdk"
.\scripts\publish\publish-node.ps1
# ... publish-python, publish-ruby, publish-php, publish-go, publish-java
```

Registry credentials: `NPM_TOKEN`, PyPI, RubyGems, Packagist, etc.

### 7. Fix-and-reupload loop

```powershell
# edit SDK code → test
.\scripts\test-all-sdks.ps1

# commit inside declined-io/ (monorepo root)
git add -A
git commit -m "fix: your message"
git push origin main

# verify GitHub
.\scripts\test-all-sdks.ps1 -FromGithub

# bump version → publish to registry
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| `test-all-sdks.ps1` | Test all 6 SDKs locally |
| `create-github-repos.ps1` | Push monorepo to Enoros/declined-sdk |
| `test-all-sdks.ps1 -FromGithub` | Clone GitHub and test |
| `create-and-test-sdks.ps1` | Upload + verify in one step |
| `install-missing-tools.ps1` | Maven, Composer, PHP extensions |
| `configure-php.ps1` | Enable PHP openssl/mbstring |
| `publish/publish-*.ps1` | Publish to npm/PyPI/etc. |

## API surface

- `POST /v1/events` — ingest events (including `payment_recovered`)
- `POST /v1/recoveries/:id/mark-recovered` — mark recovery as complete
- `GET /v1/customers`, `/v1/recoveries`, `/v1/sequences`, `/v1/webhooks`, `/v1/incentives`, `/v1/analytics`

Authenticate with `Authorization: Bearer decl_live_sk_...` or `decl_sandbox_sk_...`.
