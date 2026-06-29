#!/usr/bin/env bash
set -euo pipefail

export MAESTRO_APP_ID="${MAESTRO_APP_ID:-com.a-know.pixelaButtons}"
export PIXELA_E2E_BAD_USERNAME="${PIXELA_E2E_BAD_USERNAME:-pixela-buttons-invalid-user}"
export PIXELA_E2E_BAD_TOKEN="${PIXELA_E2E_BAD_TOKEN:-invalid-token-for-maestro}"
export PIXELA_E2E_GRAPH_NAME="${PIXELA_E2E_GRAPH_NAME:-Maestro Graph}"
export PIXELA_E2E_GRAPH_UNIT="${PIXELA_E2E_GRAPH_UNIT:-count}"
export PIXELA_E2E_CARD_NAME="${PIXELA_E2E_CARD_NAME:-Maestro Card}"
export PIXELA_E2E_FLOW_DELAY_SECONDS="${PIXELA_E2E_FLOW_DELAY_SECONDS:-5}"

run_id="$(date +%s)"
export PIXELA_E2E_GRAPH_ID="${PIXELA_E2E_GRAPH_ID:-mb${run_id}}"
export PIXELA_E2E_USERNAME="${PIXELA_E2E_USERNAME:-${PIXELA_E2E_NEW_USERNAME:-mb${run_id}}}"
export PIXELA_E2E_TOKEN="${PIXELA_E2E_TOKEN:-${PIXELA_E2E_NEW_TOKEN:-maestro-token-${run_id}}}"

maestro_env=(
  -e "MAESTRO_APP_ID=${MAESTRO_APP_ID}"
  -e "PIXELA_E2E_BAD_USERNAME=${PIXELA_E2E_BAD_USERNAME}"
  -e "PIXELA_E2E_BAD_TOKEN=${PIXELA_E2E_BAD_TOKEN}"
  -e "PIXELA_E2E_GRAPH_NAME=${PIXELA_E2E_GRAPH_NAME}"
  -e "PIXELA_E2E_GRAPH_UNIT=${PIXELA_E2E_GRAPH_UNIT}"
  -e "PIXELA_E2E_CARD_NAME=${PIXELA_E2E_CARD_NAME}"
  -e "PIXELA_E2E_GRAPH_ID=${PIXELA_E2E_GRAPH_ID}"
  -e "PIXELA_E2E_USERNAME=${PIXELA_E2E_USERNAME}"
  -e "PIXELA_E2E_TOKEN=${PIXELA_E2E_TOKEN}"
)

if [[ $# -gt 0 ]]; then
  maestro test "${maestro_env[@]}" "$@"
else
  flows=(
    .maestro/flows/01_register_new_user.yaml
    .maestro/flows/02_login_failure.yaml
    .maestro/flows/03_login_success.yaml
    .maestro/flows/04_create_graph.yaml
    .maestro/flows/05_graph_list.yaml
    .maestro/flows/06_add_button_card.yaml
    .maestro/flows/07_record_custom_value.yaml
    .maestro/flows/08_logout.yaml
    .maestro/flows/09_change_language.yaml
    .maestro/flows/10_reminder_permission_dialog.yaml
    .maestro/flows/11_delete_account.yaml
  )

  for flow in "${flows[@]}"; do
    echo "Running ${flow}"
    maestro test "${maestro_env[@]}" "${flow}"
    sleep "${PIXELA_E2E_FLOW_DELAY_SECONDS}"
  done
fi
