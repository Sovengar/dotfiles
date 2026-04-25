/**
 * Manual sync para .agents
 * Corre con: bun run scripts/manual-sync-agents.ts
 */

import { existsSync, cpSync, rmSync } from "node:fs"
import { join } from "node:path"
import { spawnSync } from "node:child_process"

const SRC = "C:\\Users\\buble\\.agents"
const REPO = "C:\\Users\\buble\\AppData\\Local\\opencode\\opencode-synced\\repo"
const DEST = join(REPO, ".agents")

console.log("Sincronizando .agents...")

if (!existsSync(SRC)) {
  console.error("ERROR: No existe", SRC)
  process.exit(1)
}

// Remove old
if (existsSync(DEST)) {
  rmSync(DEST, { recursive: true, force: true })
}

// Copy
cpSync(SRC, DEST, { recursive: true })
console.log("Copiado a", DEST)

// Git add
const gitAdd = spawnSync("git", ["add", ".agents"], { cwd: REPO, stdio: "inherit" })
if (gitAdd.status !== 0) {
  console.error("Git add falló")
  process.exit(1)
}

// Git status
const gitStatus = spawnSync("git", ["status", "--short"], { cwd: REPO, encoding: "utf-8" })
console.log("Status:", gitStatus.stdout)

if (!gitStatus.stdout.trim()) {
  console.log("No hay cambios para commit")
  process.exit(0)
}

// Git commit
const gitCommit = spawnSync("git", ["commit", "-m", "Sync .agents folder"], { cwd: REPO, stdio: "inherit" })
if (gitCommit.status !== 0) {
  console.error("Git commit falló")
  process.exit(1)
}

// Git push
const gitPush = spawnSync("git", ["push"], { cwd: REPO, stdio: "inherit" })
if (gitPush.status !== 0) {
  console.error("Git push falló")
  process.exit(1)
}

console.log("✓ .agents sincronizado y actualizado al remote")