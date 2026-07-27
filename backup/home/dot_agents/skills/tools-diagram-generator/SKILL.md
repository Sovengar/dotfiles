---
name: tools-diagram-generator
description: >
  Unified diagram creation skill for Excalidraw, Draw.io, and Napkin.
  Detects user intent and delegates to the appropriate tool.
  Trigger: When user asks to create a diagram, flowchart, mind map, whiteboard, or any visual diagram.
decisionFramework: "Always ask user to choose when ambiguous. If user has preference, use that tool. If project has corporate template, use Draw.io."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Diagram Generator

Unified entry point for creating diagrams. Detects intent and delegates to the best tool.

---

## Decision Framework

| Scenario | Action |
|----------|--------|
| **User mentions specific tool** | → Use that tool (Excalidraw, Draw.io, Napkin) |
| **New project, no preference** | → Use Excalidraw (default) |
| **Corporate/enterprise project** | → Use Draw.io (supports templates) |
| **Ambiguous/no preference** | → Ask user to choose |
| **Doubts** | → Ask user |

---

| User mentions | Use |
|--------------|-----|
| "draw.io", "mxGraph", ".drawio", "corporate template", "enterprise" | Draw.io |
| "napkin", "pizarra", "whiteboard", "interactive", "collaborate" | Napkin |
| "excalidraw", ".excalidraw", "mind map", "mindmap", "flowchart", "sequence", "architecture", "DFD", "ER diagram" | Excalidraw |
| Icon libraries (AWS/GCP/Azure) + "corporate template" | Draw.io |
| Ambiguous | Ask user to choose: Excalidraw / Draw.io / Napkin |

## Triggers

This skill activates when user says:
- "create a diagram"
- "crear un diagrama"
- "draw a flowchart"
- "haz un diagrama"
- "generate an architecture diagram"
- "diagrama de flujo"
- "mapa mental"
- "diagrama de arquitectura"
- "pizarra"
- "whiteboard"
- "mind map"
- "excalidraw"
- "draw.io"
- "napkin"

---

# Excalidraw Mode

## When to Use Excalidraw

Use when users request:
- "Create a diagram showing..."
- "Make a flowchart for..."
- "Visualize the process of..."
- "Draw the system architecture of..."
- "Generate a mind map about..."
- "Create an Excalidraw file for..."

**Supported diagram types:**
- 📊 **Flowcharts**: Sequential processes, workflows, decision trees
- 🔗 **Relationship Diagrams**: Entity relationships, system components, dependencies
- 🧠 **Mind Maps**: Concept hierarchies, brainstorming results, topic organization
- 🏗️ **Architecture Diagrams**: System design, module interactions, data flow
- 📈 **Data Flow Diagrams (DFD)**: Data flow visualization
- 🏊 **Business Flow (Swimlane)**: Cross-functional workflows
- 📦 **Class Diagrams**: Object-oriented design
- 🔄 **Sequence Diagrams**: Object interactions over time
- 📃 **ER Diagrams**: Database entity relationships

## Step-by-Step Workflow

### Step 1: Analyze the Request

Determine:
1. **Diagram type** (flowchart, relationship, mind map, architecture)
2. **Key elements** (entities, steps, concepts)
3. **Relationships** (flow, connections, hierarchy)
4. **Complexity** (number of elements)

### Step 2: Generate the Excalidraw JSON

Create `.excalidraw` file with:
- **rectangle**: Boxes for entities, steps, concepts
- **ellipse**: Alternative shapes for emphasis
- **diamond**: Decision points
- **arrow**: Directional connections
- **text**: Labels and annotations

**Key properties:**
- Position: `x`, `y` coordinates
- Size: `width`, `height`
- Style: `strokeColor`, `backgroundColor`, `fillStyle`
- Font: `fontFamily: 5` (Excalifont - **required**)
- Text: Embedded text for labels

### Step 3: Save and Provide

1. Save as `<descriptive-name>.excalidraw`
2. Instructions:
   - Visit https://excalidraw.com
   - Click "Open" or drag-and-drop the file
   - Or use Excalidraw VS Code extension

## Element Guidelines

| Diagram Type | Recommended | Maximum |
|--------------|-------------|---------|
| Flowchart steps | 3-10 | 15 |
| Relationship entities | 3-8 | 12 |
| Mind map branches | 4-6 | 8 |

**Layout:**
- Horizontal gap: 200-300px
- Vertical gap: 100-150px
- Text size: 16-24px

## Validation Checklist

- [ ] All elements have unique IDs
- [ ] Coordinates prevent overlapping
- [ ] Text is readable (16+ px)
- [ ] All text uses `fontFamily: 5` (Excalifont)
- [ ] Arrows connect logically
- [ ] Valid JSON

---

# Draw.io Mode

## When to Use Draw.io

Use when user mentions:
- "draw.io", "mxGraph", ".drawio"
- "corporate template"
- "enterprise diagram"
- "standard format"
- Icon libraries (AWS/GCP/Azure)

## Features

- Professional diagram templates
- Corporate/stylized shapes
- Icon library support
- MX Graph format (.drawio, .xml)

## Output

Save as `<name>.drawio` and open in:
- https://app.diagrams.net/
- VS Code drawio extension

---

# Napkin Mode

## When to Use Napkin

Use when user mentions:
- "napkin"
- "pizarra"
- "whiteboard"
- "interactive"
- "collaborate"
- "bocetar" (sketch)
- "brainstorm"

## How It Works

1. Copy bundled HTML template to user Desktop
2. User opens in browser
3. User draws/skills sticky notes
4. Agent reads whiteboard via PNG snapshot
5. Agent responds with analysis

## Workflow

```bash
Copy: assets/napkin.html → ~/Desktop/napkin.html
```

## For Users

**Target audience:** Non-technical stakeholders (PMs, designers, business)

**What user does:**
1. Open napkin.html in browser
2. Draw, sketch, add sticky notes
3. Share/screenshot back to agent

**What agent does:**
- Reads the whiteboard
- Provides analysis, suggestions, next steps

---

# Response Template

Before creating, confirm with user:

> "Voy a usar [Excalidraw/Draw.io/Napkin] para crear [diagrama]. ¿Continúas?"

---

# Complex Workflows

If user wants "bocetar y luego generar un diagrama formal":
1. Open Napkin for sketching
2. After user shares → extract concepts
3. Generate Excalidraw with extracted elements
