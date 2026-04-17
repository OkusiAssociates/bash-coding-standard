bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
[WARN] BCS1204 line 50: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace this with a simple 2–4 word section comment such as `# Messaging functions`.

[WARN] BCS1202 line 53: comment paraphrases the function below without adding non-obvious information. Fix: remove the comment or replace it with a note about a constraint/rationale not evident from the code.

[WARN] BCS1202 line 65: comment paraphrases the following function declarations without adding information. Fix: remove it or replace it with a comment that explains a non-obvious design constraint.

[WARN] BCS1202 line 68: comment paraphrases the `die()` function immediately below. Fix: remove it or replace it with useful context not obvious from the code.

[WARN] BCS1204 line 82: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace this with a simple section comment such as `# Terminal detection`.

[WARN] BCS1202 line 85: comment paraphrases the `get_terminal_width()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1204 line 120: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 line 123: comment paraphrases the validation function below. Fix: remove it or replace it with a comment that adds information not recoverable from the code.

[WARN] BCS1202 line 133: comment restates the visible directory check on the next line. Fix: remove the comment.

[WARN] BCS1202 line 136: comment paraphrases the `stat` call below. Fix: remove it unless you add non-obvious rationale.

[WARN] BCS1204 line 147: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 line 150: comment paraphrases the cleanup function declaration. Fix: remove it or replace it with non-obvious context.

[WARN] BCS1202 line 158: comment paraphrases the trap installation immediately below. Fix: remove it.

[WARN] BCS1204 line 161: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 line 164: comment paraphrases the `noarg()` helper below. Fix: remove it or replace it with a note about the deliberate “reject option-like argument” behavior.

[WARN] BCS1204 lines 173-175: uses multi-line ASCII separator comments instead of a single-line 2–4 word section comment. Fix: replace with a single line such as `# ANSI colors`.

[WARN] BCS1202 lines 177-181: comment block mostly paraphrases the color-detection code below. Fix: shorten it to only the non-obvious design rationale, or remove it.

[WARN] BCS1202 line 183: comment restates the following conditional test. Fix: remove it.

[WARN] BCS1204 line 192: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 line 246: comment paraphrases the `strip_ansi()` function. Fix: remove it or keep only non-obvious implementation notes.

[WARN] BCS1202 line 250: comment largely restates the `sed` expression below. Fix: remove it unless documenting a regex limitation or caveat.

[WARN] BCS1202 line 255: comment paraphrases the `visible_length()` function. Fix: remove it or replace it with non-obvious rationale.

[WARN] BCS1202 line 263: comment paraphrases the `sanitize_ansi()` function. Fix: remove it.

[WARN] BCS1204 lines 270-272: uses multi-line ASCII separator comments instead of a single-line 2–4 word section comment. Fix: replace with a single line such as `# Rendering functions`.

[WARN] BCS1204 line 274: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 277-279: comment block paraphrases the function below; only “order matters” is useful, the rest is recoverable from code. Fix: reduce to the ordering rationale only.

[WARN] BCS1204 line 325: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 328-329: comment paraphrases the `wrap_text()` function. Fix: remove it or keep only non-obvious constraints.

[WARN] BCS1204 line 376: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 379-380: comment paraphrases the `render_header()` function. Fix: remove it.

[WARN] BCS1204 line 402: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 405-406: comment paraphrases the `render_list_item()` function. Fix: remove it.

[WARN] BCS1202 line 415: comment restates the calculation on the next line. Fix: remove it.

[WARN] BCS1202 line 420: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 line 423: comment paraphrases the next `readarray` call. Fix: remove it.

[WARN] BCS1202 line 426: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 429: comment restates the loop purpose. Fix: remove it.

[WARN] BCS1202 lines 436-437: comment paraphrases the `render_ordered_item()` function. Fix: remove it.

[WARN] BCS1202 line 447: comment restates the indentation calculation below. Fix: remove it.

[WARN] BCS1202 line 454: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 line 457: comment paraphrases the next `readarray` call. Fix: remove it.

[WARN] BCS1202 line 460: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 463: comment restates the continuation-lines loop. Fix: remove it.

[WARN] BCS1202 lines 470-471: comment paraphrases the `render_task_item()` function. Fix: remove it.

[WARN] BCS1202 line 481: comment restates the indentation calculation below. Fix: remove it.

[WARN] BCS1202 line 487: comment paraphrases the checkbox formatting block. Fix: remove it.

[WARN] BCS1202 line 494: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 line 497: comment paraphrases the next `readarray` call. Fix: remove it.

[WARN] BCS1202 line 500: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 503: comment restates the continuation-lines loop. Fix: remove it.

