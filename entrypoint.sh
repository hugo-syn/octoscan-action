#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Initialize the base command
COMMAND="octoscan scan ."

# Add options if the corresponding environment variables are defined
if [ -n "$INPUT_DEBUG_RULES" ]; then
    COMMAND+=" --debug-rules"
fi

if [ -n "$INPUT_FILTER_TRIGGERS" ]; then
    COMMAND+=" --filter-triggers \"$INPUT_FILTER_TRIGGERS\""
fi

if [ -n "$INPUT_FILTER_RUN" ]; then
    COMMAND+=" --filter-run"
fi

if [ -n "$INPUT_IGNORE" ]; then
    COMMAND+=" --ignore \"$INPUT_IGNORE\""
fi

# --disable-rules and --enable-rules are exclusive
if [ -n "$INPUT_DISABLE_RULES" ] && [ -n "$INPUT_ENABLE_RULES" ]; then
    echo "Error: Both --disable-rules and --enable-rules cannot be set simultaneously."
    exit 1
fi

if [ -n "$INPUT_DISABLE_RULES" ]; then
    COMMAND+=" --disable-rules \"$INPUT_DISABLE_RULES\""
elif [ -n "$INPUT_ENABLE_RULES" ]; then
    COMMAND+=" --enable-rules \"$INPUT_ENABLE_RULES\""
fi

if [ -n "$INPUT_CONFIG_FILE" ]; then
    COMMAND+=" --config-file \"$INPUT_CONFIG_FILE\""
fi

# Print the constructed command for debugging
echo "Constructed command: $COMMAND"

# Execute the command
eval $COMMAND | reviewdog -efm="%f:%l:%c: %m" \
      -name="octoscan" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}

exit_code=$?

exit $exit_code