# Git Commit Rules

- **NEVER** mention AI tools, assistants, or code-generation agents by name in commit messages. These are not recognised legal entities that can be held accountable for the code they touch.
- **All** commits must be authored by a named human or team identity tied to a real email address (e.g. `Firstname Lastname <user@example.com>`). Never use placeholder identities such as `Test User` or the name of any AI agent.
- Use **Conventional Commits** style (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, ...) when appropriate.
- Use `main` as the default branch name for new repositories.
- **NEVER** commit `CLAUDE.md`, `.claude/`, `.codex/`, `.opencode/` or other AI-assistant configuration directories to a public GitHub repository. These must always be listed in `.gitignore` and never tracked in version control.
- Commit message body should explain the **why**, not the **what** -- the diff already shows what changed.
- Keep the subject line under 72 characters. Wrap the body at ~72 columns.
