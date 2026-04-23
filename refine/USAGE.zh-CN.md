# /refine 使用说明

## 是什么

`/refine` 是一个批注驱动的文档迭代 skill。在 Markdown 文档中用 `<!-- -->` 留下修改意见，然后执行 `/refine`，它会逐条处理所有批注、更新文档、删除已处理的批注。

**核心理念：文档是沟通载体，批注是指令，refine 是执行者。**

---

## 批注格式

```
<!-- TAG: 内容 -->
```

### 标签速查

| Tag | 含义 | 示例 |
|-----|------|------|
| `ADD` | 补充缺失内容 | `<!-- ADD: 缺少错误处理的描述 -->` |
| `FIX` | 修正错误 | `<!-- FIX: 返回值类型写错了，应该是 []string -->` |
| `DEL` | 删除过时/无关内容 | `<!-- DEL: 这段已经不适用 -->` |
| `ASK` | 存疑，需讨论再决定 | `<!-- ASK: 这里用 Redis 还是本地缓存？ -->` |
| `SPLIT` | 拆分段落/章节 | `<!-- SPLIT: 这节太长，按模块拆开 -->` |
| `TERM` | 术语统一 | `<!-- TERM: "同步任务" 全文改为 "翻译同步" -->` |

不加标签也可以，refine 会自动判断类型，但加标签更精准。

---

## 完整示例

假设有一份 `.tasks/feat-cache/todo.md`：

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

执行：
```
/refine .tasks/feat-cache/todo.md
```

refine 会：
1. 扫描出 4 条批注，列出清单
2. 逐条处理：删除过时段落、修正数据流、补充失效策略（可能读代码）、弹窗询问 Grafana 问题
3. 删除所有 `<!-- -->` 批注
4. 版本号 v1 → v2，更新日期

---

## 工作流

```
Claude 生成文档（research.md / todo.md）
         │
         ▼
阅读文档，插入 <!-- TAG: 意见 -->
         │
         ▼
执行：/refine <文件路径>
         │
         ▼
refine 处理 → 文档更新 → 版本 +1
         │
         ▼
再次阅读 ──→ 满意？──→ 进入实现
         │
         ▼ 不满意
继续加 <!-- --> → 再 /refine
```

---

## 常见用法

### 审查计划（todo.md）

```
<!-- DEL: step 3 is over-engineered, remove -->
<!-- ADD: missing database migration step -->
<!-- FIX: wrong order — create table before writing logic -->
```

### 审查调研（research.md）

```
<!-- ADD: missing webhook callback mechanism -->
<!-- FIX: this function signature is outdated, verify in code -->
<!-- ASK: does this conflict with the existing job scheduler? -->
```

### 优化架构文档

```
<!-- SPLIT: this section mixes three modules, separate by responsibility -->
<!-- TERM: "sync job" and "translation task" used interchangeably, unify -->
```

---

## 注意事项

- **一条批注 = 一个改动**，不要把多个意见塞进一条里
- `ASK` 批注会弹窗询问，确认后才会修改
- 超过 60% 的文档需要改 → 应该重新生成而不是 refine
- refine 只改文档，不改代码；如果批注暗示需要改代码，会跳过并提示