[WARN] BCS1204 line 510: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 513-514: comment paraphrases the `render_blockquote()` function. Fix: remove it.

[WARN] BCS1202 line 521: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 line 524: comment paraphrases the next `readarray` call. Fix: remove it.

[WARN] BCS1202 line 527: comment restates the following loop purpose. Fix: remove it.

[WARN] BCS1204 line 534: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 537-538: comment paraphrases the `render_hr()` function. Fix: remove it.

[WARN] BCS1204 line 547: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 550-551: comment paraphrases the `render_code_line()` function. Fix: remove it.

[WARN] BCS1202 line 557: comment paraphrases the following assignment. Fix: remove it.

[WARN] BCS1202 line 560: comment paraphrases the conditional below. Fix: remove it.

[WARN] BCS1202 line 566: comment paraphrases the following `case` block. Fix: remove it.

[WARN] BCS1202 line 573: comment paraphrases the following `case` block. Fix: remove it.

[WARN] BCS1202 line 592: comment paraphrases the function below; the “simplified” note is useful, but “Simple Python syntax highlighting” is not. Fix: keep only the non-obvious limitation/rationale.

[WARN] BCS1202 line 597: comment restates the immediate-return comment handling below. Fix: remove it.

[WARN] BCS1202 line 603: comment restates the immediate-return docstring handling below. Fix: remove it.

[WARN] BCS1202 lines 609-610: comment paraphrases the minimal-highlighting code below. Fix: remove or condense to only the rationale about avoiding ANSI conflicts.

[WARN] BCS1202 line 618: comment paraphrases the function below; only the limitation note is useful. Fix: keep only the non-obvious rationale.

[WARN] BCS1202 line 623: comment restates the early-return comment handling below. Fix: remove it.

[WARN] BCS1202 line 629: comment paraphrases the minimal-highlighting code below. Fix: remove it.

[WARN] BCS1202 line 637: comment paraphrases the function below; only the limitation note is useful. Fix: keep only the non-obvious rationale.

[WARN] BCS1202 line 642: comment restates the early-return comment handling below. Fix: remove it.

[WARN] BCS1202 line 648: comment paraphrases the minimal-highlighting code below. Fix: remove it.

[WARN] BCS1204 lines 656-658: uses multi-line ASCII separator comments instead of a single-line 2–4 word section comment. Fix: replace with a single line such as `# Table rendering`.

[WARN] BCS1204 line 660: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 663-665: comment paraphrases the `render_table()` function. Fix: remove it or keep only the note about index mutation if that behavior is not obvious to callers.

[WARN] BCS1202 line 678: comment restates the collection loop below. Fix: remove it.

[WARN] BCS1202 line 689: comment paraphrases the validation check below. Fix: remove it.

[WARN] BCS1202 line 695: comment restates the next step. Fix: remove it.

[WARN] BCS1202 line 702: comment restates the separation logic below. Fix: remove it.

[WARN] BCS1202 line 712: comment paraphrases the padding loop below. Fix: remove it.

[WARN] BCS1202 line 718: comment restates the function call below. Fix: remove it.

[WARN] BCS1202 line 722: comment restates the function call below. Fix: remove it.

[WARN] BCS1204 line 728: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 731-732: comment paraphrases the `_parse_table_structure()` function. Fix: remove it.

[WARN] BCS1202 line 747: comment restates the trimming operations below. Fix: remove it.

[WARN] BCS1202 line 751: comment restates the pipe-removal operations below. Fix: remove it.

[WARN] BCS1202 line 755: comment paraphrases the following `read` command. Fix: remove it.

[WARN] BCS1202 line 758: comment paraphrases the following loop. Fix: remove it.

[WARN] BCS1202 line 766: comment restates the alignment-row detection logic below. Fix: remove it.

[WARN] BCS1202 line 775: comment paraphrases the following loop. Fix: remove it.

[WARN] BCS1202 line 788: comment paraphrases the `printf -v` serialization below. Fix: remove it unless documenting why unit separator was chosen.

[WARN] BCS1202 line 792: comment restates the max-column tracking below. Fix: remove it.

[WARN] BCS1204 line 800: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 803-804: comment paraphrases the `_calculate_column_widths()` function. Fix: remove it.

[WARN] BCS1202 line 814: comment restates the initialization loop below. Fix: remove it.

[WARN] BCS1202 line 819: comment restates the row-processing loop below. Fix: remove it.

[WARN] BCS1202 line 821: comment paraphrases the `read` statement below. Fix: remove it.

[WARN] BCS1202 line 824: comment restates the inner measurement loop below. Fix: remove it.

[WARN] BCS1202 line 828: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 line 831: comment paraphrases the next two lines. Fix: remove it.

