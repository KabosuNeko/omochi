import { execSync, spawnSync } from "node:child_process"

/** Minimal shape of the hook API this plugin uses (`ctx.tool.hook`). */
type RtkPluginContext = {
  tool: {
    hook(name: string, handler: (event: unknown) => void | Promise<void>): Promise<void>
  }
}

export default {
  id: "rtk",
  async setup(ctx: RtkPluginContext) {
    try {
      execSync("which rtk", { stdio: "ignore" })
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", (event: unknown) => {
      if (typeof event !== "object" || event === null) return
      if (!("tool" in event) || !("input" in event)) return
      if (typeof event.tool !== "string") return
      const toolName = event.tool.toLowerCase()
      if (toolName !== "bash" && toolName !== "shell") return
      const input = event.input
      if (typeof input !== "object" || input === null) return
      if (!("command" in input) || typeof input.command !== "string" || !input.command) return
      // spawnSync with an argv array: no shell, so the command text cannot be
      // expanded or interpolated. `rtk rewrite` exits 3 after a successful
      // rewrite and exits 1 with empty stdout when no filter matches, so
      // stdout — not the exit status — is the success signal.
      const rewritten = spawnSync("rtk", ["rewrite", input.command], { encoding: "utf-8" }).stdout?.trim() ?? ""
      if (rewritten && rewritten !== input.command) {
        input.command = rewritten
      }
    })
  },
}
