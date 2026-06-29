# Maestro E2E tests

These flows exercise Pixela Buttons through the native UI with
[Maestro](https://maestro.mobile.dev/).

## Prerequisites

- Install Maestro: `curl -fsSL "https://get.maestro.mobile.dev" | bash`
- Start one iOS simulator or Android emulator.
- Install and launch the app once with Flutter, or keep `flutter run` attached
  while running Maestro.
- Set the simulator/emulator language to Japanese. The flows intentionally use
  the Japanese UI text.

## Environment variables

The tests use real Pixela API calls. Do not commit credentials.

The default suite creates one disposable Pixela user, reuses that user through
the login, graph, card, recording, and settings flows, then deletes the user in
the final flow.

User defaults:

- `PIXELA_E2E_USERNAME`: disposable user name for the full suite. If you use
  `scripts/maestro_test.sh`, a unique default is generated.
- `PIXELA_E2E_TOKEN`: token for the disposable user. If you use
  `scripts/maestro_test.sh`, a unique default is generated.

Legacy aliases:

- `PIXELA_E2E_NEW_USERNAME` and `PIXELA_E2E_NEW_TOKEN` are still accepted by
  `scripts/maestro_test.sh` when `PIXELA_E2E_USERNAME` and
  `PIXELA_E2E_TOKEN` are not set.

Optional defaults:

- `PIXELA_E2E_BAD_USERNAME`: defaults to `pixela-buttons-invalid-user`
- `PIXELA_E2E_BAD_TOKEN`: defaults to `invalid-token-for-maestro`
- `PIXELA_E2E_GRAPH_ID`: defaults to a unique `mb<timestamp>` value in
  `scripts/maestro_test.sh`
- `PIXELA_E2E_GRAPH_NAME`: defaults to `Maestro Graph`
- `PIXELA_E2E_GRAPH_UNIT`: defaults to `count`
- `PIXELA_E2E_CARD_NAME`: defaults to `Maestro Card`
- `PIXELA_E2E_FLOW_DELAY_SECONDS`: seconds to wait between flows in the default
  local suite. Defaults to `5` to reduce accidental Pixela rate limiting.

## Run

```bash
scripts/maestro_test.sh
```

To run a single flow:

```bash
scripts/maestro_test.sh .maestro/flows/03_login_success.yaml
```

## Notes

- The default `scripts/maestro_test.sh` run executes the numbered flows in
  order. The suite is intentionally order-dependent.
- `01_register_new_user.yaml` creates `PIXELA_E2E_USERNAME`.
- `04_create_graph.yaml` creates a real Pixela graph for that user. Use a fresh
  `PIXELA_E2E_GRAPH_ID` for each full run.
- `11_delete_account.yaml` deletes `PIXELA_E2E_USERNAME`, then verifies the
  deleted user cannot log in.
- If the suite stops before `11_delete_account.yaml`, the disposable Pixela user
  and graph may remain and should be cleaned up manually.
- Notification permission text is OS-controlled. The reminder flow verifies
  the app reaches the reminder creation path and looks for a Japanese
  notification permission dialog.
