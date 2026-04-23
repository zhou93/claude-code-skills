# claude-code-skills

> 适用于 [Claude Code](https://code.claude.com) 的全局 Skill 集合。

[English](./README.md) | [中文](./README.zh-CN.md)

---

## Skill 列表

### arch-doc

对任意功能域进行架构分析，自动生成结构化、图表丰富的架构文档。

- [x] 并行启动 4 个子 Agent，按层分工研究（数据层 / 服务层 / 客户端 / 运行时）
- [x] 输出 C4 L1 系统边界图 + 分层架构图 + 交互时序图
- [x] 智能选择图表格式（Mermaid / 表格 / ASCII，按场景决定，不强制套用）
- [x] 每图限制 ≤ 300 token，防止图表失控
- [x] 输出带版本号的文档，方便人工批注后迭代
- [x] 输出路径按项目约定解析：prompt 显式指定 → CLAUDE.md 配置 → 交互询问
- [x] 适用于任意功能域：`skill-agent`、`auth`、`chat-runtime`、`file-storage` 等

### refine

处理任意 Markdown 文档中的 `<!-- TAG: 批注 -->` 并定向修改，无需从头重写。

- [x] 支持 6 种标签：`ADD`、`FIX`、`DEL`、`ASK`、`SPLIT`、`TERM`，无标签时自动分类
- [x] `ASK` 标签会暂停并询问用户确认后再修改
- [x] 按批注类型判断是否需要读代码库
- [x] 逐条处理，每条处理完后删除批注
- [x] 自动更新文档版本号和日期
- [x] 适用于任何 Markdown 文件：架构文档、任务计划、工作流文档、研究笔记等
- [x] 包含[使用说明](refine/USAGE.zh-CN.md)

---

## 安装

### 一键安装（推荐）

```bash
git clone https://github.com/zhou93/claude-code-skills.git
cd claude-code-skills
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
# 生成架构文档
arch-doc skill-agent                   # 不指定路径 → 读 CLAUDE.md 或交互询问
arch-doc auth doc/arch/               # 显式指定输出目录
arch-doc chat-runtime

# 处理当前对话中最近文档的批注
refine

# 指定文件处理批注
refine tasks/skill-agent/research.md
refine .tasks/fix-auth/todo.md
```

### 工作流

```
arch-doc <topic> [目录]   生成文档，标注 v1 待批注
       ↓
在文档中写 <!-- 批注 -->
       ↓
refine                    处理批注，更新到 v2
       ↓
继续批注 → refine → v3 → ...
```

---

## 为什么做这两个 Skill

[anthropics/skills](https://github.com/anthropics/skills) 官方仓库中，架构文档生成这个方向是空白。这两个 Skill 的核心差异化：

1. **批注驱动的迭代循环** — 人工批注 → AI 定向修改。Archyl、Swimm、Mintlify 等现有工具均未以文件形式实现这一工作流。
2. **运行时行为覆盖** — 不只做静态分析，包含对话时序、工具调用路由、执行器分发链路等运行时流程文档。
3. **图表选择规则** — 明确约定何时用 Mermaid、何时用表格、何时用 ASCII，不强制套用单一格式。

---

## License

MIT
