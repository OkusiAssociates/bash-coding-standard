<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Section 13: Environment Configuration

This section is the canonical reference for environment variables read by the `bcs` toolchain itself. Unlike sections 01–12, it documents the toolkit's runtime configuration surface — not coding rules — and contributes no `BCS####` codes to `bcs codes`.

Variables fall into six families:

1. **User configuration** — defaults for `bcs check` flags, overridable per-call
2. **Backend model overrides** — pin a concrete model regardless of `-m` tier keyword
3. **Backend selection** — `OLLAMA_HOST` directs the local Ollama backend
4. **Credentials** — API keys consumed by the cloud backends
5. **Search paths** — XDG locations for config and state files
6. **Internal / advanced** — runtime flags exported by `bcs` itself; documented for source-readers

Values are resolved in this precedence (highest wins):

1. CLI flag (e.g. `-m`, `-e`, `--strict`)
2. Configuration file (`bcs.conf` cascade, see §13.5)
3. Environment variable
4. Hardcoded default in `bcs`

The `bcs.conf.sample` file in the source tree is a quick-start template. This section is the authoritative reference.

## 13.1 User Configuration

Default values for the `bcs check` subcommand. All have CLI flag equivalents that override them.

### `BCS_MODEL`

- **Default:** `balanced`
- **Values:** tier keyword (`fast`, `balanced`, `thorough`), `claude-code[:tier|:model]`, or any concrete model name routed by `_sniff_backend()` (`claude-*`, `gemini-*`, `gpt-*`, `o[0-9]*`, anything else → Ollama)
- **Override flag:** `-m`, `--model`
- **Consumed:** `cmd_check()` initialiser

Tier keywords probe available backends in order (claude → ollama → anthropic → openai → google) and use that tier's default model for the first reachable one. Concrete model names route directly to the matching backend without probing.

### `BCS_EFFORT`

- **Default:** `medium`
- **Values:** `low`, `medium`, `high`, `max`
- **Override flag:** `-e`, `--effort`
- **Consumed:** `cmd_check()` initialiser

Effort controls both prompt guidance and the output token budget (`EFFORT_TOKENS` array: `low=4096`, `medium=8192`, `high=32768`, `max=65536`). `max` should be avoided for Ollama cloud models (hallucination risk).

### `BCS_STRICT`

- **Default:** `0`
- **Values:** `0` or `1`
- **Override flag:** `-s` / `-S`, `--strict` / `--no-strict`
- **Consumed:** `cmd_check()` initialiser

When `1`, warnings are reported as violations and contribute to a non-zero exit code.

### `BCS_DEBUG`

- **Default:** `0`
- **Values:** `0` or `1`
- **Override flag:** `-D`, `--debug`
- **Consumed:** `cmd_check()` initialiser

When `1`, the raw-response dump path is announced on success (it is always announced on failure).

### `BCS_JSON`

- **Default:** `0`
- **Values:** `0` or `1`
- **Override flag:** `-j`, `--json`
- **Consumed:** `cmd_check()` initialiser

When `1`, stdout is a single JSON object shaped like `shellcheck --format=json1` (`{source, meta, comments[]}`). Info messages still go to stderr when verbose.

### `BCS_SHELLCHECK`

- **Default:** `1` (enabled)
- **Values:** `0` or `1`
- **Override flag:** `--shellcheck`, `--no-shellcheck`
- **Consumed:** `cmd_check()` initialiser

When `1`, `shellcheck --format=json -x` runs over the target script and the JSON report is prepended to the LLM user prompt as static-analysis context. Auto-skipped when `shellcheck` is not on `PATH`.

### `BCS_TIER`

- **Default:** unset (no tier filter)
- **Values:** `core`, `recommended`, or `style`
- **Override flag:** `-T`, `--tier`
- **Consumed:** `cmd_check()` initialiser

Restricts findings to a single tier. Useful in CI: `BCS_TIER=core` reports only correctness/safety bugs.

### `BCS_MIN_TIER`

- **Default:** unset (no minimum)
- **Values:** `core`, `recommended`, or `style`
- **Override flag:** `-M`, `--min-tier`
- **Consumed:** `cmd_check()` initialiser

Reports findings at the named tier or higher severity. `BCS_MIN_TIER=recommended` skips style findings during development.

### `BCS_RESPONSE_DUMP`

- **Default:** `${XDG_STATE_HOME:-$HOME/.local/state}/bcs/last-response.txt`, or `mktemp /tmp/bcs-last-response.XXXXXX` if the state directory cannot be created
- **Values:** any writable file path
- **Override flag:** none (set externally to redirect)
- **Consumed:** `cmd_check()` always exports this; `_dump_response()` writes raw HTTP bodies; the path is announced on failure or with `--debug`

Set externally to direct raw API responses to a known location for inspection. The Claude Code CLI backend writes directly here (it returns text, not JSON).

## 13.2 Backend Model Overrides

Each variable pins a concrete model for one backend, taking precedence over the `-m` tier mapping (`ANTHROPIC_MODELS`, `OPENAI_MODELS`, etc.). Useful when a tier's default is unavailable in your account or you want to hold a specific model across sessions.

