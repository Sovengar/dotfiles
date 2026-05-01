#!/usr/bin/env python3
"""
Simple selector to decide which visual skill to use based on a user prompt.
This is a local test helper and does not modify other skills.
"""
import sys

RULES = [
    ("draw-io-diagram-generator", ["draw.io", "drawio", ".drawio", "mxgraph", "mxfile", "corporate", "plantilla", "template"]),
    ("napkin", ["napkin", "pizarra", "whiteboard", "interactive", "compartir", "share"]),
    ("excalidraw-diagram-generator", ["excalidraw", ".excalidraw", "mind map", "mindmap", "mapa mental", "diagrama de flujo", "diagrama flujo", "flowchart", "sequence", "architecture", "dfd", "data flow", "diagrama de arquitectura"]),
]

ICON_HINTS = ["aws", "gcp", "azure", "k8s", "kubernetes", "icons"]


SPANISH_HINTS = ["diagrama", "diagrama de flujo", "mapa mental", "mapa", "flujo"]


def select_visual_skill(prompt: str) -> str:
    p = prompt.lower()
    for skill, keywords in RULES:
        for k in keywords:
            if k.lower() in p:
                return skill
    for k in ICON_HINTS:
        if k in p:
            return "excalidraw-diagram-generator"
    # Fall back: detect Spanish generic hints for diagram types
    for k in SPANISH_HINTS:
        if k in p:
            # prefer excalidraw for editable diagrams
            return "excalidraw-diagram-generator"
    return "clarify"


def make_payload(skill: str, prompt: str) -> dict:
    # Minimal payload generator for simulation
    if skill == "excalidraw-diagram-generator":
        return {
            "diagram_type": "flowchart",
            "title": prompt[:60],
            "elements": [],
            "icon_library": None,
            "output_name": "diagram.excalidraw",
            "complexity": "small",
        }
    if skill == "draw-io-diagram-generator":
        return {
            "diagram_type": "architecture",
            "template": "assets/templates/architecture.drawio",
            "output_path": "docs/arch.drawio",
            "validate": True,
        }
    if skill == "napkin":
        return {"action": "open_whiteboard", "copy_template": "~/Desktop/napkin.html"}
    return {}


def validate_payload(skill: str, payload: dict) -> (bool, list):
    """Validate payload for the selected skill. Returns (is_valid, errors)."""
    errors = []
    if skill == "excalidraw-diagram-generator":
        allowed = {"flowchart", "architecture", "mindmap", "mind map", "sequence", "dfd", "class", "er", "data flow"}
        dt = payload.get("diagram_type")
        if not dt:
            errors.append("missing diagram_type")
        elif dt.lower() not in allowed:
            errors.append(f"unsupported diagram_type: {dt}")
        if not payload.get("title"):
            errors.append("missing title")
        out = payload.get("output_name")
        if out and not out.endswith(".excalidraw"):
            errors.append("output_name should end with .excalidraw")
    elif skill == "draw-io-diagram-generator":
        if not payload.get("diagram_type"):
            errors.append("missing diagram_type")
        tpl = payload.get("template")
        if not tpl:
            errors.append("missing template (path to .drawio template)")
        else:
            # warn if template file doesn't exist on disk
            try:
                from pathlib import Path

                if not Path(tpl).exists():
                    errors.append(f"template not found: {tpl}")
            except Exception:
                pass
        op = payload.get("output_path")
        if op and not any(op.endswith(ext) for ext in (".drawio", ".drawio.svg", ".drawio.png")):
            errors.append("output_path should have a drawio extension (.drawio/.drawio.svg/.drawio.png)")
    elif skill == "napkin":
        act = payload.get("action")
        if act not in ("open_whiteboard", "process_snapshot", None):
            errors.append(f"unsupported napkin action: {act}")
        if act == "process_snapshot":
            if not payload.get("json_path") and not payload.get("snapshot_path"):
                errors.append("process_snapshot requires json_path or snapshot_path")
    else:
        errors.append("unknown skill for validation")

    return (len(errors) == 0, errors)


def run_tests():
    tests = [
        "Crea un diagrama de flujo del registro de usuarios",
        "Necesito un .drawio con el template corporativo para la arquitectura 3-tier",
        "Abramos una pizarra para bocetar ideas — quiero algo interactivo",
        "Haz un diagrama de la arquitectura y añade iconos AWS",
        "Genera un mindmap sobre roadmapping",
        "Quiero un diagrama, haz lo que creas mejor",
    ]
    for t in tests:
        skill = select_visual_skill(t)
        payload = make_payload(skill, t)
        print("PROMPT:", t)
        print("=> SELECTED:", skill)
        print("=> PAYLOAD:", payload)
        print("-" * 60)


def main():
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
        skill = select_visual_skill(prompt)
        payload = make_payload(skill, prompt)
        print(skill)
        print(payload)
        return
    run_tests()


if __name__ == "__main__":
    main()
