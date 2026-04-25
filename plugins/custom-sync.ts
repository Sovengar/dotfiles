/**
 * Custom sync plugin — sincroniza carpetas adicionales más allá de opencode-synced
 * 
 * Sincroniza:
 * - ~/.agents (para skills personalizados)
 * - ~/.config/opencode (ya incluido en opencode-synced)
 * 
 * Usa symlinks o copia directa al repo de sync
 */

import type { Plugin } from "@opencode-ai/plugin"
import { spawnSync } from "node:child_process"
import { existsSync, mkdirSync, cpSync, readdirSync, statSync, rmSync } from "node:fs"
import { join, dirname, basename } from "node:path"
import { homedir } from "node:os"

interface PluginConfig {
  /** Ruta adicional a sincronizar (ej: C:\Users\buble\.agents) */
  extraPaths?: string[]
  /** Repo path local */
  repoPath?: string
}

const DEFAULT_EXTRA_PATHS = [
  "C:\\Users\\buble\\.agents",
]

export default {
  name: "custom-sync",
  
  onInit: async (ctx) => {
    const config: PluginConfig = ctx.config ?? {}
    const extraPaths = config.extraPaths ?? DEFAULT_EXTRA_PATHS
    const home = homedir()
    
    // Carpeta del repo de sync
    const repoPath = config.repoPath ?? join(process.env.LOCALAPPDATA ?? "", "opencode", "opencode-synced", "repo")
    const localStatePath = process.env.LOCALAPPDATA ?? ""
    
    console.log("[custom-sync] Iniciando sincronización adicional...")
    console.log("[custom-sync] Repo path:", repoPath)
    console.log("[custom-sync] Extra paths:", extraPaths)
    
    for (const srcPath of extraPaths) {
      if (!existsSync(srcPath)) {
        console.log("[custom-sync] Skip (no existe):", srcPath)
        continue
      }
      
      const folderName = basename(srcPath)
      const destPath = join(repoPath, folderName)
      
      console.log(`[custom-sync] Sincronizando: ${srcPath} -> ${destPath}`)
      
      // Eliminar destino existente
      if (existsSync(destPath)) {
        rmSync(destPath, { recursive: true, force: true })
      }
      
      // Copiar contenido
      try {
        cpSync(srcPath, destPath, { recursive: true })
        console.log(`[custom-sync] ✓ ${folderName} sincronizado`)
      } catch (err) {
        console.error(`[custom-sync] ✗ Error copiando ${folderName}:`, err)
      }
    }
    
    console.log("[custom-sync] Sincronización adicional completada")
  },
  
  hooks: {
    onStart: async (ctx) => {
      // Optional: hacer sync al iniciar opencode
    },
  },
} satisfies Plugin