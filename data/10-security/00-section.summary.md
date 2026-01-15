# Security Considerations

Establishes security-first practices covering five essential areas: no SUID/SGID on bash scripts (inherent security risks), locked-down PATH validation (prevent command hijacking), IFS safety (avoid word-splitting vulnerabilities), `eval` avoidance (injection risks—requires explicit justification), and input sanitization patterns (validate/clean early). Prevents privilege escalation, command injection, path traversal, and common shell attack vectors.
