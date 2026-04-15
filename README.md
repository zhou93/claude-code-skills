# claude-code-skills

> A collection of global Skills for [Claude Code](https://code.claude.com).

[English](./README.md) | [中文](./README.zh-CN.md)

---

## Skills

### arch-doc

Analyze any feature domain across all architectural layers and generate a structured, diagram-rich document — automatically.

- [x] Spawns 4 parallel subagents scoped by layer: data / service / client / runtime
- [x] Produces a C4 L1 system boundary diagram + internal layer diagram + interaction sequence diagrams
- [x] Intelligently selects diagram format per context (Mermaid / table / ASCII)
- [x] Enforces ≤ 300 tokens per diagram to prevent bloat
- [x] Outputs versioned documents ready for human annotation
- [x] Works on any domain: `skill-agent`, `auth`, `chat-runtime`, `file-storage`, etc.

### refine

Process `<!-- annotation -->` blocks in any Markdown document and apply targeted edits — without rewriting from scratch.

- [x] Scans all annotations and classifies them (add-content / fix / layout / restructure / clarify / terminology)
- [x] Decides per annotation whether codebase reads are needed
- [x] Processes annotations one by one, removes each after handling
- [x] Updates document version number and date automatically
- [x] Works on any Markdown file: architecture docs, task plans, workflow docs, research notes

---

## Installation

### One-liner (recommended)

```bash
git clone https://github.com/zhou93/claude-code-skills.git
cd claude-code-skills
bash install.sh
```

### Manual

```bash
cp -r arch-doc ~/.claude/skills/
cp -r refine ~/.claude/skills/
```

Restart Claude Code after installation.

---

## Usage

```bash
# Generate an architecture document (outputs to tasks/<topic>/research.md)
arch-doc skill-agent
arch-doc auth
arch-doc chat-runtime

# Process annotations in the most recently discussed document
refine

# Process annotations in a specific file
refine tasks/skill-agent/research.md
refine .tasks/fix-auth/todo.md
```

### Workflow

```
arch-doc <topic>           Generate document, versioned as "v1 draft"
       ↓
Add <!-- annotations --> in the document
       ↓
refine                     Process annotations, bump to v2
       ↓
Annotate again → refine → v3 → ...
```

---

## Why these skills

The [anthropics/skills](https://github.com/anthropics/skills) official repository has no skill for architecture documentation — this gap is real. These two skills introduce capabilities not found in existing tools:

1. **Annotation-driven iteration loop** — humans annotate a draft, AI applies targeted edits. No existing tool (Archyl, Swimm, Mintlify) implements this as a file-based workflow.
2. **Runtime behavior coverage** — goes beyond static analysis to document conversation flows, tool call routing, and executor dispatch chains.
3. **Diagram selection rules** — explicit conventions for when to use Mermaid, when to use a table, and when plain ASCII is clearer.

---

## License

MIT