[WARN] BCS1202 line 835: comment restates the conditional assignment below. Fix: remove it.

[WARN] BCS1204 line 843: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 846-847: comment paraphrases the `_render_table_output()` function. Fix: remove it.

[WARN] BCS1202 line 862: comment restates the divider-building block below. Fix: remove it.

[WARN] BCS1202 line 873: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 877: comment restates the row loop below. Fix: remove it.

[WARN] BCS1202 line 879: comment paraphrases the next `read` statement. Fix: remove it.

[WARN] BCS1202 line 882: comment restates the padding loop below. Fix: remove it.

[WARN] BCS1202 line 887: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 890: comment restates the inner cell loop below. Fix: remove it.

[WARN] BCS1202 line 894: comment paraphrases the next assignment. Fix: remove it.

[WARN] BCS1202 lines 897-898: comment explains non-obvious color-reset behavior. No issue there, but the first sentence is partially paraphrastic. Fix: keep only the rationale sentence if editing.

[WARN] BCS1202 line 901: comment restates the next assignment. Fix: remove it.

[WARN] BCS1202 line 905: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1202 line 911: comment restates the following conditional. Fix: remove it.

[WARN] BCS1202 line 920: comment restates the following `printf`. Fix: remove it.

[WARN] BCS1204 line 924: uses an 80-dash separator as a routine section divider; the standard reserves such separators for major script divisions only and typically no more than two or three per file. Fix: replace it with a simple section comment.

[WARN] BCS1202 lines 927-928: comment paraphrases the `_align_cell()` function. Fix: remove it.

[WARN] BCS1202 line 936: comment paraphrases the next two lines. Fix: remove it.

[WARN] BCS1202 line 940: comment paraphrases the next two lines. Fix: remove it.

[WARN] BCS1202 lines 962-964: uses multi-line ASCII separator comments instead of a single-line 2–4 word section comment. Fix: replace with a single line such as `# Markdown parser`.

[WARN] BCS1204 lines 966-968: includes an 80-dash separator and redundant multi-line section framing for a routine section. Fix: replace with a simple single-line section comment.

[WARN] BCS1202 line 971: comment paraphrases the `render_footnotes()` function. Fix: remove it.

[WARN] BCS1202 lines 999-1000: comment paraphrases the `parse_markdown()` function. Fix: remove it.

[WARN] BCS1202 line 1006: comment restates the state-reset block below. Fix: remove it.

[WARN] BCS1202 lines 1028-1029: comment block mostly paraphrases the regex below; only the note about literal backticks may be useful. Fix: keep only the non-obvious regex note.

[WARN] BCS1202 line 1060: comment restates the conditional branch below. Fix: remove it.

[WARN] BCS1202 line 1068: comment restates the following table detection branch. Fix: remove it.

[WARN] BCS1202 line 1071: comment paraphrases the effect already documented by the call pattern. Fix: remove it unless callers truly need the mutation note here.

[WARN] BCS1202 line 1074: comment restates the branch behavior below. Fix: remove it.

[WARN] BCS1202 line 1083: comment restates the horizontal-rule branch below. Fix: remove it.

[WARN] BCS1202 line 1091: comment restates the blockquote branch below. Fix: remove it.

[WARN] BCS1202 line 1100: comment restates the header branch below. Fix: remove it.

[WARN] BCS1202 line 1110: comment restates the task-list branch below. Fix: remove it.

[WARN] BCS1202 line 1119: comment paraphrases the else branch below. Fix: remove it.

[WARN] BCS1202 line 1127: comment restates the unordered-list branch below. Fix: remove it.

[WARN] BCS1202 line 1137: comment restates the ordered-list branch below. Fix: remove it.

[WARN] BCS1202 line 1148: comment restates the footnote-definition branch below. Fix: remove it.

[WARN] BCS1202 line 1153: comment paraphrases the assignment below. Fix: remove it.

[WARN] BCS1202 line 1156: comment paraphrases the deduplication block below. Fix: remove it.

[WARN] BCS1202 line 1161: comment restates the `continue` behavior below. Fix: remove it.

[WARN] BCS1202 line 1167: comment restates the empty-line branch below. Fix: remove it.

[WARN] BCS1202 line 1175: comment restates the regular-text path below. Fix: remove it.

[WARN] BCS1202 line 1177: comment paraphrases the footnote-reference tracking block below. Fix: remove it.

[WARN] BCS1202 line 1185: comment restates the substitution below. Fix: remove it.

[WARN] BCS1202 line 1188: comment restates the restoration assignment below. Fix: remove it.

[WARN] BCS1202 lines 1198-1199: comment paraphrases the final footnote-rendering condition below. Fix: remove it.

