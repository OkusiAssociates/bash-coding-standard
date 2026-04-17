bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
[WARN] BCS0103 line 13: script metadata is incomplete; `SCRIPT_NAME` is derived from `$0` instead of the standard `realpath`-based metadata pattern, and the inline `#bcscheck disable=BCS0103` does not suppress this line because it applies only to the next command on line 13. Fix: declare metadata per BCS0103, e.g. `#shellcheck disable=SC2155` then `declare -r SCRIPT_PATH=$(realpath -- "$0")` and derive `SCRIPT_DIR`/`SCRIPT_NAME` from it, or move the suppression to the actual command if intentionally deviating.

[WARN] BCS1204 line 39: section comment uses decorative `## ... ##` style instead of a single `#` section comment. Fix: rewrite as a simple section comment such as `# Utility functions`.

[WARN] BCS1204 line 50: major divider uses an 80-dash separator, which BCS reserves for only two or three major script divisions per file; this script uses many such separators. Fix: replace most separators with normal single-line section comments such as `# Core messaging functions`.

[WARN] BCS1202 line 65: comment paraphrases the code below (`# Unconditional output` above `warn()`/`error()`). Fix: remove it or replace it with a comment that adds non-obvious rationale.

[WARN] BCS1202 line 68: comment paraphrases the code below (`# Exit with error` above `die()`). Fix: remove it or replace it with a comment that adds useful context.

[WARN] BCS1202 line 85: comment paraphrases the function below (`# Get terminal width with multiple fallback methods`). Fix: remove it or keep only the following comment that adds actual detail about fallback methods/bounds.

[WARN] BCS1204 line 120: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 123: comment paraphrases the function below (`# Validate file exists, is readable, and within size limits`). Fix: remove it or replace it with non-obvious constraints only.

[WARN] BCS1202 line 133: comment paraphrases the next statement (`# Check if it's a directory`). Fix: remove it.

[WARN] BCS1202 line 136: comment paraphrases the next statement (`# Get file size in bytes`). Fix: remove it.

[WARN] BCS1204 line 147: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 150: comment paraphrases the function below (`# Cleanup function called on exit/interrupt`). Fix: remove it or replace it with rationale not obvious from the code.

[WARN] BCS1202 line 154: comment paraphrases the next statement (`# Reset terminal to clean state`). Fix: remove it.

[WARN] BCS1202 line 158: comment paraphrases the next statement (`# Install signal handlers`). Fix: remove it.

[WARN] BCS1204 line 173: section comment uses decorative `===...===` framing instead of a single `#` comment. Fix: rewrite as `# ANSI color definitions`.

[WARN] BCS1202 line 177: comment paraphrases the declaration block below (`# Detect terminal color support`). Fix: remove it; keep the subsequent explanatory comment if needed.

[WARN] BCS0706 line 185: color detection enables ANSI colors when `TERM` is set and not `dumb`, even if stdout/stderr are not terminals; BCS requires TUI/color gating on terminal detection. Fix: gate ANSI color definitions on `[[ -t 1 && -t 2 ]]` only, or separate terminal TUI behavior from any non-TTY plain output mode.

[WARN] BCS1204 line 192: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 246: comment paraphrases the function below (`# Strip ANSI escape sequences from text`). Fix: remove it or retain only the usage/rationale comment.

[WARN] BCS1202 line 255: comment paraphrases the function below (`# Get visible length of text...`). Fix: remove it or retain only the usage/rationale comment.

[WARN] BCS1202 line 263: comment paraphrases the function below (`# Sanitize input by removing ANSI sequences`). Fix: remove it or retain only the usage/rationale comment.

[WARN] BCS1204 line 270: section comment uses decorative `===...===` framing instead of a single `#` comment. Fix: rewrite as `# Rendering functions`.

[WARN] BCS1204 line 274: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 277: comment paraphrases the function below (`# Apply all inline formatting to a line of text`). Fix: remove it; keep only the order/rationale comment if desired.

