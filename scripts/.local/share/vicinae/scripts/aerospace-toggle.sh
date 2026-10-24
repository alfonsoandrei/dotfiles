#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Toggle AeroSpace
# @vicinae.mode compact
# @vicinae.packageName AeroSpace
# @vicinae.exec ["/bin/bash"]

# Lives in Vicinae because a paused AeroSpace ignores its own key bindings.
export PATH="/opt/homebrew/bin:$PATH"

if aerospace enable off --fail-if-noop >/dev/null 2>&1; then
  echo "AeroSpace paused"
else
  aerospace enable on && echo "AeroSpace on"
fi
