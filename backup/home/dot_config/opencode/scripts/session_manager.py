#!/usr/bin/env python3
"""
session_manager.py — Task & agent state manager for opencode sessions.

State file: opencode/scripts/.session.json

AGENT INTERFACE (agents call these when they start/update/finish):
  python session_manager.py start-task   <task_name>
  python session_manager.py register     <agent> <description> [--depends-on agent1,agent2]
  python session_manager.py update       <agent> <progress_0_to_100>
  python session_manager.py complete     <agent>
  python session_manager.py block        <agent> <reason>
  python session_manager.py fail         <agent> <reason>

STATUS (called by show-task-status command):
  python session_manager.py status

RESET:
  python session_manager.py reset
"""

import json
import sys
import os
from datetime import datetime, timezone
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────

SCRIPT_DIR  = Path(__file__).parent
STATE_FILE  = SCRIPT_DIR / ".session.json"
DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

# ── Status definitions ─────────────────────────────────────────────────────────

STATUS_ICON = {
    "completed":   "✅",
    "in_progress": "🔄",
    "blocked":     "🚫",
    "failed":      "❌",
    "pending":     "⏳",
}

TASK_STATUS_ICON = {
    "in_progress": "🔄 EN PROGRESO",
    "completed":   "✅ COMPLETADA",
    "blocked":     "🚫 BLOQUEADA",
    "failed":      "❌ FALLIDA",
    "pending":     "⏳ PENDIENTE",
}

# ── Persistence ───────────────────────────────────────────────────────────────

