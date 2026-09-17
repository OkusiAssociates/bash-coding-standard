# Replay corpus

Real `bcs check` text-mode answers saved during the September 2026 audit,
replayed by `tests/test-check-exit-promotion.sh`. Nothing here is executed and
no backend is contacted.

File name: `<script>_<backend>_<effort>.rc<N>.txt`, where `rc<N>` is the exit
code the run produced and therefore the verdict the `[ERROR]` probe must keep
reproducing (`rc1` = at least one `[ERROR]` finding header, `rc0` = none).

The corpus covers the four header layouts the backends have produced:

| Layout | Example |
|--------|---------|
| Contract | `[ERROR] BCS1002 line 106: ...` |
| Bold, tag first | `**[ERROR] BCS0102** (Tier: core) — Line 6` |
| Bold, code first | `**BCS1005** (Tier: core) — **[ERROR]** — Line 215` |
| Code first, plain tag | `**BCS0409** — Tier: core — [ERROR] — Line 8` |

`cln_claude-code_thinkaloud.rc1.txt` is a think-aloud answer in which most
`[ERROR]` headers end in "Compliant.". It stays `rc1` on purpose: the probe does
not try to detect retractions, because a wrong guess would turn a real ERROR
into exit 0. Add a file here whenever a backend produces a new layout.
