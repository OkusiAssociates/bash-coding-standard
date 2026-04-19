<?php
/**
 * spacetime - Format and display current time with optional template support
 *
 * Usage: spacetime([template])
 *   Without arguments: Returns formatted time as
 *     "DayOfWeek YYYY-MM-DD HH:MM:SS TZ Timezone"
 *   With template: Returns custom format using placeholders:
 *     {{dow}}      - Day of week (e.g., Monday)
 *     {{date}}     - Date in YYYY-MM-DD format
 *     {{time}}     - Time in HH:MM:SS format
 *     {{tz}}       - Timezone offset (e.g., +0000)
 *     {{timezone}} - Timezone name (e.g., America/New_York)
 *
 * @param string|null $template Optional template string with placeholders
 * @return string Formatted time string
 */
function spacetime(?string $template = null): string {
  // Resolve timezone name
  // If TZ env var is set (even empty), use it directly (POSIX: TZ='' means UTC).
  // If TZ is unset, use cached system timezone.
  static $cached_timezone = null;
  $tz_env = getenv('TZ');
  if ($tz_env !== false) {
    $timezone_name = ($tz_env === '') ? 'UTC' : $tz_env;
    try {
      $tz_obj = new DateTimeZone($timezone_name);
    } catch (\Exception $e) {
      $timezone_name = 'UTC';
      $tz_obj = new DateTimeZone('UTC');
    }
  } else {
    if ($cached_timezone === null) {
      $cached_timezone = date_default_timezone_get();
    }
    $timezone_name = $cached_timezone;
    $tz_obj = new DateTimeZone($timezone_name);
  }

  $now = new DateTime('now', $tz_obj);
  $dow = $now->format('l');
  $date = $now->format('Y-m-d');
  $time = $now->format('H:i:s');
  $tz = $now->format('O'); // +0000 format (no colon)
  $timezone = $timezone_name;

  // Default format when no template provided
  $curtime = "$dow $date $time $tz $timezone";

  // If a template string is provided, parse and replace placeholders
  if ($template !== null) {
    $curtime = str_replace(
      ['{{dow}}', '{{date}}', '{{time}}', '{{tz}}', '{{timezone}}'],
      [$dow, $date, $time, $tz, $timezone],
      $template
    );
  }

  // Store the result in the global variable for later reference
  $GLOBALS['EPOCHSPACETIME'] = $curtime;

  return $curtime;
}

// If script is executed directly, run spacetime with arguments
if (basename(__FILE__) === basename($_SERVER['SCRIPT_FILENAME'] ?? '')) {
  $VERSION = '1.1.0';

  if (isset($argv[1]) && in_array($argv[1], ['-V', '--version'])) {
    echo basename(__FILE__) . " $VERSION\n";
    exit(0);
  }

  if (isset($argv[1]) && in_array($argv[1], ['-h', '--help'])) {
    echo <<<'EOF'
spacetime - Format and display current time with template support

Usage: spacetime [template]

Without arguments: Returns formatted time as
  "DayOfWeek YYYY-MM-DD HH:MM:SS TZ Timezone"

With template: Returns custom format using placeholders

Placeholders:
  {{dow}}      - Day of week (e.g., Monday)
  {{date}}     - Date in YYYY-MM-DD format
  {{time}}     - Time in HH:MM:SS format
  {{tz}}       - Timezone offset (e.g., +0000)
  {{timezone}} - Timezone name (e.g., America/New_York)

Examples:
  spacetime.php
  TZ=UTC spacetime.php
  spacetime.php "{{date}} at {{time}}"
  spacetime.php "Log entry: {{dow}} {{date}} {{time}} {{tz}}"
EOF;
    echo "\n";
    exit(0);
  }

  echo spacetime($argv[1] ?? null) . "\n";
}

#fin
