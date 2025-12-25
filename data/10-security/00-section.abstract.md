# Security Considerations

**Security-first practices for production bash scripts covering privilege controls, PATH validation, field separator safety, eval dangers, and input sanitization to prevent privilege escalation, command injection, path traversal, and other attack vectors.**

**Core mandates**: Never SUID/SGID on bash scripts (inherent race conditions, predictable temp files, signal vulnerabilities); lock down PATH or validate explicitly (prevents command hijacking); understand IFS word-splitting risks; avoid `eval` unless justified (injection vector); sanitize all user input early (regex validation, whitelisting).

**Ref:** BCS1200
