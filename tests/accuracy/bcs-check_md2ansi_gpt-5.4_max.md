bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
[WARN] BCS0103 line 13: Script metadata is incomplete; `SCRIPT_NAME` is derived directly from `$0` instead of the recommended `realpath`-based metadata pattern. Fix: use the standard metadata block, e.g. `#shellcheck disable=SC2155; declare -r SCRIPT_PATH=$(realpath -- "$0"); declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}` if those values are needed.

[WARN] BCS1202 line 16: Comment paraphrases the code (`0 means auto-detect`) rather than adding non-obvious context. Fix: remove the comment or replace it with rationale/constraint that is not obvious from the assignment itself.

[WARN] BCS1202 line 17: Comment paraphrases the code (`10MB limit`) rather than adding non-obvious context. Fix: remove the comment or replace it with rationale/constraint.

[WARN] BCS1204 line 39: Section comment uses `## ... ##` framing instead of a single `#` 2-4 word section comment. Fix: rewrite as a simple section comment such as `# Utility functions`.

[WARN] BCS1204 line 43: Section comment is a full sentence-like label longer than the 2-4 word guideline. Fix: shorten to a 2-4 word section comment, e.g. `# Message colors`.

[WARN] BCS1204 line 50: 80-dash separator is used as a section divider; these are reserved for major script divisions only and should be used sparingly. Fix: replace with a normal single-line section comment unless this is one of the file’s few true major divisions.

[WARN] BCS1202 line 53: Comment paraphrases the function body rather than adding non-obvious information. Fix: remove it or replace it with rationale/constraint.

[WARN] BCS0702 line 62: `_msg()` prints to stdout, but status/messaging functions must go to stderr. Fix: redirect inside `_msg()` with `>&2 printf ...`, or ensure `_msg()` itself always writes to stderr.

[WARN] BCS1202 line 65: Comment paraphrases the statements below (`Unconditional output`). Fix: remove it or replace it with meaningful context.

[WARN] BCS1202 line 68: Comment paraphrases the `die()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 71: Comment paraphrases the `debug()` function. Fix: remove it or replace it with substantive context.

[WARN] BCS1204 line 82: 80-dash separator used for an ordinary section. Fix: use a normal `# ...` section comment unless reserving this for a major division.

[WARN] BCS1202 line 85: Comment paraphrases the `get_terminal_width()` function. Fix: remove it or replace it with non-obvious design rationale.

[WARN] BCS1202 line 86: Comment restates the return contract visible from the code. Fix: remove it unless documenting something not inferable from the implementation.

[WARN] BCS1202 line 90: Comment paraphrases the next statement (`Method 1: tput cols`). Fix: remove it or replace it with rationale for method ordering.

[WARN] BCS1202 line 100: Comment paraphrases the next statement (`Method 2: stty size`). Fix: remove it or replace it with rationale.

[WARN] BCS1202 line 112: Comment paraphrases the next statement (`Method 3: COLUMNS environment variable`). Fix: remove it or replace it with non-obvious context.

[WARN] BCS1204 line 120: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 123: Comment paraphrases the `validate_file_size()` function. Fix: remove it or replace it with rationale not obvious from the checks.

[WARN] BCS1202 line 124: Comment only restates the function usage. Fix: remove it unless needed for non-obvious calling constraints.

[WARN] BCS0602 line 134: Uses exit code `4`, which is not among the standard documented exit codes in BCS0602. Fix: use a standard code such as `22` for invalid argument or another documented code that matches the failure class.

[WARN] BCS0602 line 140: Uses exit code `9`, which is not among the standard documented exit codes in BCS0602. Fix: use a standard documented exit code, e.g. `22` or `5` depending on intended meaning.

[WARN] BCS1202 line 133: Comment paraphrases the following directory check. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 136: Comment paraphrases the following file-size retrieval. Fix: remove it or replace it with non-obvious context.

[WARN] BCS1204 line 147: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 150: Comment paraphrases the `cleanup()` function. Fix: remove it or replace it with rationale/constraint.

