#!/bin/bash

# Generate available-servers.mdx from spec.json
# Appends auto-generated server sections to the file
# Usage: ./generate-mcp-servers.sh <spec-file-path>

# Check if spec file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <spec-file-path>"
    echo "Example: $0 spec.json"
    exit 1
fi

SPEC_FILE="$1"
OUTPUT_FILE="docs/mcp/available-servers.mdx"

# Check if spec file exists
if [ ! -f "$SPEC_FILE" ]; then
    echo "❌ Error: Spec file not found: $SPEC_FILE"
    exit 1
fi

# Function to convert camelCase to Title Case
camel_to_title() {
    echo "$1" | sed -E 's/([A-Z])/ \1/g' | sed 's/^ //' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}}1'
}

# Function to get the type for ResponseField
get_field_type() {
    local type="$1"
    case "$type" in
        "string") echo "string" ;;
        "integer") echo "number" ;;
        "number") echo "number" ;;
        "boolean") echo "boolean" ;;
        "array") echo "string[]" ;;
        *) echo "string" ;;
    esac
}

# Process each server in the spec.json
jq -r '.properties | keys[]' "$SPEC_FILE" | sort | while read -r server; do
    # Get server title
    title=$(jq -r ".properties.${server}.title // \"\"" "$SPEC_FILE")
    # Remove "MCP SERVER" (case insensitive) and trim whitespace
    title=$(echo "$title" | sed -E 's/MCP SERVER//i' | xargs)
    
    # Get description and Docker Hub URL
    description=$(jq -r ".properties.${server}.description // \"\"" "$SPEC_FILE")
    docker_hub_url=$(jq -r ".properties.${server}[\"x-dockerHubUrl\"] // .properties.${server}.dockerHubUrl // \"\"" "$SPEC_FILE")
    
    echo "" >> "$OUTPUT_FILE"
    echo "## $title" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Add description if available
    if [ -n "$description" ] && [ "$description" != "null" ]; then
        echo "$description" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Add Docker Hub link if available
    if [ -n "$docker_hub_url" ] && [ "$docker_hub_url" != "null" ]; then
        echo "[View on Docker Hub]($docker_hub_url)" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Start ResponseField
    echo "<ResponseField name=\"$server\" type=\"object\">" >> "$OUTPUT_FILE"
    
    # Get properties for this server
    properties=$(jq -r ".properties.${server}.properties // {} | keys[]" "$SPEC_FILE" 2>/dev/null)
    required_fields=$(jq -r ".properties.${server}.required // [] | .[]" "$SPEC_FILE" 2>/dev/null)
    
    if [ -n "$properties" ]; then
        echo "  <Expandable title=\"properties\">" >> "$OUTPUT_FILE"
        
        # Process each property
        echo "$properties" | while read -r prop; do
            # Get property details
            prop_type=$(jq -r ".properties.${server}.properties.${prop}.type // \"string\"" "$SPEC_FILE")
            description=$(jq -r ".properties.${server}.properties.${prop}.description // \"\"" "$SPEC_FILE")
            
            # Escape angle brackets in descriptions to avoid JSX parsing issues
            # Convert <text> patterns to `<text>` (backticks for code formatting)
            if [ -n "$description" ] && [ "$description" != "null" ]; then
                description=$(echo "$description" | sed -E 's/<([^>]+)>/`<\1>`/g')
            fi
            
            # Check if required
            is_required=""
            if echo "$required_fields" | grep -q "^${prop}$"; then
                is_required=" required"
            fi
            
            # Convert type
            field_type=$(get_field_type "$prop_type")
            
            # Write the ResponseField
            echo "    <ResponseField name=\"$prop\" type=\"$field_type\"$is_required>" >> "$OUTPUT_FILE"
            if [ -n "$description" ] && [ "$description" != "null" ]; then
                echo "      $description" >> "$OUTPUT_FILE"
            fi
            echo "    </ResponseField>" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        done
        
        echo "  </Expandable>" >> "$OUTPUT_FILE"
    fi
    
    echo "</ResponseField>" >> "$OUTPUT_FILE"
done

# Count the servers
server_count=$(jq -r '.properties | keys | length' "$SPEC_FILE")

echo "✅ Appended $server_count MCP servers to $OUTPUT_FILE"
echo "   📄 Source: $SPEC_FILE"