def load_state() -> dict:
    if not STATE_FILE.exists():
        return {}
    with open(STATE_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_state(state: dict) -> None:
    with open(STATE_FILE, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)

def now() -> str:
    return datetime.now(timezone.utc).strftime(DATE_FORMAT)

# ── Commands ──────────────────────────────────────────────────────────────────

def cmd_start_task(name: str) -> None:
    """Initialize a new task session, replacing any previous one."""
    state = {
        "task": {
            "name": name,
            "status": "in_progress",
            "created_at": now(),
            "completed_at": None,
        },
        "subtasks": [],
    }
    save_state(state)
    print(f"✅ Tarea iniciada: {name}")


def cmd_register(agent: str, description: str, depends_on: list[str]) -> None:
    """Agent registers itself when it starts working."""
    state = load_state()
    if not state:
        print("❌ No hay tarea activa. Ejecutá: start-task <nombre>", file=sys.stderr)
        sys.exit(1)

    # Avoid duplicate registration — update instead
    for sub in state["subtasks"]:
        if sub["agent"] == agent:
            sub["description"] = description
            sub["depends_on"]  = depends_on
            save_state(state)
            print(f"🔄 Agente actualizado: {agent}")
            return

    state["subtasks"].append({
        "agent":        agent,
        "description":  description,
        "status":       "in_progress",
        "progress":     0,
        "depends_on":   depends_on,
        "note":         None,
        "started_at":   now(),
        "completed_at": None,
    })
    save_state(state)
    print(f"✅ Agente registrado: {agent} — {description}")


def cmd_update(agent: str, progress: int) -> None:
    """Agent reports progress (0–100)."""
    if not (0 <= progress <= 100):
        print("❌ El progreso debe estar entre 0 y 100.", file=sys.stderr)
        sys.exit(1)

    state = load_state()
    sub   = _find_subtask(state, agent)
    sub["progress"] = progress
    sub["status"]   = "in_progress"
    save_state(state)
    print(f"🔄 {agent}: {progress}%")


def cmd_complete(agent: str) -> None:
    """Agent marks itself as completed."""
    state = load_state()
    sub   = _find_subtask(state, agent)
    sub["status"]       = "completed"
    sub["progress"]     = 100
    sub["completed_at"] = now()
    sub["note"]         = None
    _maybe_complete_task(state)
    save_state(state)
    print(f"✅ {agent}: completado")


def cmd_block(agent: str, reason: str) -> None:
    """Agent marks itself as blocked."""
    state = load_state()
    sub   = _find_subtask(state, agent)
    sub["status"] = "blocked"
    sub["note"]   = reason
    state["task"]["status"] = "blocked"
    save_state(state)
    print(f"🚫 {agent}: bloqueado — {reason}")


def cmd_fail(agent: str, reason: str) -> None:
    """Agent marks itself as failed."""
    state = load_state()
    sub   = _find_subtask(state, agent)
    sub["status"]       = "failed"
    sub["note"]         = reason
    sub["completed_at"] = now()
    state["task"]["status"] = "failed"
    save_state(state)
    print(f"❌ {agent}: falló — {reason}")


def cmd_status() -> None:
    """Display current task execution state."""
    state = load_state()

    if not state:
        print("⚠️  No hay sesión activa.")
        print("   Iniciá una con: python session_manager.py start-task <nombre>")
        return

    task     = state["task"]
    subtasks = state["subtasks"]

    # ── Header ────────────────────────────────────────────────────────────────
    print()
    print(f"=== Tarea: {task['name']} ===")
    print()

    if not subtasks:
        print("   Sin subtareas registradas aún.")
        print()
        return

    # ── Progress bar ──────────────────────────────────────────────────────────
    completed = [s for s in subtasks if s["status"] == "completed"]
    pct       = int(len(completed) / len(subtasks) * 100) if subtasks else 0
    bar       = _progress_bar(pct)
    print(f"Progreso: {bar} {pct}%")
    print()

    # ── Subtask tree ──────────────────────────────────────────────────────────
    bottleneck = _find_bottleneck(subtasks)

    for sub in subtasks:
        icon   = STATUS_ICON.get(sub["status"], "❓")
        agent  = sub["agent"]
        desc   = sub["description"]
        status = sub["status"]

        if status == "in_progress":
            pct_sub = sub.get("progress", 0)
            suffix  = f"({pct_sub}%)"
            if agent == bottleneck:
                suffix += " ← cuello de botella"
        elif status == "blocked":
            suffix = f"— bloqueado: {sub.get('note', '')}"
        elif status == "failed":
            suffix = f"— falló: {sub.get('note', '')}"
        elif status == "completed":
            suffix = ""
        else:
            blocked_by = _blocked_by(sub, subtasks)
            suffix     = f"— esperando a {blocked_by}" if blocked_by else ""

        line = f"   {icon} {agent:<24} → {desc}"
        if suffix:
            line += f"  {suffix}"
        print(line)

    # ── Task completability ───────────────────────────────────────────────────
    print()
    task_status = _derive_task_status(task, subtasks)
    label       = TASK_STATUS_ICON.get(task_status, task_status)

    if task_status == "completed":
        print(f"Estado: {label} — lista para validación")
    elif task_status == "blocked":
        blocker = next((s for s in subtasks if s["status"] == "blocked"), None)
        reason  = blocker["note"] if blocker else "motivo desconocido"
        print(f"Estado: {label} — {reason}")
    elif task_status == "failed":
        failed  = [s["agent"] for s in subtasks if s["status"] == "failed"]
        print(f"Estado: {label} — falló en: {', '.join(failed)}")
    elif bottleneck:
        print(f"Estado: {label} — no completable hasta que {bottleneck} termine")
    else:
        print(f"Estado: {label}")

    print()


def cmd_reset() -> None:
    """Remove current session state."""
    if STATE_FILE.exists():
        STATE_FILE.unlink()
        print("🗑️  Sesión eliminada.")
    else:
        print("⚠️  No había sesión activa.")

# ── Helpers ───────────────────────────────────────────────────────────────────

def _find_subtask(state: dict, agent: str) -> dict:
    if not state:
        print("❌ No hay tarea activa.", file=sys.stderr)
        sys.exit(1)
    for sub in state["subtasks"]:
        if sub["agent"] == agent:
            return sub
    print(f"❌ Agente no registrado: {agent}", file=sys.stderr)
    print("   Registralo primero con: register <agent> <description>", file=sys.stderr)
    sys.exit(1)


def _maybe_complete_task(state: dict) -> None:
    """Mark root task as completed if all subtasks are done."""
    all_done = all(s["status"] == "completed" for s in state["subtasks"])
    if all_done and state["subtasks"]:
        state["task"]["status"]       = "completed"
        state["task"]["completed_at"] = now()


def _derive_task_status(task: dict, subtasks: list) -> str:
    """Compute effective task status from subtask states."""
    if any(s["status"] == "failed"   for s in subtasks): return "failed"
    if any(s["status"] == "blocked"  for s in subtasks): return "blocked"
    if all(s["status"] == "completed" for s in subtasks) and subtasks: return "completed"
    return "in_progress"


def _find_bottleneck(subtasks: list) -> str | None:
    """Return the in-progress agent that is blocking other pending agents."""
    in_progress = {s["agent"] for s in subtasks if s["status"] == "in_progress"}
    for sub in subtasks:
        if sub["status"] == "pending":
            for dep in sub.get("depends_on", []):
                if dep in in_progress:
                    return dep
    # If no explicit dependency found, return any in-progress agent
    if len(in_progress) == 1:
        return next(iter(in_progress))
    return None


def _blocked_by(sub: dict, subtasks: list) -> str | None:
    """Return which agent is blocking this pending subtask."""
    not_done = {s["agent"] for s in subtasks if s["status"] != "completed"}
    for dep in sub.get("depends_on", []):
        if dep in not_done:
            return dep
    return None


def _progress_bar(pct: int, width: int = 10) -> str:
    filled = int(width * pct / 100)
    return "█" * filled + "░" * (width - filled)

# ── CLI entry point ───────────────────────────────────────────────────────────

def main() -> None:
    args = sys.argv[1:]

    if not args:
        print(__doc__)
        sys.exit(0)

    cmd = args[0]

    match cmd:
        case "status":
            cmd_status()

        case "start-task":
            if len(args) < 2:
                print("Uso: start-task <nombre_de_la_tarea>", file=sys.stderr)
                sys.exit(1)
            cmd_start_task(" ".join(args[1:]))

        case "register":
            if len(args) < 3:
                print("Uso: register <agent> <description> [--depends-on agent1,agent2]", file=sys.stderr)
                sys.exit(1)
            agent       = args[1]
            depends_on  = []
            desc_parts  = []
            i = 2
            while i < len(args):
                if args[i] == "--depends-on" and i + 1 < len(args):
                    depends_on = [a.strip() for a in args[i + 1].split(",")]
                    i += 2
                else:
                    desc_parts.append(args[i])
                    i += 1
            description = " ".join(desc_parts)
            cmd_register(agent, description, depends_on)

        case "update":
            if len(args) < 3:
                print("Uso: update <agent> <progress>", file=sys.stderr)
                sys.exit(1)
            try:
                progress = int(args[2])
            except ValueError:
                print("❌ El progreso debe ser un número entero (0–100).", file=sys.stderr)
                sys.exit(1)
            cmd_update(args[1], progress)

        case "complete":
            if len(args) < 2:
                print("Uso: complete <agent>", file=sys.stderr)
                sys.exit(1)
            cmd_complete(args[1])

        case "block":
            if len(args) < 3:
                print("Uso: block <agent> <reason>", file=sys.stderr)
                sys.exit(1)
            cmd_block(args[1], " ".join(args[2:]))

        case "fail":
            if len(args) < 3:
                print("Uso: fail <agent> <reason>", file=sys.stderr)
                sys.exit(1)
            cmd_fail(args[1], " ".join(args[2:]))

        case "reset":
            cmd_reset()

        case _:
            print(f"❌ Comando desconocido: {cmd}", file=sys.stderr)
            print("Comandos disponibles: status, start-task, register, update, complete, block, fail, reset")
            sys.exit(1)


if __name__ == "__main__":
    main()