[WARN] BCS1202 line 154: Comment paraphrases the reset statement below it. Fix: remove it or replace it with meaningful context.

[WARN] BCS1202 line 158: Comment paraphrases the trap installation. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1204 line 161: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 164: Comment paraphrases the `noarg()` function. Fix: remove it or replace it with substantive context.

[WARN] BCS1202 line 165: Comment only restates usage mechanics already visible from the function. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1204 line 173: Section heading uses `===` framing instead of a single `#` section comment. Fix: rewrite as a simple section comment such as `# ANSI colors`.

[WARN] BCS1202 line 177: Comment paraphrases the following color-detection block. Fix: remove it or replace it with non-obvious rationale only.

[WARN] BCS1202 line 178: Comment narrates the implementation rather than adding external context. Fix: remove it or condense into a rationale comment if needed.

[WARN] BCS1202 line 183: Comment paraphrases the following `if` test. Fix: remove it.

[WARN] BCS0707 line 185: TUI/color capability logic enables color when `TERM` is set and not `dumb` even if stdout/stderr are not terminals, which can leak ANSI escapes into pipes or redirected output. Fix: gate ANSI/TUI behavior on terminal checks such as `[[ -t 1 && -t 2 ]]`, with plain-text fallback otherwise.

[WARN] BCS1204 line 192: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 193: Comment paraphrases the following color declaration block. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 195: Comment paraphrases the use of `$'...'` directly visible in the code. Fix: remove it.

[WARN] BCS1202 line 203: Comment paraphrases the following header color declarations. Fix: remove it or replace it with non-obvious design intent.

[WARN] BCS1202 line 204: Inline explanatory color names merely restate the declarations that follow. Fix: remove them unless they capture non-obvious mapping rationale.

[WARN] BCS1202 line 212: Comment paraphrases the following element color declarations. Fix: remove it or replace it with rationale.

[WARN] BCS1202 line 213: Inline explanatory color names restate the values' intent without adding substantive context. Fix: remove them unless documenting something non-obvious.

[WARN] BCS1202 line 222: Comment paraphrases the following syntax highlighting declarations. Fix: remove it or replace it with rationale.

[WARN] BCS1202 line 223: Inline color label comment restates the declarations. Fix: remove it unless it adds non-obvious mapping rationale.

[WARN] BCS1202 line 232: Comment paraphrases the else branch (`No color support - all empty strings`). Fix: remove it.

[WARN] BCS1204 line 243: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 246: Comment paraphrases the `strip_ansi()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 247: Comment only restates function usage. Fix: remove it unless there is a hidden constraint.

[WARN] BCS1202 line 250: Comment paraphrases the sed expression below. Fix: remove it.

[WARN] BCS1202 line 255: Comment paraphrases the `visible_length()` function. Fix: remove it or replace it with non-obvious context.

[WARN] BCS1202 line 256: Comment only restates usage. Fix: remove it unless documenting a hidden contract.

[WARN] BCS1202 line 263: Comment paraphrases the `sanitize_ansi()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 264: Comment only restates usage. Fix: remove it unless needed for a hidden constraint.

[WARN] BCS1204 line 270: Section heading uses `===` framing instead of a single `#` section comment. Fix: rewrite as a simple section comment.

[WARN] BCS1204 line 274: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 277: Comment paraphrases the `colorize_line()` function. Fix: remove it or replace it with non-obvious design constraints only.

[WARN] BCS1202 line 278: Comment about processing order adds some rationale, but the separate `Usage:` line at 279 is paraphrastic. Fix: keep the order rationale if desired, but remove the usage-only comment on line 279.

[WARN] BCS1202 line 285: Comment paraphrases the sed transform below. Fix: remove it unless documenting a non-obvious edge case.

[WARN] BCS1202 line 288: Comment paraphrases the image-processing block. Fix: remove it or retain only the non-obvious ordering rationale.

[WARN] BCS1202 line 293: Comment paraphrases the links block. Fix: remove it.

