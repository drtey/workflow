// Bridges the Claude Code shell hooks (.claude/hooks/*) into opencode.
// Same scripts, same stdin JSON contract — single source of truth for both tools.
import { spawnSync } from "node:child_process"

export const ClaudeHooks = async ({ directory }) => {
  const run = (script, payload) =>
    spawnSync("bash", [`${directory}/.claude/hooks/${script}`], {
      input: JSON.stringify(payload),
      cwd: directory,
      encoding: "utf8",
    })

  const captureEpisode = () => {
    const r = run("on-stop.sh", {})
    if (r.status !== 0) console.error(`[claude-hooks] on-stop.sh:\n${r.stderr}`)
  }

  // after-hooks don't receive tool args, so stash them by callID in the before-hook
  const pendingFiles = new Map()

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const r = run("pre-bash.sh", { tool_input: { command: output.args.command } })
        if (r.status !== 0) throw new Error(r.stderr || "blocked by pre-bash.sh")
      }
      if (input.tool === "edit" || input.tool === "write") {
        pendingFiles.set(input.callID, output.args.filePath)
      }
    },

    "tool.execute.after": async (input) => {
      if (input.tool !== "edit" && input.tool !== "write") return
      const filePath = pendingFiles.get(input.callID)
      pendingFiles.delete(input.callID)
      if (!filePath) return
      const r = run("post-edit.sh", { tool_input: { file_path: filePath } })
      if (r.status !== 0) throw new Error(r.stderr || "post-edit.sh failed")
    },

    // inject durable context into the compaction summary; raw capture happens on
    // the stable session.compacted event below (don't capture twice)
    "experimental.session.compacting": async (input, output) => {
      output.context.push(
        [
          "## Persistent project memory",
          "Preserve in the continuation summary: current task and status, decisions",
          "made, constraints, files in flight, next steps.",
          "Durable state lives in memory/MEMORY.md (semantic) and memory/episodic/",
          "(raw logs); keep references to open CONFLICT: entries and pending work.",
        ].join("\n"),
      )
    },

    event: async ({ event }) => {
      if (event.type !== "session.idle" && event.type !== "session.compacted") return
      captureEpisode()
    },
  }
}
