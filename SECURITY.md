# Security Policy

## Our Commitment
At **SmartQuitIoT**, the security of our users' health data and the integrity of our IoT ecosystem are our top priorities. We follow the principle of least privilege and utilize modern encryption standards to ensure that every step of the journey toward quitting smoking is safe and private.

## Supported Versions

We currently provide security updates and patches for the following versions:

| Version | Supported          | Notes                                     |
| ------- | ------------------ | ----------------------------------------- |
| 1.x.x   | :white_check_mark: | Active Development (Java 21 / Spring Boot 3.4) |
| 0.9.x   | :warning:          | Critical Security Fixes Only              |
| < 0.8.x | :x:                | End of Life (EOL)                         |

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues.**

If you discover a security-related bug or vulnerability, we appreciate a responsible disclosure. You can report it through one of the following channels:

1.  **GitHub Private Reporting:** Use the [Private Vulnerability Reporting](https://github.com/luantnk/SmartQuitIoT/security/advisories/new) feature on this repository.
2.  **Email:** Send a detailed report to **luantnk2907@gmail.com**.

### What to include in your report:
*   A clear description of the vulnerability and potential impact.
*   Step-by-step instructions to reproduce the issue (PoC).
*   Details of the environment (OS, App version, Device type).

## Our Response Process

When a vulnerability is reported, the SmartQuitIoT team will:
*   **Acknowledge** receipt of the report within **48 hours**.
*   **Triage** the issue and provide an initial assessment of the risk.
*   **Fix** the vulnerability. We aim to release a patch for critical issues within **7-14 days**.
*   **Notify** the reporter once the fix has been deployed to production.

## Security Practices

To protect our users, we implement the following:
*   **Static Analysis:** Continuous scanning of our codebase using **CodeQL**.
*   **Dependency Scanning:** Automated vulnerability detection in libraries and Docker images via **Trivy**.
*   **Encryption:** All sensitive member data is encrypted at rest and in transit using TLS 1.3.
*   **Access Control:** Strict OAuth2 and JWT-based authentication for all API endpoints.

## Disclosure Policy

We ask that you follow **Responsible Disclosure** guidelines:
*   Provide us a reasonable amount of time to fix the issue before making it public.
*   Do not attempt to access or modify data that does not belong to you.
*   Do not perform Denial of Service (DoS) attacks or interrupt service for other users.

---
*Thank you for helping us make SmartQuitIoT safer for our community.*