### `BCS_ANTHROPIC_MODEL`

- **Default:** unset (use `ANTHROPIC_MODELS[$tier]`)
- **Values:** any Anthropic model ID (e.g. `claude-sonnet-4-6`, `claude-opus-4-7`)
- **Consumed:** `_llm_anthropic()`, `_llm_claude_cli()`

### `BCS_OPENAI_MODEL`

- **Default:** unset (use `OPENAI_MODELS[$tier]`)
- **Values:** any OpenAI model ID (e.g. `gpt-5.4`, `o3-mini`)
- **Consumed:** `_llm_openai()`

### `BCS_GOOGLE_MODEL`

- **Default:** unset (use `GOOGLE_MODELS[$tier]`)
- **Values:** any Gemini model ID (e.g. `gemini-2.5-pro`)
- **Consumed:** `_llm_google()`

### `BCS_OLLAMA_MODEL`

- **Default:** unset (use `OLLAMA_MODELS[$tier]`)
- **Values:** any Ollama model tag, including `:cloud` variants (e.g. `qwen3.5:14b`, `minimax-m2:cloud`)
- **Consumed:** `_llm_ollama()`

## 13.3 Backend Selection (Ollama)

### `OLLAMA_HOST`

- **Default:** `localhost:11434`
- **Values:** `host:port` or `protocol://host:port`
- **Consumed:** `_llm_ollama()`, `_detect_backend()` reachability probe

Direct the local Ollama backend at a non-default endpoint (e.g. `OLLAMA_HOST=ollama.lan:11434`).

## 13.4 Credentials

API keys for the cloud backends. Resolved by `_detect_backend()` in this order: ollama (reachability) → anthropic → openai → google. The first backend with a usable credential wins under tier-keyword resolution; concrete model names always route to the matching backend regardless of probe order.

### `ANTHROPIC_API_KEY`

- **Required for:** Anthropic API backend (`claude-*` models, `claude-code` sentinel falls through to this when the CLI is unavailable)
- **Consumed:** `_llm_anthropic()` HTTP header

### `OPENAI_API_KEY`

- **Required for:** OpenAI API backend (`gpt-*`, `o[0-9]*` models)
- **Consumed:** `_llm_openai()` `Authorization: Bearer` header

### `GOOGLE_API_KEY`

- **Required for:** Google Gemini API backend (`gemini-*` models)
- **Consumed:** `_llm_google()` query parameter

### `GEMINI_API_KEY`

- **Alias for:** `GOOGLE_API_KEY` (Google's two SDK families use different names for the same key)
- **Precedence:** `GOOGLE_API_KEY` wins. If both are set, `bcs` unsets `GEMINI_API_KEY` before invoking the backend so downstream tooling sees a single canonical name.

## 13.5 Search Paths

XDG Base Directory variables that locate `bcs.conf` and the response dump. Standard XDG semantics apply (defaults used when unset).

### `XDG_CONFIG_HOME`

- **Default:** `$HOME/.config`
- **Affects:** `bcs.conf` and `policy.conf` cascade — `$XDG_CONFIG_HOME/bcs/bcs.conf` is the user-level config layer (overrides `/etc/bcs.conf`, `/etc/bcs/bcs.conf`, `/usr/local/etc/bcs/bcs.conf`)
- **Consumed:** `_conf_search_paths()`; policy resolution in `_load_policy()`

### `XDG_STATE_HOME`

- **Default:** `$HOME/.local/state`
- **Affects:** default `BCS_RESPONSE_DUMP` location (`$XDG_STATE_HOME/bcs/last-response.txt`)
- **Consumed:** `cmd_check()` state-dir setup

The data directory containing `BASH-CODING-STANDARD.md` and `data/*.md` section files is **not** XDG-resolved. It uses a four-step FHS search (development tree → relative `share/yatti/BCS/data` → `/usr/local/share/yatti/BCS/data` → `/usr/share/yatti/BCS/data`) defined in `_find_data_dir()`. There is no environment override for the data directory.

## 13.6 Internal / Advanced

These variables are set by `bcs` itself at runtime. They are documented here so power users reading the source — or wrapping the `_llm_*` backend functions — understand the runtime contract. **Users should not set them directly**; the corresponding CLI flag is the supported interface.

### `BCS_JSON_MODE`

- **Set by:** `cmd_check()` exports this from `--json` / `BCS_JSON`
- **Values:** `0` or `1`
- **Consumed:** all four `_llm_*` backend bodies

When `1`, each backend flips its native JSON-output knob:

- Ollama → `"format": "json"` at payload top level
- OpenAI → `"response_format": {"type": "json_object"}`
- Google → `"response_mime_type": "application/json"` under `generationConfig`
- Anthropic / Claude CLI → no native flag; rely on prompt discipline plus `_strip_json_fences()` fallback

Override the flag via `-j`/`--json` or `BCS_JSON=1` rather than setting `BCS_JSON_MODE` directly. Setting it externally without taking the rest of the JSON-rendering path (envelope wrap, schema validation in `_render_json_output()`) produces inconsistent output.
