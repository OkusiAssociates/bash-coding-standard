bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
[WARN] BCS0102 line 1: shebang uses `#!/bin/bash`; BCS recommends `#!/usr/bin/bash` as the preferred Linux form. Fix: change line 1 to `#!/usr/bin/bash` if that path is correct for your target systems.

[WARN] BCS0301 line 59: static string is wrapped in double quotes: `"Invalid argument ${1@Q}"`. Because this includes expansion, double quotes are needed for the whole string, but the literal portion should be split from the expansion for clearer intent. Fix: use `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" 'Invalid argument '"${1@Q}"` or route through an error helper.

[WARN] BCS0602 line 60: usage/argument error exits with code `1`; BCS recommends exit code `2` for usage / argument errors. Fix: change `exit 1` to `exit 2`.

[WARN] BCS1202 line 14: comment `# Models to exercise` does not add meaningful information beyond the array declaration immediately below. Fix: remove it or replace it with a comment that adds context not obvious from the code.

[WARN] BCS1202 line 26: comment `# Efforts; low ommitted because of consistent poor quality with current models` is useful context, but contains a typo (`ommitted`). Fix: correct to `omitted`.

[WARN] BCS1202 line 79: comment `# Sanitize for filename: collapse ':' and '/' to '_'.` does not match the code, which replaces with `-`, not `_`. Fix: update the comment to say `'-'` or change the code to use `_`.

[WARN] BCS0301 line 83: static text is in double quotes even though only variable parts need expansion. Fix: prefer clearer split quoting, e.g. `>&2 echo 'bcs check --model '"$model"' --effort '"$effort"' '"${script@Q}"' &>'"${output_to@Q}"`.

[WARN] BCS0301 line 85: static text is in double quotes even though only variable parts need expansion. Fix: prefer `>&2 echo '    '"${output_to@Q}"' already exists; skipping'`.

[WARN] BCS0301 line 96: `TZ=UTC0` is an unquoted static string assignment; BCS allows one-word literals unquoted, but prefers UTC examples as `TZ=UTC`. Fix: use `TZ=UTC printf ...` unless `UTC0` is specifically required.

Summary:

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0102 | recommended | [WARN] | 1 | Preferred shebang form not used |
| BCS0301 | style | [WARN] | 59 | Quoting style could better separate literal and expanded parts |
| BCS0602 | recommended | [WARN] | 60 | Invalid argument exits with code 1 instead of recommended 2 |
| BCS1202 | style | [WARN] | 14 | Comment adds little beyond adjacent code |
| BCS1202 | style | [WARN] | 26 | Comment has typo |
| BCS1202 | style | [WARN] | 79 | Comment does not match code behavior |
| BCS0301 | style | [WARN] | 83 | Quoting style could better separate literal and expanded parts |
| BCS0301 | style | [WARN] | 85 | Quoting style could better separate literal and expanded parts |
| BCS0301 | style | [WARN] | 96 | Minor style issue around timezone assignment form |
bcs: ◉ Tokens: in=24795 out=787
bcs: ◉ Elapsed: 14s
