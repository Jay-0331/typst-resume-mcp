import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { resolve, dirname } from "node:path";

const PROJECT_ROOT = dirname(Bun.main);
const DEFAULT_TEMPLATE_DIR = resolve(PROJECT_ROOT, "typt_template");
const SCHEMA_URI = "schema://resume";

const server = new McpServer(
  {
    name: "typst-mcp",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

server.registerResource(
  "resume-schema",
  SCHEMA_URI,
  {
    title: "Resume YAML Schema",
    description:
      "JSON Schema (draft-07) describing the YAML structure expected by the render_resume tool. Fetch this resource before constructing yaml_content.",
    mimeType: "application/schema+json",
  },
  async () => {
    const templateDir =
      process.env.TYPST_TEMPLATE_DIR ?? DEFAULT_TEMPLATE_DIR;
    const schemaPath = resolve(templateDir, "resume.schema.json");
    const text = await Bun.file(schemaPath).text();
    return {
      contents: [
        {
          uri: SCHEMA_URI,
          mimeType: "application/schema+json",
          text,
        },
      ],
    };
  }
);

server.registerTool(
  "get_resume_schema",
  {
    description:
      "Return the JSON Schema (draft-07) describing the YAML structure expected by render_resume. Call this first to learn the required shape of yaml_content. Same content as the schema://resume resource, exposed as a tool for clients without resource support.",
    inputSchema: {},
  },
  async () => {
    const templateDir =
      process.env.TYPST_TEMPLATE_DIR ?? DEFAULT_TEMPLATE_DIR;
    const schemaPath = resolve(templateDir, "resume.schema.json");
    try {
      const text = await Bun.file(schemaPath).text();
      return {
        content: [
          {
            type: "text" as const,
            text,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text" as const,
            text: `Failed to read resume schema at ${schemaPath}: ${
              error instanceof Error ? error.message : String(error)
            }`,
          },
        ],
        isError: true,
      };
    }
  }
);

server.registerTool(
  "render_resume",
  {
    description:
      "Render a Typst resume from YAML content into a PDF file. The output directory is configured via the TYPST_OUTPUT_DIR environment variable. " +
      "The yaml_content must conform to the JSON Schema exposed at resource URI 'schema://resume' (resource name: resume-schema). " +
      "Top-level keys: personal (required: name, email), summary, education, work, projects, skills. " +
      "Dates use YYYY-MM-DD format; endDate may be 'present'. Use *text* for bold in highlights.",
    inputSchema: {
      yaml_content: z
        .string()
        .describe(
          "Full YAML resume content as a string. Must conform to schema://resume."
        ),
      filename: z.string().describe("PDF filename (e.g. resume.pdf)."),
    },
  },
  async ({ yaml_content, filename }) => {
    const outputDir = process.env.TYPST_OUTPUT_DIR;
    if (!outputDir) {
      return {
        content: [
          {
            type: "text" as const,
            text: "Environment variable TYPST_OUTPUT_DIR is not set.",
          },
        ],
        isError: true,
      };
    }

    const templateDir =
      process.env.TYPST_TEMPLATE_DIR ?? DEFAULT_TEMPLATE_DIR;
    const templatePath = resolve(templateDir, "template.typ");
    const yamlPath = resolve(templateDir, "Resume_Modify.yml");
    const resolvedOutputPath = resolve(outputDir, filename);

    try {
      await Bun.write(yamlPath, yaml_content);

      const proc = Bun.spawn(
        ["typst", "compile", templatePath, resolvedOutputPath],
        {
          cwd: templateDir,
          stdout: "pipe",
          stderr: "pipe",
        }
      );

      const stdout = proc.stdout ? await proc.stdout.text() : "";
      const stderr = proc.stderr ? await proc.stderr.text() : "";
      const exitCode = await proc.exited;

      if (exitCode !== 0) {
        return {
          content: [
            {
              type: "text" as const,
              text:
                "Typst compilation failed.\n\n" +
                (stderr || stdout || `Exit code: ${exitCode}`),
            },
          ],
          isError: true,
        };
      }

      return {
        content: [
          {
            type: "text" as const,
            text: `PDF generated at: ${resolvedOutputPath}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text" as const,
            text: `Unexpected error: ${
              error instanceof Error ? error.message : String(error)
            }`,
          },
        ],
        isError: true,
      };
    }
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("typst-mcp server running on stdio");
}

main().catch((error: Error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});