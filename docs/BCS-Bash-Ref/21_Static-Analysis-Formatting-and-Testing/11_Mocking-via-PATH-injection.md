<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.11 Mocking via PATH injection

Replacing external commands for tests.

```bash
setup() {
  MOCK_DIR=$(mktemp -d)
  PATH="$MOCK_DIR:$PATH"
  cat > "$MOCK_DIR/curl" <<'EOF'
#!/bin/bash
echo '{"result": "mocked"}'
EOF
  chmod +x "$MOCK_DIR/curl"
}

teardown() {
  rm -rf -- "$MOCK_DIR"
}
```

- Prepend a tempdir to PATH.
- Drop in mock binaries.
- Mock checks arguments and produces controlled output.
- Each test can have different mocks via `setup`.
- Persistent mocks (across tests) via `setup_file`.

#fin