[WARN] BCS1204 line 325: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 328: comment paraphrases the function below (`# Wrap text to specified width, preserving ANSI codes`). Fix: remove it or keep only usage/context comments.

[WARN] BCS1204 line 376: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 379: comment paraphrases the function below (`# Render a markdown header with appropriate color`). Fix: remove it.

[WARN] BCS1202 line 386: comment paraphrases the next `case` block (`# Determine color based on header level`). Fix: remove it.

[WARN] BCS1202 line 396: comment paraphrases the next statement (`# Apply inline formatting to header text`). Fix: remove it.

[WARN] BCS1204 line 402: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 405: comment paraphrases the function below (`# Render unordered list item with proper indentation`). Fix: remove it.

[WARN] BCS1202 line 415: comment paraphrases the next statements (`# Calculate indentation level...`). Fix: remove it.

[WARN] BCS1202 line 420: comment paraphrases the next statement (`# Apply inline formatting`). Fix: remove it.

[WARN] BCS1202 line 423: comment paraphrases the next statement (`# Wrap text to terminal width`). Fix: remove it.

[WARN] BCS1202 line 426: comment paraphrases the next `printf` (`# Print first line with bullet`). Fix: remove it.

[WARN] BCS1202 line 429: comment paraphrases the following loop (`# Print continuation lines if any`). Fix: remove it.

[WARN] BCS1202 line 436: comment paraphrases the function below (`# Render ordered list item`). Fix: remove it.

[WARN] BCS1202 line 447: comment paraphrases the next statements (`# Calculate indentation`). Fix: remove it.

[WARN] BCS1202 line 454: comment paraphrases the next statement (`# Apply inline formatting`). Fix: remove it.

[WARN] BCS1202 line 457: comment paraphrases the next statement (`# Wrap text`). Fix: remove it.

[WARN] BCS1202 line 460: comment paraphrases the next statement (`# Print first line with number`). Fix: remove it.

[WARN] BCS1202 line 463: comment paraphrases the following loop (`# Print continuation lines`). Fix: remove it.

[WARN] BCS1202 line 470: comment paraphrases the function below (`# Render task list item (checkbox)`). Fix: remove it.

[WARN] BCS1202 line 481: comment paraphrases the next statements (`# Calculate indentation`). Fix: remove it.

[WARN] BCS1202 line 487: comment paraphrases the following `if` (`# Format checkbox`). Fix: remove it.

[WARN] BCS1202 line 494: comment paraphrases the next statement (`# Apply inline formatting`). Fix: remove it.

[WARN] BCS1202 line 497: comment paraphrases the next statement (`# Wrap text`). Fix: remove it.

[WARN] BCS1202 line 500: comment paraphrases the next statement (`# Print first line`). Fix: remove it.

[WARN] BCS1202 line 503: comment paraphrases the following loop (`# Print continuation lines`). Fix: remove it.

[WARN] BCS1204 line 510: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 513: comment paraphrases the function below (`# Render blockquote with proper formatting`). Fix: remove it.

[WARN] BCS1202 line 521: comment paraphrases the next statement (`# Apply inline formatting`). Fix: remove it.

[WARN] BCS1202 line 524: comment paraphrases the next statement (`# Wrap text`). Fix: remove it.

[WARN] BCS1202 line 527: comment paraphrases the following loop (`# Print each line with blockquote formatting`). Fix: remove it.

[WARN] BCS1204 line 534: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 537: comment paraphrases the function below (`# Render horizontal rule`). Fix: remove it.

[WARN] BCS1204 line 547: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 550: comment paraphrases the function below (`# Render a line of code with basic syntax highlighting`). Fix: remove it.

[WARN] BCS1202 line 557: comment paraphrases the next statement (`# Sanitize ANSI codes from input`). Fix: remove it.

[WARN] BCS1202 line 560: comment paraphrases the following `if` (`# If syntax highlighting is disabled...`). Fix: remove it.

[WARN] BCS1202 line 566: comment paraphrases the following `case` (`# Normalize language name`). Fix: remove it.

[WARN] BCS1202 line 573: comment paraphrases the following `case` (`# Apply simple syntax highlighting based on language`). Fix: remove it.

