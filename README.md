# typst-mcp

An MCP server that compiles Typst resumes from YAML content into PDF files.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![MCP](https://img.shields.io/badge/MCP-server-blue)](https://modelcontextprotocol.io)

## Prerequisites

- [Bun](https://bun.com) runtime
- [Typst](https://typst.app) CLI installed and on your PATH

## Setup

```bash
bun install
```

## Template

The Typst template is bundled at `typt_template/` and includes:

- `template.typ` — entry point (reads `Resume_Modify.yml`, imports `cv.typ`)
- `cv.typ` — resume section components (heading, summary, education, work, projects, skills)
- `utils.typ` — date formatting helpers
- `resume.schema.json` — JSON Schema (draft-07) for the YAML input, also exposed as MCP resource `schema://resume`

The server writes the YAML content you pass as `Resume_Modify.yml` into this directory before compiling.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `TYPST_OUTPUT_DIR` | Yes | — | Directory where the compiled PDF is written (e.g. `/Users/jay/resumes`) |
| `TYPST_TEMPLATE_DIR` | No | `typt_template/` in project root | Directory containing `template.typ`, `cv.typ`, and `utils.typ` |

## Resources

### `schema://resume`

JSON Schema (draft-07) describing the YAML structure accepted by `render_resume`. MCP clients should fetch this resource before constructing `yaml_content`.

Top-level keys:

| Key | Required | Description |
|---|---|---|
| `personal` | Yes | Required nested keys: `name`, `email`. Optional: `phone`, `url`, `titles[]`, `location{city,region}`, `profiles[]` |
| `summary` | No | 1-2 sentence professional summary |
| `education[]` | No | `institution`, `studyType`, `area`, `startDate`, `endDate`, `location`, optional `gpa` |
| `work[]` | No | `organization`, `location`, `positions[]` (each: `position`, `startDate`, `endDate`, `highlights[]`) |
| `projects[]` | No | `name`, `highlights[]`, optional `url`, `techstack` (no dates) |
| `skills[]` | No | `category`, `skills[]` |

Date format: `YYYY-MM-DD`. `endDate` may be `"present"`. Use `*text*` for bold Typst markup inside highlight strings.

## Tools

### `get_resume_schema`

Returns the JSON Schema (draft-07) for the resume YAML as a text payload. Use this when your MCP client does not surface resources, or when you want the schema inline before constructing `yaml_content`.

**Inputs:** none.

### `render_resume`

Compiles a Typst resume from YAML content into a PDF. The output directory is set via the `TYPST_OUTPUT_DIR` environment variable; the filename is passed as a tool input.

**Inputs:**

| Parameter | Type | Description |
|---|---|---|
| `yaml_content` | `string` | Full YAML resume content (must conform to `schema://resume`) |
| `filename` | `string` | PDF filename (e.g. `resume.pdf`) |

## MCP Client Configuration

### Cursor / VS Code

Add to your `.cursor/mcp.json` or equivalent:

```json
{
  "mcpServers": {
    "typst-mcp": {
      "command": "bun",
      "args": ["run", "/absolute/path/to/typst-mcp/index.ts"],
      "env": {
        "TYPST_OUTPUT_DIR": "/absolute/path/to/output/dir"
      }
    }
  }
}
```

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "typst-mcp": {
      "command": "bun",
      "args": ["run", "/absolute/path/to/typst-mcp/index.ts"],
      "env": {
        "TYPST_OUTPUT_DIR": "/absolute/path/to/output/dir",
        "TYPST_TEMPLATE_DIR": "/absolute/path/to/your/template/dir"
      }
    }
  }
}
```