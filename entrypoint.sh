#!/bin/bash

# set some vars
CLICKHOUSE_CONFIG="${CLICKHOUSE_CONFIG:-/etc/clickhouse-server/config.xml}"
USER="$(id -u clickhouse)"
GROUP="$(id -g clickhouse)"

# port is needed to check if clickhouse-server is ready for connections
HTTP_PORT="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=http_port)"

# get CH directories locations
DATA_DIR="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=path || true)"
TMP_DIR="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=tmp_path || true)"
# USER_PATH="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=user_files_path || true)"
LOG_PATH="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=logger.log || true)"
LOG_DIR="$(dirname $LOG_PATH || true)"
ERROR_LOG_PATH="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=logger.errorlog || true)"
ERROR_LOG_DIR="$(dirname $ERROR_LOG_PATH || true)"
# FORMAT_SCHEMA_PATH="$(clickhouse extract-from-config --config-file $CLICKHOUSE_CONFIG --key=format_schema_path || true)"

# ensure directories exist
mkdir -p \
    "$DATA_DIR" \
    "$ERROR_LOG_DIR" \
    "$LOG_DIR" \
    "$TMP_DIR" \
    # "$USER_PATH" \
    # "$FORMAT_SCHEMA_PATH"

if [ "$CLICKHOUSE_DO_NOT_CHOWN" != "1" ]; then
    # ensure proper directories permissions
    chown -R $USER:$GROUP \
        "$DATA_DIR" \
        "$ERROR_LOG_DIR" \
        "$LOG_DIR" \
        "$TMP_DIR" \
        # "$USER_PATH" \
        # "$FORMAT_SCHEMA_PATH"
fi
gosu clickhouse /usr/bin/clickhouse-server --config-file=$CLICKHOUSE_CONFIG