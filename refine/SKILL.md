---
name: refine
description: >
  Invoke after annotating any Markdown document with <!-- comment --> blocks.
  Reads all annotations, makes targeted edits, removes processed annotations,
  and updates the document version. Works on any document type: architecture
  docs, workflow docs, task plans, research notes. Not for rewriting from scratch.
version: 1.0.0
allowed-tools:
  - Read
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
---

# refine: Annotation-Driven Document Refinement

Process human annotations in any Markdown file and apply targeted edits. One annotation = one focused change. No full rewrites unless the annotation explicitly requests one.

The contract: every `<!-- ... -->` block is a directive. When this skill exits, all annotations are gone and every directive has been acted on.

## Invocation

```
refine [file-path]
```

**File resolution order:**
1. If `file-path` is provided, use it directly.
2. If not provided, look for the most recently modified `.md` file mentioned in the current conversation.
3. If still unclear, use `AskUserQuestion` to ask which file to refine.

Accept both absolute and relative paths. Resolve relative paths from the project root (`git rev-parse --show-toplevel`).

---

## Phase 1: Inventory Annotations

Read the full target file. Extract every `<!-- ... -->` block with its line number and surrounding context (the heading it falls under, the paragraph it's adjacent to).

Build an annotation inventory:

| # | Line | Location (heading) | Annotation text | Type |
|---|------|--------------------|-----------------|------|
| 1 | 12 | ## 一、架构总览 | 需要加 C4 L1 图 | add-content |
| 2 | 47 | ### 2.1 流程图 | 这里的箭头方向有误 | fix |
| 3 | 91 | 1.3 两层数据架构 | 这句话被挡住了 | layout |

**Annotation types:**

| Type | Description |
|------|-------------|
| `add-content` | Missing information needs to be added |
| `fix` | Something is wrong (diagram, logic, description) |
| `restructure` | Section needs reordering or splitting |
| `layout` | Formatting/display issue (text hidden, diagram too large) |
| `clarify` | Existing content needs to be made more precise |
| `scope` | Content is out of scope or irrelevant |
| `terminology` | Word choice or naming inconsistency |

Print the inventory before processing. If zero annotations are found, report this and exit — do not modify the file.

---

## Phase 2: Classify Each Annotation

For each annotation, determine:

1. **Requires reading code?**
   - `add-content` about a feature → likely yes
   - `fix` on a diagram → probably no, just look at surrounding content
   - `layout` / `terminology` / `restructure` → no

2. **Scope of edit:**
   - `local`: change within the annotated paragraph or section
   - `section`: restructure or expand a full section
   - `cross-document`: affects multiple sections

3. **Dependencies:** does annotation N depend on the result of annotation M? If yes, process M first.

List your processing order if reordering was needed.

---

## Phase 3: Process Annotations

Process each annotation in order. For each:

**Step A — Understand intent.** Read the annotation text and the surrounding 10-20 lines for context. If the annotation is ambiguous and the wrong interpretation would cause significant work, use `AskUserQuestion` to clarify. For minor ambiguities, pick the most likely interpretation and note it.

**Step B — Gather information (if needed).** Only for `add-content` annotations that require codebase knowledge:
- Use `Grep` to find relevant code patterns
- Use `Read` to read specific files
- Use `Glob` to locate relevant file paths
- Stay focused: read only what's needed for this annotation

**Step C — Apply the edit.** Use `Edit` to make the change. Follow these rules by annotation type:

| Type | Edit behavior |
|------|--------------|
| `add-content` | Insert new content at or after the annotation location |
| `fix` | Correct the specific error; don't touch surrounding content |
| `restructure` | Move, split, or merge sections as indicated |
| `layout` | Fix the formatting issue (replace diagram with table, move text above diagram, etc.) |
| `clarify` | Rewrite the annotated sentence/paragraph for precision |
| `scope` | Remove the content if truly out of scope; confirm with user if unsure |
| `terminology` | Find and replace the term consistently across the document |

**Step D — Remove the annotation.** Delete the `<!-- ... -->` block after the edit is applied. If the edit fully resolves the annotation, it's gone. If you made a partial fix and more work is needed, replace the annotation with a new one describing what remains.

---

## Diagram-Specific Fixes

When an annotation targets a diagram:

**"图太复杂" / "看不懂" / "节点太多":**
Split into two diagrams at a natural boundary, or replace with a table if the diagram is essentially a list with attributes.

**"箭头方向有误" / "连接错误":**
Fix only the specific edges mentioned. Don't redraw the whole diagram.

**"用 Mermaid" / "换成 ASCII":**
Convert the diagram to the requested format. Preserve all information.

**"图被文字挡住" / "格式问题":**
Move the prose above the code block, or replace the diagram with a table.

**Diagram constraints to maintain:**
- Each Mermaid block: ≤ 300 tokens
- If converting to Mermaid introduces bloat, split into two smaller diagrams

---

## Version Update

After all annotations are processed, update the document version in the frontmatter or header line:

- `v1 待批注` → `v2 待批注` (if annotations remain or new ones were added)
- `v1 待批注` → `v2` (if all annotations are resolved and document is clean)
- `v2 待批注` → `v3 待批注` (and so on)

Update the date to today.

---

## Phase 4: Verification

After all edits, re-read the full document and verify:

- [ ] Zero `<!-- -->` blocks remain (or only new ones added during this session)
- [ ] No broken Mermaid syntax (check for unclosed blocks, missing `end` keywords)
- [ ] No orphaned headings (sections with no content)
- [ ] Version number and date updated
- [ ] No content was accidentally deleted outside the annotated regions

If Mermaid syntax is uncertain, paste the diagram block into a comment and note "verify rendering."

---

## Output

In chat, report:

1. Number of annotations processed
2. For each: annotation type, one-line description of change made
3. Whether any code was read (and which files)
4. Final document version

Example:
```
处理了 3 条批注:
· [layout] 1.3 节 — 将 Mermaid 图替换为表格，文字不再被遮挡
· [add-content] 1.1 节 — 新增 C4 L1 系统边界图（读取了 src/envs/app.ts）
· [terminology] 全文 — "本地市场" → "自有市场"（6 处）

文档: tasks/skill-agent/research.md → v6
```

Do not paste the modified document sections into chat. The file is the output.

---

## What refine is NOT for

- **Full rewrites:** if more than 60% of the document needs to change, use `arch-doc` again with the same topic to regenerate from scratch.
- **New research:** if the annotation is "梳理 X 的完整流程" without existing content to build on, that is a new section requiring `arch-doc` subagent research, not a refinement.
- **Code changes:** refine only modifies documentation files. If an annotation implies a code fix, note it and skip it.