[WARN] BCS1202 line 298: Comment paraphrases the following sed command. Fix: remove it.

[WARN] BCS1202 line 301: Comment paraphrases the following sed commands. Fix: remove it.

[WARN] BCS1202 line 305: Comment paraphrases the following sed command. Fix: remove it.

[WARN] BCS1202 line 308: Comment mostly paraphrases the following sed command. Fix: keep only non-obvious edge-case rationale, remove the rest.

[WARN] BCS1202 line 309: Comment narrates the implementation rather than adding durable context. Fix: remove it unless documenting a proven parser limitation.

[WARN] BCS1202 line 311: Comment narrates implementation details visible from what follows. Fix: remove it.

[WARN] BCS1202 line 312: Comment documents a deliberate limitation; this is acceptable. No issue on this line.

[WARN] BCS1202 line 314: Comment paraphrases the following sed command. Fix: remove it.

[WARN] BCS1202 line 317: Comment paraphrases the footnote-processing block. Fix: remove it.

[WARN] BCS1204 line 325: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 328: Comment paraphrases the `wrap_text()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 329: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1003 line 348: Uses `IFS=' ' read ...` without local scoping or subshell isolation. Fix: use `local -- IFS=' '` before `read`, or keep the inline-assignment form with a single command if intended to be scoped explicitly according to BCS guidance.

[WARN] BCS1202 line 338: Comment paraphrases the visible-length assignment below. Fix: remove it.

[WARN] BCS1202 line 341: Comment paraphrases the `if` block below. Fix: remove it.

[WARN] BCS1202 line 347: Comment paraphrases the `read` statement below. Fix: remove it.

[WARN] BCS1202 line 350: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1202 line 360: Comment paraphrases the branch body below. Fix: remove it.

[WARN] BCS1202 line 365: Comment paraphrases the branch body below. Fix: remove it.

[WARN] BCS1202 line 372: Comment paraphrases the final echo below. Fix: remove it.

[WARN] BCS1204 line 376: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 379: Comment paraphrases the `render_header()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 380: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 386: Comment paraphrases the `case` block below. Fix: remove it.

