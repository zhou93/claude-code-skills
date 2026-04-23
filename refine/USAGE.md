# /refine Usage Guide

## What it does

`/refine` processes `<!-- -->` annotations in a Markdown document — applying each edit, removing the annotation, and bumping the version. The document is the communication medium, annotations are instructions, refine is the executor.

---

## Annotation format

```
<!-- TAG: your note here -->
```

### Tag reference

| Tag | Meaning | Example |
|-----|---------|---------|
| `ADD` | Add missing content | `<!-- ADD: missing error handling section -->` |
| `FIX` | Fix an error | `<!-- FIX: return type should be []string -->` |
| `DEL` | Remove outdated content | `<!-- DEL: no longer applicable -->` |
| `ASK` | Needs discussion first | `<!-- ASK: Redis or local cache here? -->` |
| `SPLIT` | Split a section | `<!-- SPLIT: too long, break by module -->` |
| `TERM` | Unify terminology | `<!-- TERM: rename "sync task" to "translation sync" globally -->` |

Untagged annotations also work — refine will auto-classify — but tags are more precise.

---

## Example

Given `.tasks/feat-cache/todo.md`:

```markdown
# Cache optimization plan v1 (draft)

## 1. Architecture

Currently using local cache + Redis dual-layer.
<!-- DEL: switched to pure Redis, this is outdated -->

## 2. Data flow

Request → API Gateway → Logic → DAO → DB
<!-- FIX: missing Redis cache layer between Logic and DAO -->

## 3. Invalidation

<!-- ADD: document TTL strategy and active invalidation triggers -->

## 4. Monitoring

Using Prometheus for cache hit rate.
<!-- ASK: should we add Grafana alerting? -->
```

Run:
```
/refine .tasks/feat-cache/todo.md
```

Refine will:
1. Scan and list 4 annotations
2. Process each: remove outdated section, fix data flow, add invalidation content (may read code), ask about Grafana
3. Remove all `<!-- -->` annotations
4. Bump version: v1 → v2

---

## Workflow

```
Claude generates document (research.md / todo.md)
         │
         ▼
You read, insert <!-- TAG: note --> where needed
         │
         ▼
Run: /refine <file-path>
         │
         ▼
Refine processes → document updated → version +1
         │
         ▼
You review again ──→ satisfied? ──→ start implementation
         │
         ▼ not yet
Add more <!-- --> → /refine again
```

---

## Common patterns

**Reviewing a plan (todo.md):**
```
<!-- DEL: step 3 is over-engineered, remove -->
<!-- ADD: missing database migration step -->
<!-- FIX: wrong order — create table before writing logic -->
```

**Reviewing research (research.md):**
```
<!-- ADD: missing webhook callback mechanism -->
<!-- FIX: this function signature is outdated, verify in code -->
<!-- ASK: does this conflict with the existing job scheduler? -->
```

**Improving architecture docs:**
```
<!-- SPLIT: this section mixes three modules, separate by responsibility -->
<!-- TERM: "sync job" and "translation task" used interchangeably, unify -->
```

---

## Rules of thumb

- **One annotation = one change.** Don't pack multiple requests into a single `<!-- -->`.
- **`ASK` pauses for input.** Refine will prompt you before making any edit.
- **>60% changes = regenerate.** If most of the document is wrong, start fresh instead.
- **Documents only.** If an annotation implies a code change, refine will skip it and flag it in the output.
