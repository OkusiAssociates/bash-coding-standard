<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.5 `bcscheck`

LLM-backed BCS compliance checker.

- Invocation: `bcscheck script.bash`.
- Calls into a configured LLM (Claude, Ollama, OpenAI, Google, etc.) per `bcs check`.
- Slow (minutes per script).
- Catches BCS-specific patterns ShellCheck doesn't (option terminator `--`, function organisation, error-code conventions).
- Configuration: `~/.config/bcs/bcs.conf`.
- JSON output mode for CI parsing: `bcscheck -j`.
- Inline suppression: `#bcscheck disable=BCSdddd`.

```bash
# scenario: JSON-mode invocation suitable for CI
$ bcscheck -j -m balanced -e medium ./bin/myscript
{
  "source": "bcs",
  "meta": { "model": "claude-sonnet-4", "effort": "medium", "elapsed_ms": 47210 },
  "comments": [
    {
      "file": "./bin/myscript",
      "line": 42,
      "column": 1,
      "level": "error",
      "code": "BCS0101",
      "message": "Strict mode preamble missing 'set -euo pipefail'.",
      "fix": null
    },
    {
      "file": "./bin/myscript",
      "line": 88,
      "column": 3,
      "level": "warning",
      "code": "BCS0307",
      "message": "Avoid unquoted $1 in [[ … ]]; quote for empty-arg safety.",
      "fix": null
    }
  ]
}
```

The envelope mirrors `shellcheck --format=json1` (§21.1) so the same CI
parsers work for both tools. `level=error` exits non-zero; `level=warning`
exits zero but is still surfaced.

```bash
# scenario: inline suppression scoped to the next command/block
# bcscheck disable=BCS0307 reason: arg known non-empty after option-parser guard
[[ $1 == --version ]] && { printf '%s\n' "$VERSION"; exit 0; }
```

The `#bcscheck disable=` comment honours the same scope rules as
`# shellcheck disable=` — the next single command, function, or
`{ … }` block. Always include a `reason:` (BCS0307 hooks here).

**See also**: §21.1 (ShellCheck JSON), §21.2 (ShellCheck directives), BCS0101 (strict mode), BCS0307 (anti-patterns).

#fin