[WARN] BCS1202 line 396: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1204 line 402: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 405: Comment paraphrases the `render_list_item()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 406: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1202 line 415: Comment paraphrases the arithmetic below. Fix: remove it.

[WARN] BCS0505 line 416: Uses `indent_level=$((${#indent} / 2))` command substitution for arithmetic assignment instead of plain arithmetic assignment. Fix: declare the variable integer and use `indent_level=$(( ${#indent} / 2 ))`.

[WARN] BCS1202 line 420: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 423: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 426: Comment paraphrases the `printf` below. Fix: remove it.

[WARN] BCS1202 line 429: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1202 line 436: Comment paraphrases the `render_ordered_item()` function. Fix: remove it.

[WARN] BCS1202 line 437: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1202 line 447: Comment paraphrases the following indentation setup. Fix: remove it.

[WARN] BCS0505 line 448: Uses `indent_level=$((${#indent} / 2))` command substitution for arithmetic assignment instead of plain arithmetic assignment. Fix: use `indent_level=$(( ${#indent} / 2 ))`.

[WARN] BCS0505 line 450: Uses `number_width=$((${#number} + 2))` command substitution for arithmetic assignment instead of plain arithmetic assignment. Fix: use `number_width=$(( ${#number} + 2 ))`.

[WARN] BCS1202 line 454: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 457: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 460: Comment paraphrases the `printf` below. Fix: remove it.

[WARN] BCS1202 line 463: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1202 line 470: Comment paraphrases the `render_task_item()` function. Fix: remove it.

[WARN] BCS1202 line 471: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1202 line 474: Inline comment `'x' or ' '` merely restates accepted values already implied by the code. Fix: remove it unless documenting a non-obvious contract.

[WARN] BCS1202 line 481: Comment paraphrases the indentation setup below. Fix: remove it.

[WARN] BCS0505 line 482: Uses `indent_level=$((${#indent} / 2))` command substitution for arithmetic assignment instead of plain arithmetic assignment. Fix: use `indent_level=$(( ${#indent} / 2 ))`.

[WARN] BCS1202 line 485: Comment paraphrases the string append below. Fix: remove it.

[WARN] BCS1202 line 487: Comment paraphrases the checkbox formatting block. Fix: remove it.

[WARN] BCS1202 line 494: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 497: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 500: Comment paraphrases the `printf` below. Fix: remove it.

[WARN] BCS1202 line 503: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1204 line 510: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 513: Comment paraphrases the `render_blockquote()` function. Fix: remove it.

[WARN] BCS1202 line 514: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1202 line 521: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 524: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 527: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1204 line 534: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 537: Comment paraphrases the `render_hr()` function. Fix: remove it.

[WARN] BCS1202 line 538: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1204 line 547: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 550: Comment paraphrases the `render_code_line()` function. Fix: remove it.

[WARN] BCS1202 line 551: Comment only restates usage. Fix: remove it unless needed for hidden constraints.

[WARN] BCS1202 line 557: Comment paraphrases the sanitization call below. Fix: remove it.

[WARN] BCS1202 line 560: Comment paraphrases the `if` block below. Fix: remove it.

[WARN] BCS1202 line 566: Comment paraphrases the case block below. Fix: remove it.

[WARN] BCS1202 line 573: Comment paraphrases the following case block. Fix: remove it.

[WARN] BCS1202 line 592: Comment paraphrases the function purpose already obvious from the name. Fix: remove it or replace it with non-obvious constraints only.

[WARN] BCS1202 line 593: Comment documents simplification rationale; acceptable. No issue on this line.

[WARN] BCS1202 line 597: Comment paraphrases the following `if` test and return. Fix: remove it.

[WARN] BCS1202 line 603: Comment paraphrases the following `if` test and return. Fix: remove it.

[WARN] BCS1202 line 609: Comment narrates implementation and mostly paraphrases the following code. Fix: keep only durable rationale if needed, remove the rest.

[WARN] BCS1202 line 610: Comment is stylistic narration (“keep it simple”) rather than useful code context. Fix: remove it.

[WARN] BCS1202 line 618: Comment paraphrases function purpose already obvious from the name. Fix: remove it.

[WARN] BCS1202 line 619: Comment documents simplification rationale; acceptable. No issue on this line.

[WARN] BCS1202 line 623: Comment paraphrases the following `if` block. Fix: remove it.

[WARN] BCS1202 line 629: Comment paraphrases the following sed transformation. Fix: remove it.

[WARN] BCS1202 line 637: Comment paraphrases function purpose already obvious from the name. Fix: remove it.

[WARN] BCS1202 line 638: Comment documents simplification rationale; acceptable. No issue on this line.

[WARN] BCS1202 line 642: Comment paraphrases the following `if` block. Fix: remove it.

[WARN] BCS1202 line 648: Comment paraphrases the following sed transformation. Fix: remove it.

[WARN] BCS1204 line 656: Section heading uses `===` framing instead of a single `#` section comment. Fix: rewrite as a simple section comment.

[WARN] BCS1204 line 660: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 663: Comment paraphrases the `render_table()` function. Fix: remove it.

[WARN] BCS1202 line 664: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 665: Comment paraphrases observable side effect on the index variable. Fix: remove it or document a non-obvious contract more precisely.

[WARN] BCS1202 line 678: Comment paraphrases the while loop below. Fix: remove it.

[WARN] BCS1202 line 681: Comment paraphrases the regex test below. Fix: remove it.

[WARN] BCS1202 line 689: Comment paraphrases the size check below. Fix: remove it.

[WARN] BCS1202 line 696: Comment paraphrases the next function call. Fix: remove it.

[WARN] BCS1202 line 702: Comment paraphrases the `if` block below. Fix: remove it.

[WARN] BCS1202 line 704: Comment paraphrases the assignments below. Fix: remove it.

[WARN] BCS1202 line 706: Comment paraphrases the slice assignment below. Fix: remove it.

[WARN] BCS1202 line 708: Comment paraphrases the else branch below. Fix: remove it.

[WARN] BCS1202 line 712: Comment paraphrases the while loop below. Fix: remove it.

[WARN] BCS1202 line 718: Comment paraphrases the next function call. Fix: remove it.

[WARN] BCS1202 line 722: Comment paraphrases the next function call. Fix: remove it.

[WARN] BCS1204 line 728: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 731: Comment paraphrases the `_parse_table_structure()` function. Fix: remove it.

[WARN] BCS1202 line 732: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 747: Comment paraphrases the trimming code below. Fix: remove it.

[WARN] BCS1202 line 751: Comment paraphrases the parameter expansions below. Fix: remove it.

[WARN] BCS1003 line 756: Uses `IFS='|' read ...` without local scoping or subshell isolation. Fix: use `local -- IFS='|'` before the `read`, or keep an explicitly scoped single-command form consistent with BCS guidance.

[WARN] BCS1202 line 755: Comment paraphrases the split operation below. Fix: remove it.

[WARN] BCS1202 line 758: Comment paraphrases the trimming loop below. Fix: remove it.

[WARN] BCS1202 line 766: Comment paraphrases the alignment detection logic below. Fix: remove it.

[WARN] BCS1202 line 775: Comment paraphrases the loop below. Fix: remove it.

[WARN] BCS1202 line 788: Comment paraphrases the `printf -v` row storage below. Fix: remove it.

[WARN] BCS1202 line 792: Comment paraphrases the max column tracking below. Fix: remove it.

[WARN] BCS1204 line 800: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 803: Comment paraphrases the `_calculate_column_widths()` function. Fix: remove it.

[WARN] BCS1202 line 804: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 814: Comment paraphrases the initialization loop below. Fix: remove it.

[WARN] BCS1202 line 819: Comment paraphrases the row loop below. Fix: remove it.

[WARN] BCS1003 line 822: Uses `IFS=$'\037' read ...` without local scoping or subshell isolation. Fix: use `local -- IFS=$'\037'` before `read`, or an explicitly scoped form consistent with BCS guidance.

[WARN] BCS1202 line 821: Comment paraphrases the parse step below. Fix: remove it.

[WARN] BCS1202 line 824: Comment paraphrases the inner loop below. Fix: remove it.

[WARN] BCS1202 line 828: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 831: Comment paraphrases the stripping/length logic below. Fix: remove it.

[WARN] BCS1202 line 835: Comment paraphrases the comparison below. Fix: remove it.

[WARN] BCS1204 line 843: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 846: Comment paraphrases the `_render_table_output()` function. Fix: remove it.

[WARN] BCS1202 line 847: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 862: Comment paraphrases the initialization below. Fix: remove it.

[WARN] BCS1202 line 873: Comment paraphrases the print statement below. Fix: remove it.

[WARN] BCS1202 line 877: Comment paraphrases the row loop below. Fix: remove it.

[WARN] BCS1003 line 880: Uses `IFS=$'\037' read ...` without local scoping or subshell isolation. Fix: use `local -- IFS=$'\037'` before `read`, or an explicitly scoped form consistent with BCS guidance.

[WARN] BCS1202 line 879: Comment paraphrases the parse step below. Fix: remove it.

[WARN] BCS1202 line 882: Comment paraphrases the padding loop below. Fix: remove it.

[WARN] BCS1202 line 887: Comment paraphrases the `printf` below. Fix: remove it.

[WARN] BCS1202 line 890: Comment paraphrases the inner loop below. Fix: remove it.

[WARN] BCS1202 line 894: Comment paraphrases the command below. Fix: remove it.

[WARN] BCS1202 line 897: Comment paraphrases the substitution below. Fix: remove it.

[WARN] BCS1202 line 901: Comment paraphrases the alignment call below. Fix: remove it.

[WARN] BCS1202 line 905: Comment paraphrases the `printf` below. Fix: remove it.

[WARN] BCS1202 line 911: Comment paraphrases the following `if` block. Fix: remove it.

[WARN] BCS1202 line 920: Comment paraphrases the final print statement. Fix: remove it.

[WARN] BCS1204 line 924: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 927: Comment paraphrases the `_align_cell()` function. Fix: remove it.

[WARN] BCS1202 line 928: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 936: Comment paraphrases the stripping code below. Fix: remove it.

[WARN] BCS1202 line 940: Comment paraphrases the padding arithmetic below. Fix: remove it.

[WARN] BCS1202 line 946: Comment paraphrases the center-alignment branch below. Fix: remove it.

[WARN] BCS1202 line 952: Comment paraphrases the right-alignment branch below. Fix: remove it.

[WARN] BCS1202 line 956: Comment paraphrases the default branch below. Fix: remove it.

[WARN] BCS1204 line 962: Section heading uses `===` framing instead of a single `#` section comment. Fix: rewrite as a simple section comment.

[WARN] BCS1204 line 966: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1204 line 968: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 969: Comment paraphrases the following `render_footnotes()` function heading. Fix: remove it.

[WARN] BCS1202 line 971: Comment paraphrases the `render_footnotes()` function. Fix: remove it.

[WARN] BCS1202 line 989: Comment paraphrases the else branch below. Fix: remove it.

[WARN] BCS1202 line 999: Comment paraphrases the `parse_markdown()` function. Fix: remove it.

[WARN] BCS1202 line 1000: Comment only restates usage. Fix: remove it unless documenting hidden constraints.

[WARN] BCS1202 line 1006: Comment paraphrases the assignments below. Fix: remove it.

[WARN] BCS1202 line 1024: Comment paraphrases the trimming expansion below. Fix: remove it.

[WARN] BCS1204 line 1027: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1028: Comment narrates the block type just handled by the regex below. Fix: remove it.

[WARN] BCS1202 line 1029: Comment paraphrases the regex itself. Fix: remove it.

[WARN] BCS1202 line 1038: Comment paraphrases the branch meaning already obvious from the condition. Fix: remove it.

[WARN] BCS1202 line 1044: Comment paraphrases the else-branch behavior. Fix: remove it.

[WARN] BCS1202 line 1048: Comment paraphrases the opening-fence branch. Fix: remove it.

[WARN] BCS1202 line 1060: Comment paraphrases the `if` block below. Fix: remove it.

[WARN] BCS1204 line 1067: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1068: Comment paraphrases the regex/classification below. Fix: remove it.

[WARN] BCS1202 line 1071: Comment paraphrases the side effect just relied on. Fix: remove it unless documenting a subtle contract not obvious from the function signature.

[WARN] BCS1202 line 1074: Comment paraphrases the else-if branch behavior. Fix: remove it.

[WARN] BCS1204 line 1082: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1083: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1204 line 1090: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1091: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1204 line 1099: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1100: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1204 line 1109: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1110: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1202 line 1119: Comment paraphrases the else-branch behavior. Fix: remove it.

[WARN] BCS1204 line 1126: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1127: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1204 line 1136: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1137: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1204 line 1147: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1148: Comment paraphrases the regex category below. Fix: remove it.

[WARN] BCS1202 line 1153: Comment paraphrases the assignment below. Fix: remove it.

[WARN] BCS1202 line 1156: Comment paraphrases the following duplicate-check block. Fix: remove it.

[WARN] BCS1202 line 1161: Comment paraphrases the `continue` behavior below. Fix: remove it.

[WARN] BCS1204 line 1166: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1167: Comment paraphrases the empty-line branch below. Fix: remove it.

[WARN] BCS1204 line 1174: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1175: Comment paraphrases the default text-handling block. Fix: remove it.

[WARN] BCS1202 line 1177: Comment paraphrases the tracking logic below. Fix: remove it.

[WARN] BCS1202 line 1185: Comment paraphrases the substitution below. Fix: remove it.

[WARN] BCS1202 line 1188: Comment paraphrases the restoration assignment below. Fix: remove it.

[WARN] BCS1204 line 1198: 80-dash separator used for an ordinary section. Fix: use a normal single-line section comment.

[WARN] BCS1202 line 1199: Comment paraphrases the following `if` block. Fix: remove it.

[WARN] BCS1204 line 1205: Section heading uses `===` framing instead of a single `#` section comment. Fix: rewrite as a simple section comment.

[WARN] BCS1202 line 1209: Comment paraphrases the `show_help()` function. Fix: remove it.

[WARN] BCS0806 line 1224: Uses non-standard short option `-D` for debug only because BCS standard assigns `-D` to debug when used; this one is fine. No issue here.

[WARN] BCS1202 line 1265: Comment paraphrases the `parse_arguments()` function. Fix: remove it.

[WARN] BCS0801 line 1268: Argument parsing loop is split across two lines instead of the standard `while (($#)); do case $1 in ... esac; shift; done` pattern. Fix: rewrite to the canonical compact form if aiming for BCS consistency.

[WARN] BCS0803 line 1271: `noarg()` rejects arguments beginning with `-`, so valid option arguments like negative values or strings starting with dash cannot be passed to `--width`; BCS `noarg()` is meant to check existence only. Fix: change `noarg()` to `(($# > 1)) || die 22 "Option ${1@Q} requires an argument"` and perform value validation separately.

[WARN] BCS0501 line 1275: Uses `((TERM_WIDTH >= 20 && TERM_WIDTH <= 500))` instead of simpler arithmetic truth patterns where appropriate. Fix: leave as-is for range testing if desired; this is at most a minor style deviation.

[WARN] BCS1202 line 1289: Comment adds some rationale for plain mode; acceptable. No issue on this line.

[WARN] BCS1202 line 1321: Inline comment `Bundled short options` paraphrases the pattern below. Fix: remove it.

[WARN] BCS1202 line 1330: Comment paraphrases the default case below. Fix: remove it.

[WARN] BCS1202 line 1338: Comment paraphrases the following function group. Fix: remove it or replace it with a proper short section comment.

[WARN] BCS1202 line 1340: Comment paraphrases the `process_file()` function. Fix: remove it.

[WARN] BCS1202 line 1347: Comment paraphrases the branch below. Fix: remove it.

[WARN] BCS1202 line 1351: Comment paraphrases the read loop below. Fix: remove it unless documenting a non-obvious encoding constraint.

[WARN] BCS1202 line 1353: Comment paraphrases the `if` below. Fix: remove it.

[WARN] BCS1202 line 1360: Comment paraphrases the else branch below. Fix: remove it.

[WARN] BCS1202 line 1364: Comment paraphrases the read loop below. Fix: remove it.

[WARN] BCS1202 line 1367: Comment paraphrases the arithmetic below. Fix: remove it.

[WARN] BCS0602 line 1370: Uses exit code `9`, which is not among the standard documented exit codes in BCS0602. Fix: use a documented code such as `22` or `5`, depending on intended classification.

[WARN] BCS1202 line 1373: Comment paraphrases the `if` below. Fix: remove it.

[WARN] BCS1202 line 1383: Comment paraphrases the function call below. Fix: remove it.

[WARN] BCS1202 line 1387: Comment paraphrases the `main()` function heading. Fix: remove it or replace it with a proper short section comment.

[WARN] BCS1202 line 1390: Comment paraphrases the call below. Fix: remove it.

[WARN] BCS1202 line 1393: Comment paraphrases the assignment below. Fix: remove it.

[WARN] BCS1205 line 1401: Uses external `sed` in `debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"` where builtin parameter/string handling should be preferred when practical. Fix: avoid the external `sed`, e.g. debug the raw `declare -p` output or transform it with shell parameter expansion.

[WARN] BCS1202 line 1403: Comment paraphrases the reset print below. Fix: remove it.

[WARN] BCS1202 line 1406: Comment paraphrases the control-flow block below. Fix: remove it.

[WARN] BCS1202 line 1412: Comment paraphrases the `if` below. Fix: remove it.

[WARN] BCS1202 line 1418: Comment paraphrases the else branch below. Fix: remove it.

[WARN] BCS1202 line 1422: Comment paraphrases the reset print below. Fix: remove it.

[WARN] BCS1202 line 1428: Comment paraphrases the invocation below. Fix: remove it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0103 | recommended | [WARN] | 13 | Non-standard script metadata pattern; direct `$0` extraction instead of recommended `realpath`-based metadata block |
| BCS1202 | style | [WARN] | 16, 17, 53, 65, 68, 71, 85, 86, 90, 100, 112, 123, 124, 133, 136, 150, 154, 158, 164, 165, 177, 178, 183, 193, 195, 203, 204, 212, 213, 222, 223, 232, 246, 247, 250, 255, 256, 263, 264, 277, 278, 285, 288, 293, 298, 301, 305, 308, 309, 311, 314, 317, 328, 329, 338, 341, 347, 350, 360, 365, 372, 379, 380, 386, 396, 405, 406, 415, 420, 423, 426, 429, 436, 437, 447, 454, 457, 460, 463, 470, 471, 474, 481, 485, 487, 494, 497, 500, 503, 513, 514, 521, 524, 527, 537, 538, 550, 551, 557, 560, 566, 573, 592, 597, 603, 609, 610, 618, 623, 629, 637, 642, 648, 663, 664, 665, 678, 681, 689, 696, 702, 704, 706, 708, 712, 718, 722, 731, 732, 747, 751, 755, 758, 766, 775, 788, 792, 803, 804, 814, 819, 821, 824, 828, 831, 835, 846, 847, 862, 873, 877, 879, 882, 887, 890, 894, 897, 901, 905, 911, 920, 927, 928, 936, 940, 946, 952, 956, 969, 971, 989, 999, 1000, 1006, 1024, 1028, 1029, 1038, 1044, 1048, 1060, 1068, 1071, 1074, 1083, 1091, 1100, 1110, 1119, 1127, 1137, 1148, 1153, 1156, 1161, 1167, 1175, 1177, 1185, 1188, 1199, 1209, 1265, 1321, 1330, 1338, 1340, 1347, 1351, 1353, 1360, 1364, 1367, 1373, 1383, 1387, 1390, 1393, 1403, 1406, 1412, 1418, 1422, 1428 | Comments paraphrase adjacent code instead of adding non-obvious context |
| BCS1204 | style | [WARN] | 39, 43, 50, 82, 120, 147, 161, 173, 192, 243, 270, 274, 325, 376, 402, 510, 534, 547, 656, 660, 728, 800, 843, 924, 962, 966, 968, 1027, 1067, 1082, 1090, 1099, 1109, 1126, 1136, 1147, 1166, 1174, 1198, 1205 | Non-compliant section comments and overuse of 80-dash separators |
| BCS0702 | core | [WARN] | 62 | `_msg()` emits status text to stdout rather than stderr |
| BCS0602 | recommended | [WARN] | 134, 140, 1370 | Uses undocumented/non-standard exit codes (`4`, `9`) |
| BCS0707 | recommended | [WARN] | 185 | Color/TUI detection may enable ANSI output for non-terminal stdout/stderr |
| BCS1003 | recommended | [WARN] | 348, 756, 822, 880 | IFS modifications on `read` not localized with `local`/subshell per rule guidance |
| BCS0505 | style | [WARN] | 416, 448, 450, 482 | Arithmetic assignment done via command substitution style instead of plain arithmetic assignment |
| BCS0801 | core | [WARN] | 1268 | Non-canonical argument parsing layout |
| BCS0803 | core | [WARN] | 1271 | `noarg()` improperly rejects option arguments that begin with `-` |
| BCS1205 | style | [WARN] | 1401 | Uses external `sed` where builtin handling should be preferred |
bcs: ◉ Tokens: in=39583 out=10102
bcs: ◉ Elapsed: 109s
