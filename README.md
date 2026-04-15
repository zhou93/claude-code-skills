# claude-skills

> 适用于 [Claude Code](https://code.claude.com) 的全局 Skill 集合。

目前包含两个 Skill：

- **arch-doc** — 对任意功能域生成架构文档（C4 模型 + Mermaid + 时序图）
- **refine** — 处理 Markdown 文档中的 `<!-- 批注 -->` 并定向修改

---

## 功能

### arch-doc

- [x] 并行启动 4 个子 Agent，分层研究（数据 / 服务 / 客户端 / 运行时）
- [x] 输出 C4 L1 系统边界图 + 分层架构图 + 交互时序图
- [x] 智能选择图表格式（Mermaid / 表格 / ASCII，按场景决定）
- [x] 每图限制 ≤ 300 token，防止图表失控
- [x] 输出文档标注版本号，方便迭代
- [x] 支持任意功能域：`skill-agent`、`auth`、`chat-runtime` 等

### refine

- [x] 扫描文档中所有 `<!-- 批注 -->` 并分类（add-content / fix / layout / restructure 等）
- [x] 按批注类型智能决策是否需要读代码
- [x] 逐条处理，处理后删除批注
- [x] 自动更新文档版本号和日期
- [x] 适用于任何 Markdown 文档：架构文档、任务计划、流程文档等

---

## 安装

### 一键安装（推荐）

```bash
git clone https://github.com/zhou93/claude-skills.git
cd claude-skills
bash install.sh
```

### 手动安装

```bash
cp -r arch-doc ~/.claude/skills/
cp -r refine ~/.claude/skills/
```

安装后重启 Claude Code 即可使用。

---

## 使用方式

```bash
# 生成架构文档（输出到 tasks/<topic>/research.md）
arch-doc skill-agent
arch-doc auth
arch-doc chat-runtime

# 处理当前对话中最近文档的批注
refine

# 指定文件处理批注
refine tasks/skill-agent/research.md
refine .tasks/fix-auth/todo.md
```

### 工作流

```
arch-doc <topic>          生成文档，标注 v1 待批注
       ↓
在文档中写 <!-- 批注 -->
       ↓
refine                    处理批注，更新到 v2
       ↓
继续批注 → refine → v3 → ...
```

---

## 背景

业界目前没有可用的 Claude Code Skill 用于架构文档生成（[anthropics/skills](https://github.com/anthropics/skills) 官方仓库中这个方向是空白）。

这两个 Skill 的核心差异化：

1. **批注驱动的迭代循环** — 人工批注 → AI 定向修改，现有工具均未实现
2. **运行时行为覆盖** — 不只做静态分析，包含对话时序、工具调用链路等运行时流程
3. **图表选择规则** — 明确约定何时用 Mermaid、何时用表格、何时用 ASCII

---

## License

MIT
