#!/bin/bash
# json_parser.sh - JSON parsing utilities

# Parse JSON value from file using jq or Python fallback
# Args: $1 = file path, $2 = key, $3 = default value
# Returns: Prints the value
parse_json_value() {
    local file="$1"
    local key="$2"
    local default="${3:-}"
    local value
    
    if [[ ! -f "${file}" ]]; then
        echo "${default}"
        return
    fi
    
    # Try jq first (preferred)
    if command -v jq &>/dev/null; then
        value=$(jq -r ".${key} // empty" "${file}" 2>/dev/null)
        if [[ -n "${value}" ]]; then
            echo "${value}"
            return
        fi
    fi
    
    # Fallback to Python
    if command -v python3 &>/dev/null; then
        value=$(python3 -c "
import json, sys
try:
    with open('${file}') as f:
        data = json.load(f)
    print(data.get('${key}', ''))
except:
    pass
" 2>/dev/null)
        if [[ -n "${value}" ]]; then
            echo "${value}"
            return
        fi
    fi
    
    # Return default if parsing failed
    echo "${default}"
}

# Parse JSON from stdin (for hook input)
# Args: $1 = key path (dot notation)
# Returns: Prints the value
parse_hook_input() {
    local key="$1"
    local input
    
    # Read from stdin
    input=$(cat)
    
    # Try jq first
    if command -v jq &>/dev/null; then
        echo "${input}" | jq -r ".${key} // empty" 2>/dev/null
        return
    fi
    
    # Fallback to Python
    if command -v python3 &>/dev/null; then
        echo "${input}" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    keys = '${key}'.split('.')
    result = data
    for k in keys:
        result = result.get(k, {})
    if result and result != {}:
        print(result)
except:
    pass
" 2>/dev/null
        return
    fi
    
    # No parser available
    echo ""
}