[WARN] BCS1202 line 592: comment paraphrases the function below (`# Simple Python syntax highlighting`). Fix: remove it.

[WARN] BCS1202 line 597: comment paraphrases the following `if` (`# Comments (highest priority) - return immediately`). Fix: remove it.

[WARN] BCS1202 line 603: comment paraphrases the following `if` (`# Docstrings - return immediately`). Fix: remove it.

[WARN] BCS1202 line 609: comment partly paraphrases the following code (`# For other lines...`). Fix: keep only the non-obvious rationale about ANSI conflicts, remove the rest.

[WARN] BCS1202 line 618: comment paraphrases the function below (`# Simple JavaScript syntax highlighting`). Fix: remove it.

[WARN] BCS1202 line 623: comment paraphrases the following `if` (`# Comments - return immediately`). Fix: remove it.

[WARN] BCS1202 line 629: comment paraphrases the next statement (`# Minimal highlighting - just keywords`). Fix: remove it.

[WARN] BCS1202 line 637: comment paraphrases the function below (`# Simple Bash syntax highlighting`). Fix: remove it.

[WARN] BCS1202 line 642: comment paraphrases the following `if` (`# Comments - return immediately`). Fix: remove it.

[WARN] BCS1202 line 648: comment paraphrases the next statement (`# Minimal highlighting - just keywords and common built-ins`). Fix: remove it.

[WARN] BCS1204 line 656: section comment uses decorative `===...===` framing instead of a single `#` comment. Fix: rewrite as `# Table rendering functions`.

[WARN] BCS1204 line 660: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 663: comment paraphrases the function below (`# Parse and render a complete table`). Fix: remove it.

[WARN] BCS1202 line 678: comment paraphrases the following loop (`# Step 1: Collect all consecutive table lines`). Fix: remove it or keep only truly non-obvious rationale.

[WARN] BCS1202 line 681: comment paraphrases the next test (`# Check if line starts with | ...`). Fix: remove it.

[WARN] BCS1202 line 689: comment paraphrases the following `if` (`# Need at least 2 lines for a valid table...`). Fix: remove it.

[WARN] BCS1202 line 696: comment paraphrases the next call (`# Step 2: Parse all rows and detect alignment row`). Fix: remove it.

[WARN] BCS1202 line 702: comment paraphrases the following `if` (`# Step 3: Separate data rows from alignment row`). Fix: remove it.

[WARN] BCS1202 line 704: comment paraphrases the next assignments (`# First row is header...`). Fix: remove it.

[WARN] BCS1202 line 706: comment paraphrases the next assignment (`# Skip alignment row...`). Fix: remove it.

[WARN] BCS1202 line 708: comment paraphrases the next assignment (`# No alignment row - all rows are data`). Fix: remove it.

[WARN] BCS1202 line 712: comment paraphrases the following loop (`# Ensure we have alignment info for all columns`). Fix: remove it.

[WARN] BCS1202 line 718: comment paraphrases the next call (`# Step 4: Calculate column widths`). Fix: remove it.

[WARN] BCS1202 line 722: comment paraphrases the next call (`# Step 5: Render the table`). Fix: remove it.

[WARN] BCS1204 line 728: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 731: comment paraphrases the function below (`# Parse table lines into rows and detect alignment`). Fix: remove it.

[WARN] BCS1202 line 747: comment paraphrases the next statements (`# Remove leading/trailing whitespace`). Fix: remove it.

[WARN] BCS1202 line 751: comment paraphrases the next statements (`# Remove leading and trailing pipes`). Fix: remove it.

[WARN] BCS1202 line 755: comment paraphrases the next statement (`# Split by pipe into cells`). Fix: remove it.

[WARN] BCS1202 line 758: comment paraphrases the following loop (`# Trim whitespace from each cell`). Fix: remove it.

[WARN] BCS1202 line 766: comment paraphrases the following `if` (`# Check if this is an alignment row...`). Fix: remove it.

