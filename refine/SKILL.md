---
name: refine
description: >
  Process <!-- TAG: note --> annotations in a Markdown document: apply targeted
  edits, remove processed annotations, bump the version. Supports tags ADD, FIX,
  DEL, ASK, SPLIT, TERM. Not for full rewrites.
version: 2.0.0
user_invocable: true
---

# refine: Annotation-Driven Document Refinement

One annotation = one focused edit. No full rewrites.

**Contract:** every `<!-- ... -->` block is a directive. When this skill exits, all annotations are gone and every directive has been acted on.

## Invocation

```
/refine [file-path]
```

**File resolution:** explicit path > most recently modified `.md` in conversation > ask user.

---

## Phase 1: Inventory

Read the target file. Extract every `<!-- ... -->` block with line number, parent heading, and tag.

**Preferred annotation format:** `<!-- TAG: content -->`

| Tag | Meaning | Edit behavior |
|-----|---------|---------------|
| `ADD` | Missing content | Insert new content at or after the annotation |
| `FIX` | Error in text/diagram/logic | Correct the specific error; don't touch surrounding content |
| `DEL` | Outdated or irrelevant | Remove the content; confirm with user only if scope is ambiguous |
| `ASK` | Needs discussion first | Do NOT edit — use `AskUserQuestion`, then apply based on answer |
| `SPLIT` | Section too large or mixed | Split or restructure as indicated |
| `TERM` | Naming inconsistency | Find and replace the term across the entire document |
| _(none)_ | Untagged | Auto-classify as best-fit tag above, or as `layout` / `clarify` |

Print the inventory table before processing. Zero annotations → report and exit.

**Determine processing order:** if annotation N depends on the result of M, process M first. List reordering if needed.

---

## Phase 2: Process Annotations

For each annotation, in order:

**A. Understand intent.** Read annotation + surrounding 10-20 lines. Ambiguous + high-impact → `AskUserQuestion`. Minor ambiguity → pick most likely interpretation, note it.

**B. Gather information (if needed).** Only for `ADD` annotations that reference codebase features:
- `Grep` / `Read` / `Glob` — read only what this annotation requires

**C. Apply the edit.** Use `Edit`, following the tag's edit behavior from the table above.

**D. Remove the annotation.** Delete the `<!-- -->` block. Partial fix → replace with a new annotation describing what remains.

### Diagram edits

When an annotation targets a diagram:

| Intent | Action |
|--------|--------|
| Too complex / too many nodes | Split at a natural boundary, or replace with a table |
| Wrong arrows / connections | Fix only the specific edges mentioned |
| Convert format (Mermaid, ASCII, table) | Convert; preserve all information |
| Text overlapping / hidden | Move prose above the code block, or switch to table |

Constraint: each Mermaid block ≤ 300 tokens. Split if exceeded.

---

## Phase 3: Finalize

**Version bump:** increment the version number in the document header or frontmatter. Update the date to today.

- Annotations remain or were added → append `(draft)` to version
- All annotations resolved → clean version number

**Verify:**
- [ ] Zero `<!-- -->` blocks remain (except new ones added this session)
- [ ] No broken Mermaid syntax
- [ ] No orphaned headings (heading with no content)
- [ ] No content accidentally deleted outside annotated regions

---

## Output

Report in chat:

```
Processed 4 annotations:
· [ADD]   §1.1 — added C4 L1 diagram (read src/envs/app.ts)
· [FIX]   §2.1 — corrected data flow arrow direction
· [DEL]   §1.2 — removed outdated local cache description
· [TERM]  all  — "local market" → "owned market" (6 occurrences)

Document: .tasks/feat-x/research.md → v6
```

Do not paste modified sections into chat. The file is the output.

---

## Boundaries

- **Full rewrites:** if >60% of the document needs to change, regenerate from scratch instead.
- **New research:** annotations like "map out the full flow of X" with no existing content to build on require research, not refinement.
- **Code changes:** refine only modifies documents. If an annotation implies a code fix, note it in output and skip.
