#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

SARIF_OUTPUT="octoscan.sarif"

# Initialize the base command
OCTOSCAN_COMMAND="octoscan scan . --format sarif"

# Add options if the corresponding environment variables are defined
if [ -n "$INPUT_DEBUG_RULES" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --debug-rules"
fi

if [ -n "$INPUT_FILTER_TRIGGERS" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --filter-triggers \"$INPUT_FILTER_TRIGGERS\""
fi

if [ -n "$INPUT_FILTER_RUN" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --filter-run"
fi

if [ -n "$INPUT_IGNORE" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --ignore \"$INPUT_IGNORE\""
fi

# --disable-rules and --enable-rules are exclusive
if [ -n "$INPUT_DISABLE_RULES" ] && [ -n "$INPUT_ENABLE_RULES" ]; then
    echo "Error: Both --disable-rules and --enable-rules cannot be set simultaneously."
    exit 1
fi

if [ -n "$INPUT_DISABLE_RULES" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --disable-rules \"$INPUT_DISABLE_RULES\""
elif [ -n "$INPUT_ENABLE_RULES" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --enable-rules \"$INPUT_ENABLE_RULES\""
fi

if [ -n "$INPUT_CONFIG_FILE" ]; then
    OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND --config-file \"$INPUT_CONFIG_FILE\""
fi

OCTOSCAN_COMMAND="$OCTOSCAN_COMMAND > $SARIF_OUTPUT"

# Print the constructed command for debugging
echo "Octoscan command: $OCTOSCAN_COMMAND"

# Execute the commands
eval "$OCTOSCAN_COMMAND" || true

echo "sarif_output=$SARIF_OUTPUT" >> $GITHUB_OUTPUT
