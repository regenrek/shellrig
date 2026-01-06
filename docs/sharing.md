## Sharing rules (public-safe)

Keep `shellrig` public-safe. No secrets, no internal hostnames, no private account identifiers, no vault references.

### Don’t publish

- Tokens, keys, passwords, certificates, private SSH keys
- `op://...` references (1Password item paths often reveal structure)
- Internal hostnames/domains, VPN tailnet DNS, private git remotes
- Company-specific scripts (deploy, prod access, incident tooling)
- Anything that depends on private repos or private infra

### Good patterns

- Put secrets in the environment and fail fast when missing
- Keep “ops/private” helpers in a private dotfiles repo
- Add CI checks (lint + secret scanning) before merges

