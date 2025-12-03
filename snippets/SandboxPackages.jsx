export const Requirements = () => {
  const { useEffect, useState } = React;
  const [lines, setLines] = useState([]);

  useEffect(() => {
    const parseRequirement = (line) => {
      // Remove inline comments
      const commentIndex = line.indexOf("#");
      if (commentIndex !== -1) {
        line = line.substring(0, commentIndex);
      }
      line = line.trim();

      // Skip empty lines and comment-only lines
      if (!line) return null;

      // Skip special requirements (-r, -c, -e, git+, etc.)
      if (line.startsWith("-") || line.includes("@")) return null;

      // Extract package name and version spec
      // Match: package_name[extras]operator version; environment_marker
      const match = line.match(/^([a-zA-Z0-9_.-]+)(\[[^\]]*\])?(.*)$/);
      if (!match) return null;

      let name = match[1];
      const extras = match[2]; // e.g., [dev,test]
      let versionPart = match[3] || "";

      // Remove environment markers (after semicolon)
      const markerIndex = versionPart.indexOf(";");
      if (markerIndex !== -1) {
        versionPart = versionPart.substring(0, markerIndex);
      }
      versionPart = versionPart.trim();

      // Parse version specs (can have multiple: >=1.0,<2.0)
      let version = "";
      if (versionPart) {
        // Handle version operators: ==, !=, >=, <=, >, <, ~=, ===
        const versionSpecs = versionPart.split(",").map(s => s.trim());
        const parsedSpecs = [];

        for (const spec of versionSpecs) {
          const specMatch = spec.match(/^(===|==|!=|~=|>=|<=|>|<)(.*)$/);
          if (specMatch) {
            const operator = specMatch[1];
            const ver = specMatch[2].trim();
            if (ver) {
              // For display, just show the main version (use == if present, or first spec)
              if (operator === "==") {
                version = ver;
                break;
              }
              parsedSpecs.push({ operator, version: ver });
            }
          }
        }

        // If no == found, use the first spec
        if (!version && parsedSpecs.length > 0) {
          version = parsedSpecs[0].version;
        }
      }

      // Add extras to name for display if present
      if (extras) {
        name = name + extras;
      }

      return { name, version };
    }

    const load = async () => {
      const res = await fetch(
        "https://raw.githubusercontent.com/e2b-dev/code-interpreter/refs/heads/main/template/requirements.txt"
      );
      const text = await res.text();
      const packages = text
        .split("\n")
        .map(parseRequirement)
        .filter(Boolean);
      setLines(packages);
    }

    load();
  }, []);

  return (
    <div>
      <ul>
        {lines.map((pkg) => (
          <li key={pkg.name}>
            <code>{pkg.name}</code> ({pkg.version ? `v${pkg.version}` : "latest"})
          </li>
        ))}
      </ul>
    </div>
  );
}