[WARN] BCS1202 line 775: comment paraphrases the following loop (`# Parse alignment for each column`). Fix: remove it.

[WARN] BCS1202 line 788: comment paraphrases the next statement (`# Store row...`). Fix: remove it.

[WARN] BCS1202 line 792: comment paraphrases the next statement (`# Track maximum column count`). Fix: remove it.

[WARN] BCS1204 line 800: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 803: comment paraphrases the function below (`# Calculate the width needed for each column`). Fix: remove it.

[WARN] BCS1202 line 814: comment paraphrases the following loop (`# Initialize widths to 0`). Fix: remove it.

[WARN] BCS1202 line 819: comment paraphrases the following loop (`# Process each row`). Fix: remove it.

[WARN] BCS1202 line 821: comment paraphrases the next statement (`# Parse cells...`). Fix: remove it.

[WARN] BCS1202 line 824: comment paraphrases the following loop (`# Measure each cell`). Fix: remove it.

[WARN] BCS1202 line 828: comment paraphrases the next statement (`# Apply inline formatting...`). Fix: remove it.

[WARN] BCS1202 line 831: comment paraphrases the next statements (`# Get visible length...`). Fix: remove it.

[WARN] BCS1202 line 835: comment paraphrases the following conditional (`# Update max width for this column`). Fix: remove it.

[WARN] BCS1204 line 843: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 846: comment paraphrases the function below (`# Render complete table with borders and formatting`). Fix: remove it.

[WARN] BCS1202 line 862: comment paraphrases the following statements (`# Build horizontal divider line`). Fix: remove it.

[WARN] BCS1202 line 873: comment paraphrases the next statement (`# Print top border`). Fix: remove it.

[WARN] BCS1202 line 877: comment paraphrases the following loop (`# Print each row`). Fix: remove it.

[WARN] BCS1202 line 879: comment paraphrases the next statement (`# Parse cells`). Fix: remove it.

[WARN] BCS1202 line 882: comment paraphrases the following loop (`# Pad cells array to column count`). Fix: remove it.

[WARN] BCS1202 line 887: comment paraphrases the next statement (`# Start row`). Fix: remove it.

[WARN] BCS1202 line 890: comment paraphrases the following loop (`# Print each cell`). Fix: remove it.

[WARN] BCS1202 line 894: comment paraphrases the next statement (`# Apply inline formatting`). Fix: remove it.

[WARN] BCS1202 line 901: comment paraphrases the following statements (`# Align cell`). Fix: remove it.

[WARN] BCS1202 line 905: comment paraphrases the next statement (`# Print cell with table color restoration`). Fix: remove it.

[WARN] BCS1202 line 911: comment paraphrases the following `if` (`# Print divider after header row...`). Fix: remove it.

[WARN] BCS1202 line 920: comment paraphrases the next statement (`# Print bottom border`). Fix: remove it.

[WARN] BCS1204 line 924: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 927: comment paraphrases the function below (`# Align cell content to specified width`). Fix: remove it.

[WARN] BCS1202 line 936: comment paraphrases the next statements (`# Get visible length`). Fix: remove it.

[WARN] BCS1202 line 940: comment paraphrases the next statements (`# Calculate padding needed`). Fix: remove it.

[WARN] BCS1202 line 946: comment paraphrases the next statements (`# Center alignment`). Fix: remove it.

[WARN] BCS1202 line 952: comment paraphrases the next statement (`# Right alignment`). Fix: remove it.

[WARN] BCS1202 line 956: comment paraphrases the next statement (`# Left alignment (default)`). Fix: remove it.

[WARN] BCS1204 line 962: section comment uses decorative `===...===` framing instead of a single `#` comment. Fix: rewrite as `# Markdown parser functions`.

[WARN] BCS1204 line 966: major divider overused. Fix: replace with a normal section comment.

[WARN] BCS1202 line 971: comment paraphrases the function below (`# Render collected footnotes at end of document`). Fix: remove it.

[WARN] BCS1202 line 989: comment paraphrases the else case (`# Reference without definition`). Fix: remove it.

