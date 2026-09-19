---
name: security-audit
description: Practical application security auditing and vulnerability mitigation. Focuses on OWASP Top 10, injection prevention, authentication checks, secrets hygiene, and safe input parsing. Use for security reviews, threat modeling, or pre-release hardening.
compatibility: opencode
---

# Security Audit

Proactive and rigorous security auditing: secure by default, defend at the boundary.

## Audit Checklist

1. **Injection Defenses**:
   - **SQL Injection**: All database queries must use parameterized statements or ORM query builders. Never concatenate user strings into raw SQL.
   - **Command Injection**: When invoking subprocesses, pass arguments as arrays/vectors directly to the executable. Never pass untrusted user input into shell string interpreters (`bash -c`, `sh -c`, `eval`, or backticks).
   - **Cross-Site Scripting (XSS)**: Ensure template engines escape by default. Never use `dangerouslySetInnerHTML` or equivalent without strict HTML sanitization.
2. **Secrets & Credential Hygiene**:
   - Verify zero API keys, private certificates, or database passwords exist in source files or git history.
   - Check that `.env` and credential files are strictly gitignored.
   - Use environment variables or dedicated secret management systems.
3. **Authentication & Authorization**:
   - Verify access control checks occur on the server side for every protected resource.
   - Ensure passwords use modern hashing algorithms (Argon2id, bcrypt) with appropriate work factors.
   - Use secure, `HttpOnly`, `SameSite=Lax/Strict` flags for session cookies.
4. **Data Deserialization & Parsing**:
   - Validate and sanitize incoming request bodies against strict schemas before processing.
   - Forbid dangerous deserialization libraries (`pickle.loads`, `yaml.load` without SafeLoader).
5. **Transport & Headers**:
   - Enforce HTTPS.
   - Configure restrictive CORS policies (avoid wildcards `*` on authenticated endpoints).
   - Set standard security headers (`Content-Security-Policy`, `X-Content-Type-Options: nosniff`).

## Verification

- Run static security analysis tools where available (`semgrep`, `bandit`, `npm audit`, `trivy`).
- Search codebase for forbidden patterns: raw SQL interpolation, shell execution wrappers, or hardcoded secrets.
- Verify failed authentication and authorization attempts return appropriate error codes without leaking internal topology.
