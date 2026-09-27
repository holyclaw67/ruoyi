# Security Policy

**Last updated:** 2026-09-27

`ruoyi` takes security seriously. We appreciate the efforts of security researchers and users who responsibly disclose vulnerabilities.

This document outlines how to report security issues and our commitment to handling them responsibly.

---

## Supported Versions

We currently provide security updates for the latest released version only.

| Version | Supported |
|---------|-----------|
| 2.3.4 (current) | Yes |
| Older releases | Please upgrade with `ruoyi self-update` |

If you are running an older version, we strongly recommend upgrading to the latest release using:

```bash
ruoyi self-update
```

---

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues or pull requests.**

We request that you report them privately so we can investigate and fix the issue before it becomes public.

**Maintainer contact (email):** `cloudgen.wong@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).
- Prefer email for vulnerability details, reproduction steps, and impact.
- You should receive an acknowledgment when the report is received and actionable.
- Do not include exploit weaponization guides in public channels.

You may also open a **private vulnerability report** on GitHub if available.

Please include the following information in your report:

- **Description** of the vulnerability
- **Steps to reproduce** the issue (as detailed as possible)
- **Affected component** (e.g., installer script, database setup, Redis setup, RuoYi configuration)
- **Potential impact** (e.g., remote code execution, data leak, privilege escalation)
- Any suggested **mitigation** or fix (if you have one)
- Your name/handle (optional, for credit in the disclosure)

We will acknowledge receipt of your report within **48 hours** (usually much faster).

### What Happens Next

1. We will confirm receipt and assign a severity level.
2. We will investigate and work on a fix (usually within a few days, depending on complexity).
3. Once fixed, we will release a new version and notify you.
4. After the fix is public, we will credit you (unless you prefer to stay anonymous).

We follow a **coordinated disclosure** policy: we do not publicly discuss or disclose the vulnerability until a fix is available.

---

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **CIAO-Lite** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Assume hostile input, hostile networks, and misconfiguration. Validate boundaries; fail closed on integrity **mismatch** when a companion digest is present; never fail silently on hard integrity errors. |
| **I** | **Intentional** | Privilege boundaries, install channel, and integrity modes are deliberate. **Automatic companion-checksum** is the default integrity path; optional env pin is secondary (CI/out-of-band), not a public help/about setting. |
| **A** | **Anti-fragile** | Survive harsh environments (minimal containers, missing tools, non-interactive install). Prefer transparent automatic SHA-256 sidecar checks, least privilege for day-to-day CLI use, and recoverable failure over brittle trust. Missing-sidecar policy is explicit (warn+continue). |
| **O** | **Over-protect** | Defense in depth on critical paths (integrity verify before install/update, Protection Zones, dated backups before destructive domain edits, loud failure). Do not “simplify away” safety or transparency for brevity. |

Full principles: [CIAO Defensive Programming](https://github.com/cloudgen/ciao) · agent contract: [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section describes **design posture**. It is **not** a claim of third-party certification (ISO, OWASP “compliant”, etc.).

---

## Install integrity and trust

Online install and `self-update` implement the **automatic checksum mechanism** (`requirement-shell-automatic-checksum`).

| Fact | Honest statement |
|------|------------------|
| **Default path** | Automatic companion verification (`${SCRIPT_URL}.sha256`) when no operator pin is set — no env pin required for normal install/self-update. |
| **Algorithm** | SHA-256 |
| **Transparency** | Human mode shows companion **link**, expected **value**, and verification **result** (match / mismatch / missing). |
| **Mismatch** | Abort — do not install mismatched bytes. |
| **Missing sidecar** | Warn and continue (best-effort / backward compatible). Do **not** claim “always verified” when the sidecar is absent. |
| **Optional pin** | Process-env `CHECKSUM` is **secondary** (CI / out-of-band freeze). It is **not** stronger than automatic mode when the pin is fetched from the **same origin**. It is **not** advertised in `help` / `about`. |
| **Trust bound** | Same-channel SHA-256 proves **byte consistency** (wrong blob / bit-flip / stale companion vs artifact). It is **not** independent authenticity (signing / separate trust root) by itself. |

Operator-facing install steps, one-liners, and full integrity outcomes live in [`README.md`](./README.md).

---

## Disclosure Policy

- We aim to release security fixes as quickly as possible.
- We prefer **responsible disclosure** — giving us reasonable time to fix before public disclosure.
- We will publish security advisories via GitHub when appropriate.
- This is a small/maintained-by-one project, so response times may vary during weekends or holidays.

---

## Security Best Practices for Users

- Always run the latest version of `ruoyi` (`ruoyi self-update`).
- Use `--force` with caution — it performs backups, but review them.
- Review database passwords generated during `ruoyi mariadb` / `ruoyi mysql`.
- For production deployments, do **not** use the default admin credentials (`admin` / `admin123`).
- Keep your Java, Maven, MariaDB/MySQL, and Redis versions up to date.
- Run the installer and database setup with the minimum required privileges.

---

## Security Considerations Specific to This Project

- The script performs **internal sudo escalation** only for privileged operations (package installation, service management, database creation). It never requires you to run the entire command with `sudo` unless installing globally.
- All destructive operations (project reset, file modifications) create **dated backups** first.
- Domain elevation remains internal-sudo scoped (`requirement-shell-least-privilege`).
- Java 21 (Temurin) and Maven 3.9.14 are pinned for reproducibility.

---

## Scope notes

- Preferred language for reports: English.
- Out of scope: social engineering of third parties, physical attacks, spam.
- Related product docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).

If you have suggestions to improve this security policy, feel free to open a pull request or issue (non-sensitive topics only).

Thank you for helping keep `ruoyi` secure.