[WARN] BCS1202 line 999: comment paraphrases the function below (`# Parse markdown line array and produce ANSI output`). Fix: remove it.

[ERROR] BCS0202 line 1007: function assigns to global state variables (`IN_CODE_BLOCK`, `CODE_FENCE_TYPE`, `CODE_LANG`, `FOOTNOTES`, `FOOTNOTE_REFS`) without `local`, polluting global scope and making behavior stateful across calls. Fix: use local variables within `parse_markdown()` or pass state explicitly; if persistence is intentional, redesign so parsing state is not stored in globals.

[WARN] BCS1202 line 1006: comment paraphrases the next assignments (`# Reset parsing state`). Fix: remove it.

[WARN] BCS1202 line 1024: comment paraphrases the next statement (`# Trim trailing whitespace`). Fix: remove it.

[WARN] BCS1202 line 1028: comment paraphrases the following block (`# CODE BLOCKS - Fenced...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1029: comment paraphrases the regex usage (`# Use literal backticks in regex`). Fix: remove it unless documenting a non-obvious bash regex constraint.

[WARN] BCS1202 line 1038: comment paraphrases the next statement (`# Closing fence ...`). Fix: remove it.

[WARN] BCS1202 line 1044: comment paraphrases the next statement (`# Mismatched fence inside code block...`). Fix: remove it.

[WARN] BCS1202 line 1048: comment paraphrases the next statements (`# Opening fence`). Fix: remove it.

[WARN] BCS1202 line 1060: comment paraphrases the following block (`# Inside code block - render code lines`). Fix: remove it.

[WARN] BCS1202 line 1068: comment paraphrases the following block (`# TABLES - Lines starting with |`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1071: comment paraphrases the effect of the previous function call. Fix: remove it.

[WARN] BCS1202 line 1074: comment paraphrases the following statements. Fix: remove it.

[WARN] BCS1202 line 1083: comment paraphrases the following block (`# HORIZONTAL RULES...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1091: comment paraphrases the following block (`# BLOCKQUOTES...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1100: comment paraphrases the following block (`# HEADERS...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1110: comment paraphrases the following block (`# TASK LISTS...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1119: comment paraphrases the next statement. Fix: remove it.

[WARN] BCS1202 line 1127: comment paraphrases the following block (`# UNORDERED LISTS...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1137: comment paraphrases the following block (`# ORDERED LISTS...`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1148: comment paraphrases the following block (`# FOOTNOTE DEFINITIONS...`). Fix: replace with a simple section comment if needed.

[ERROR] BCS0301 line 1157: static string literals use double quotes in pattern matching where no expansion is needed (`" ${FOOTNOTE_REFS[*]} "` and `" ${footnote_id} "`). Fix: use single-quoted literal portions and quote only expansions as needed, e.g. `[[ ' '"${FOOTNOTE_REFS[*]}"' ' != *' '"$footnote_id"' '* ]]` or refactor to a clearer membership test.

[WARN] BCS1202 line 1153: comment paraphrases the next assignment (`# Store footnote`). Fix: remove it.

[WARN] BCS1202 line 1156: comment paraphrases the following `if` (`# Track reference order`). Fix: remove it.

[WARN] BCS1202 line 1161: comment paraphrases the next statements (`# Skip rendering this line`). Fix: remove it.

[WARN] BCS1202 line 1167: comment paraphrases the following block (`# EMPTY LINES`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1175: comment paraphrases the following block (`# REGULAR TEXT - with inline formatting`). Fix: replace with a simple section comment if needed.

[WARN] BCS1202 line 1177: comment paraphrases the following loop (`# Find and track footnote references in text`). Fix: remove it.

[ERROR] BCS0301 line 1182: static string literals use double quotes in pattern matching where no expansion is needed (`" ${FOOTNOTE_REFS[*]} "` and `" ${ref_id} "`). Fix: use single-quoted literal portions and quote only expansions as needed, or refactor the membership test.

[WARN] BCS1202 line 1185: comment paraphrases the next statement (`# Remove matched part to find next`). Fix: remove it.

[WARN] BCS1202 line 1188: comment paraphrases the next statement (`# Restore for colorization`). Fix: remove it.

[WARN] BCS1202 line 1199: comment paraphrases the following `if` (`# Render footnotes section at end if any exist`). Fix: remove it.

[WARN] BCS1204 line 1205: section comment uses decorative `===...===` framing instead of a single `#` comment. Fix: rewrite as `# Main script functions`.

[WARN] BCS1202 line 1209: comment paraphrases the function below (`# Usage documentation`). Fix: remove it.

[WARN] BCS0801 line 1268: argument parsing loop is split across two lines instead of the standard `while (($#)); do case $1 in ... esac; shift; done` pattern. Fix: collapse to the canonical while/case form, typically inside `main()` unless intentionally deviating.

[WARN] BCS1202 line 1289: comment paraphrases the following assignments (`# Plain mode for environments...`). Fix: keep only non-obvious rationale if needed; otherwise remove.

[WARN] BCS1202 line 1321: inline comment `# Bundled short options` paraphrases the case pattern. Fix: remove it.

[WARN] BCS1202 line 1330: comment paraphrases the next assignment (`# Regular file argument`). Fix: remove it.

[WARN] BCS1202 line 1340: comment paraphrases the function below (`# Process a single file or stdin`). Fix: remove it.

[WARN] BCS1202 line 1347: comment paraphrases the next statements (`# Process file`). Fix: remove it.

[WARN] BCS1202 line 1351: comment paraphrases the next loop (`# Read file into array...`). Fix: remove it unless documenting a non-obvious encoding caveat.

[WARN] BCS1202 line 1353: comment paraphrases the following `if` (`# Skip shebang...`). Fix: remove it.

[WARN] BCS1202 line 1360: comment paraphrases the next block (`# Process stdin`). Fix: remove it.

[WARN] BCS1202 line 1364: comment paraphrases the next loop (`# Read stdin with size limit`). Fix: remove it.

[WARN] BCS1202 line 1367: comment paraphrases the next statement (`# Account for newline`). Fix: remove it.

[WARN] BCS1202 line 1373: comment paraphrases the following `if` (`# Skip shebang...`). Fix: remove it.

[WARN] BCS1202 line 1383: comment paraphrases the next statement (`# Process the markdown lines`). Fix: remove it.

[WARN] BCS1202 line 1387: comment paraphrases the next function (`# Main function`). Fix: remove it.

[WARN] BCS1202 line 1390: comment paraphrases the next statement (`# Parse command-line arguments`). Fix: remove it.

[WARN] BCS1202 line 1393: comment paraphrases the next statement (`# Determine terminal width`). Fix: remove it.

[WARN] BCS1202 line 1403: comment paraphrases the next statement (`# Print initial reset...`). Fix: remove it.

[WARN] BCS1202 line 1406: comment paraphrases the following `if` (`# Process files or stdin`). Fix: remove it.

[WARN] BCS1202 line 1412: comment paraphrases the following `if` (`# Add newline between files if processing multiple`). Fix: remove it.

[WARN] BCS1202 line 1418: comment paraphrases the next statement (`# Read from stdin`). Fix: remove it.

[WARN] BCS1202 line 1422: comment paraphrases the next statement (`# Ensure terminal colors are reset at the end`). Fix: remove it.

[WARN] BCS1202 line 1428: comment paraphrases the next command (`# Script invocation`). Fix: remove it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0103 | recommended | [WARN] | 13 | Metadata uses nonstandard incomplete pattern; suppression is misplaced |
| BCS1204 | style | [WARN] | 39 | Decorative section comment style |
| BCS1204 | style | [WARN] | 50 | Overused major dash separator |
| BCS1202 | style | [WARN] | 65 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 68 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 85 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 120 | Overused major dash separator |
| BCS1202 | style | [WARN] | 123 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 133 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 136 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 147 | Overused major dash separator |
| BCS1202 | style | [WARN] | 150 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 154 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 158 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 173 | Decorative section comment style |
| BCS1202 | style | [WARN] | 177 | Comment paraphrases code |
| BCS0706 | recommended | [WARN] | 185 | Color/TUI detection not gated solely on terminal detection |
| BCS1204 | style | [WARN] | 192 | Overused major dash separator |
| BCS1202 | style | [WARN] | 246 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 255 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 263 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 270 | Decorative section comment style |
| BCS1204 | style | [WARN] | 274 | Overused major dash separator |
| BCS1202 | style | [WARN] | 277 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 325 | Overused major dash separator |
| BCS1202 | style | [WARN] | 328 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 376 | Overused major dash separator |
| BCS1202 | style | [WARN] | 379 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 386 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 396 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 402 | Overused major dash separator |
| BCS1202 | style | [WARN] | 405 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 415 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 420 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 423 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 426 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 429 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 436 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 447 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 454 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 457 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 460 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 463 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 470 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 481 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 487 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 494 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 497 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 500 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 503 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 510 | Overused major dash separator |
| BCS1202 | style | [WARN] | 513 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 521 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 524 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 527 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 534 | Overused major dash separator |
| BCS1202 | style | [WARN] | 537 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 547 | Overused major dash separator |
| BCS1202 | style | [WARN] | 550 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 557 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 560 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 566 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 573 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 592 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 597 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 603 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 609 | Comment partly paraphrases code |
| BCS1202 | style | [WARN] | 618 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 623 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 629 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 637 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 642 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 648 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 656 | Decorative section comment style |
| BCS1204 | style | [WARN] | 660 | Overused major dash separator |
| BCS1202 | style | [WARN] | 663 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 678 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 681 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 689 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 696 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 702 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 704 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 706 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 708 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 712 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 718 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 722 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 728 | Overused major dash separator |
| BCS1202 | style | [WARN] | 731 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 747 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 751 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 755 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 758 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 766 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 775 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 788 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 792 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 800 | Overused major dash separator |
| BCS1202 | style | [WARN] | 803 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 814 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 819 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 821 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 824 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 828 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 831 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 835 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 843 | Overused major dash separator |
| BCS1202 | style | [WARN] | 846 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 862 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 873 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 877 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 879 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 882 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 887 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 890 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 894 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 901 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 905 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 911 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 920 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 924 | Overused major dash separator |
| BCS1202 | style | [WARN] | 927 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 936 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 940 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 946 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 952 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 956 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 962 | Decorative section comment style |
| BCS1204 | style | [WARN] | 966 | Overused major dash separator |
| BCS1202 | style | [WARN] | 971 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 989 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 999 | Comment paraphrases code |
| BCS0202 | core | [ERROR] | 1007 | Function mutates global parsing state instead of local scope |
| BCS1202 | style | [WARN] | 1006 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1024 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1028 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1029 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1038 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1044 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1048 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1060 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1068 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1071 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1074 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1083 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1091 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1100 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1110 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1119 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1127 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1137 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1148 | Comment paraphrases code |
| BCS0301 | style | [ERROR] | 1157 | Double quotes used for static literals in membership test |
| BCS1202 | style | [WARN] | 1153 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1156 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1161 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1167 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1175 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1177 | Comment paraphrases code |
| BCS0301 | style | [ERROR] | 1182 | Double quotes used for static literals in membership test |
| BCS1202 | style | [WARN] | 1185 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1188 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1199 | Comment paraphrases code |
| BCS1204 | style | [WARN] | 1205 | Decorative section comment style |
| BCS1202 | style | [WARN] | 1209 | Comment paraphrases code |
| BCS0801 | core | [WARN] | 1268 | Argument parsing does not use the canonical one-line while/case pattern |
| BCS1202 | style | [WARN] | 1289 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1321 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1330 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1340 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1347 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1351 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1353 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1360 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1364 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1367 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1373 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1383 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1387 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1390 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1393 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1403 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1406 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1412 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1418 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1422 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 1428 | Comment paraphrases code |
bcs: ◉ Tokens: in=39584 out=10167
bcs: ◉ Elapsed: 109s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