[WARN] BCS1204 lines 1205-1207: uses multi-line ASCII separator comments instead of a single-line 2–4 word section comment. Fix: replace with a single line such as `# Main functions`.

[WARN] BCS1202 line 1209: comment paraphrases the `show_help()` function. Fix: remove it.

[WARN] BCS1202 line 1265: comment paraphrases the `parse_arguments()` function. Fix: remove it.

[WARN] BCS0801 line 1268: argument parsing does not use the standard compact `while (($#)); do case $1 in ... esac; shift; done` pattern. Fix: rewrite as the canonical single-loop form with `do case` on one line if practical.

[WARN] BCS1202 line 1338: comment paraphrases the following section/function grouping. Fix: remove it.

[WARN] BCS1202 line 1340: comment paraphrases the `process_file()` function. Fix: remove it.

[WARN] BCS1202 line 1347: comment restates the file-processing branch below. Fix: remove it.

[WARN] BCS1202 line 1351: comment paraphrases the file-reading loop below. Fix: remove it.

[WARN] BCS1202 line 1353: comment explains intent, but mostly paraphrases the shebang-skip condition. Fix: keep only if this behavior is important and non-obvious; otherwise remove.

[WARN] BCS1202 line 1360: comment restates the stdin branch below. Fix: remove it.

[WARN] BCS1202 line 1364: comment paraphrases the stdin-reading loop below. Fix: remove it.

[WARN] BCS1202 line 1367: comment restates the increment purpose. Fix: remove it.

[WARN] BCS1202 line 1373: comment explains intent, but mostly paraphrases the shebang-skip condition. Fix: keep only if necessary; otherwise remove.

[WARN] BCS1202 line 1383: comment restates the function call below. Fix: remove it.

[WARN] BCS1202 line 1387: comment paraphrases the `main()` function label. Fix: remove it.

[WARN] BCS1202 line 1390: comment restates the call below. Fix: remove it.

[WARN] BCS1202 line 1393: comment restates the terminal-width logic below. Fix: remove it.

[WARN] BCS1202 line 1403: comment restates the reset `printf` below. Fix: remove it.

[WARN] BCS1202 line 1406: comment restates the processing branch below. Fix: remove it.

[WARN] BCS1202 line 1412: comment restates the newline conditional below. Fix: remove it.

[WARN] BCS1202 line 1418: comment restates the stdin fallback below. Fix: remove it.

[WARN] BCS1202 line 1422: comment restates the final reset `printf` below. Fix: remove it.

[WARN] BCS1202 line 1428: comment paraphrases the script invocation below. Fix: remove it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS1204 | style | [WARN] | 50, 82, 120, 147, 161, 192, 274, 325, 376, 402, 510, 534, 547, 660, 728, 800, 843, 924 | Routine use of 80-dash separators instead of simple single-line section comments |
| BCS1204 | style | [WARN] | 173-175, 270-272, 656-658, 962-964, 966-968, 1205-1207 | Multi-line ASCII section framing instead of single-line 2–4 word section comments |
| BCS1202 | style | [WARN] | 53, 65, 68, 85, 123, 133, 136, 150, 158, 164, 177-181, 183, 246, 250, 255, 263, 277-279, 328-329, 379-380, 405-406, 415, 420, 423, 426, 429, 436-437, 447, 454, 457, 460, 463, 470-471, 481, 487, 494, 497, 500, 503, 513-514, 521, 524, 527, 537-538, 550-551, 557, 560, 566, 573, 592, 597, 603, 609-610, 618, 623, 629, 637, 642, 648, 663-665, 678, 689, 695, 702, 712, 718, 722, 731-732, 747, 751, 755, 758, 766, 775, 788, 792, 803-804, 814, 819, 821, 824, 828, 831, 835, 846-847, 862, 873, 877, 879, 882, 887, 890, 894, 897-898, 901, 905, 911, 920, 927-928, 936, 940, 971, 999-1000, 1006, 1028-1029, 1060, 1068, 1071, 1074, 1083, 1091, 1100, 1110, 1119, 1127, 1137, 1148, 1153, 1156, 1161, 1167, 1175, 1177, 1185, 1188, 1198-1199, 1209, 1265, 1338, 1340, 1347, 1351, 1353, 1360, 1364, 1367, 1373, 1383, 1387, 1390, 1393, 1403, 1406, 1412, 1418, 1422, 1428 | Comments paraphrase adjacent code without adding non-obvious information |
| BCS0801 | core | [WARN] | 1268 | Argument parsing deviates from the standard compact `while (($#)); do case ...; shift; done` form |
bcs: ◉ Tokens: in=39581 out=6169
bcs: ◉ Elapsed: 71s
