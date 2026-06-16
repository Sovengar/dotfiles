import { rmSync } from "node:fs"
import { mkdir, writeFile } from "node:fs/promises"
import { join } from "node:path"
import type { Plugin } from "@opencode-ai/plugin"

const BRIDGER_DIR = "/tmp/opencode-prompt-bridger"

function asTrackedFileReferences(text: string) {
  const trackedText = text.replace(/(^|\s+)((?:\\\s|\S)+)/g, (_match, separator: string, token: string) => {
    return token.startsWith("@") ? `${separator}${token}` : `${separator}@${token}`
  })

  return trackedText.endsWith(" ") ? trackedText : `${trackedText} `
}

export const PromptBridger: Plugin = async ({ client, directory }) => {
  await mkdir(BRIDGER_DIR, { recursive: true })

  const server = Bun.serve({
    hostname: "127.0.0.1",
    port: 0,
    async fetch(request) {
      const url = new URL(request.url)

      if (request.method === "GET" && url.pathname === "/health") {
        return Response.json({ ok: true, directory, pid: process.pid })
      }

      if (request.method !== "POST" || url.pathname !== "/append") {
        return Response.json({ ok: false, error: "not found" }, { status: 404 })
      }

      try {
        const body = await request.json() as { text?: unknown }
        const text = typeof body.text === "string" ? body.text : ""

        if (!text.trim()) {
          return Response.json({ ok: false, error: "missing text" }, { status: 400 })
        }

        await client.tui.appendPrompt({ body: { text: asTrackedFileReferences(text) } })
        await client.tui.showToast({
          body: {
            title: "OpenCode picker",
            message: "Selected paths appended to the prompt",
            variant: "success",
          },
        }).catch(() => {})

        return Response.json({ ok: true })
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error)
        return Response.json({ ok: false, error: message }, { status: 500 })
      }
    },
  })

  const registryPath = join(BRIDGER_DIR, `${process.pid}.json`)
  await writeFile(registryPath, JSON.stringify({
    pid: process.pid,
    directory,
    url: `http://${server.hostname}:${server.port}`,
    startedAt: Date.now(),
  }, null, 2))

  const cleanup = () => {
    rmSync(registryPath, { force: true })
    server.stop(true)
  }

  process.once("exit", cleanup)
  process.once("SIGINT", () => {
    cleanup()
    process.exit(130)
  })
  process.once("SIGTERM", () => {
    cleanup()
    process.exit(143)
  })

  return {}
}
