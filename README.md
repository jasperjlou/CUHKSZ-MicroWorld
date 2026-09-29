# CUHKSZ MicroWorld

基于香港中文大学（深圳）校园环境构建的 **interactive campus world / Agent environment**。
使用风格化、低多边形场景，探索校园行走、互动、限时任务与交通决策。

目标不是精确的 GIS / BIM digital twin，而是：

- **Visual resemblance**：具有可辨认的校园外观。
- **Spatial plausibility**：合理、连续、可行走的空间。
- **Semantic navigation**：可供 Agent 使用的语义地点与路径。
- **Agent interaction**：动作、观察和世界反馈。
- **Time-aware tasks**：受世界时间和事件状态影响的任务。
- **Transport decisions**：步行、候车、上车与重新规划。
- **Reproducible evaluation**：可记录、可检查的轨迹与任务结果。

## 当前状态

文档基线：**V1.0 Phase D2**。

本次提交保留本地现状：此前开发已加入 evidence-aware D2 连通与 Phase E 岔路分支，
`project.godot` 实际版本为 **`1.0.0-phase-e`**。此处区分基线与现有代码，不代表
完整校园已建成；仓库整理没有改动游戏逻辑、物理配置或地图。

当前包含：

- Fairy Lake spatial slice 与 continuous connector corridor。
- World Time、Campus Event System。
- Shuttle prototype：wait / board / continue walking / replanning。
- Agent observation、semantic navigation、trajectory logging。
- Confidence-aware spatial reconstruction。
- 湖口至第一岔路的推断连接，以及上园、下园、道扬书院、其他区域的有限方向支路。
- 原高桌晚宴场景：手机、老师提醒、帮助同学拍照与任务核验。

支路方向和门楼位置含推断/占位，不表示已经走到真实上下园或书院内部。
接驳班次和车程是原型设定。自动路线测试与模拟模型结果不等于独立真人实验或真实模型成绩。

## 技术栈

| 项目 | 当前实现 |
|---|---|
| 引擎 | Godot **4.5.1** |
| 3D physics | **GodotPhysics3D**，沿用 Godot 4.5 默认后端；未启用 Jolt |
| 语言 | GDScript |
| 角色 | `CharacterBody3D` + `move_and_slide()` |
| 导航 | `AStar3D` 语义路点图；实际移动遵循角色碰撞 |
| 渲染 | GL Compatibility，stylized / low-poly |
| 玩家界面 | 简体中文；部分实体校园导视保留双语 |

## 运行

1. 安装 Godot **4.5.1**，导入本仓库的 `project.godot`。
2. 按 F5 运行，选择“漫步神仙湖”或原高桌晚宴玩法。
3. Windows 也可指定本机引擎路径：

```powershell
.\tools\Launch.ps1 -FairyLake -GodotPath 'C:\Tools\Godot_v4.5.1-stable_win64.exe'
```

WASD 移动，Shift 慢跑，E 互动，Esc 暂停；湖区 C 前后看、V 侧看、F1 查看
置信与调试信息。原晚宴场景使用 Tab 打开手机。游戏内有中文引导。

字体随仓库提供；`.tools/` 中的本机引擎不上传。运行游戏不需要原始照片、
官方全景、旧 GTA 资产或 API key。可选模型评测另见 [BENCHMARK.md](BENCHMARK.md)。

## Evidence / Reconstruction Philosophy

| 标记 | 含义 |
|---|---|
| `verified` | 对应事实有可靠实拍或明确资料支持 |
| `inferred` | 依据照片、地图、建筑相对关系和道路逻辑综合推理 |
| `placeholder` | 推理基础较弱、为当前可玩世界提供的临时实现 |

照片、官方地图、全景与旧模型用于参考。**不把未验证推断伪装成真实测绘数据**；
可确认某物体存在，不等于确认它在游戏中的坐标、尺寸或朝向。

采用 **evidence-aware inference**：资料不足时允许建立最合理的连续世界，
同时记录依据、置信等级和可替换性。`inferred` / `placeholder` geometry
可在获得更好资料后替换。2026 Campus Guide 用于大拓扑参考，不视作测量图。
旧模型不自动等于当前真实校园。

## 文档入口

- [PROJECT_STATE](docs/PROJECT_STATE.md)：当前快照与历史续接记录。
- [CAMPUS_SPATIAL_NOTES](docs/CAMPUS_SPATIAL_NOTES.md)：空间依据与近似边界。
- [V0.7 Fairy Lake](docs/V07_SPATIAL_SLICE.md)。
- [V0.8 World Time / Event](docs/V08_WORLD_TIME_EVENT.md)。
- [V0.9 Shuttle / Route Choice](docs/V09_SHUTTLE_ROUTE_CHOICE.md)。
- V1.0 [Phase A](docs/V10_CAMPUS_JOURNEY.md) · [B](docs/V10_PHASE_B_CONNECTOR.md)
  · [C](docs/V10_PHASE_C_CONNECTOR_RESOLUTION.md) · [D](docs/V10_PHASE_D_GROUND_EVIDENCE_BRIDGE.md)
  · [D2](docs/V10_PHASE_D2_GAP_CLOSURE.md)。
- [现有 D2 / E 建设清单](references/regions/fairy_lake/phase_e_construction.json)。
- [Asset catalog](docs/asset_catalog.json) · [运行资产目录](assets/campus/environment_catalog.json)
  · [Asset provenance](docs/ASSET_PROVENANCE.md)。
- [Reference notes 与本地资料获取](references/README.md) · [Reference index](docs/REFERENCE_INDEX.md)。
- [QA 历史记录](QA.md) · [Git 提交范围](docs/REPOSITORY_CONTENTS.md)
  · [原 README 归档](docs/LEGACY_README.md)。

旧阶段文档按当时状态保留；其中的冻结/停止建设规则不覆盖上述新原则。

## 测试

使用自己安装的 Godot 命令行程序，例如：

```powershell
godot --headless --path . --fixed-fps 60 -- --junction-qa
godot --headless --path . --fixed-fps 60 -- --agent-qa
```

其他入口包括 `--lake-qa`、`--connector-qa`、`--journey-qa`、`--event-qa`、
`--shuttle-qa`、`--qa`、`--polish-qa`。检查完成收据与失败数，不只看进程是否退出。
测试输出和截图写入被忽略的本地目录。完整 reference 校验需要另行取得本地原件，
不应将缺失原件误报为游戏无法运行。

## Asset / Copyright Notice

- 本仓库不默认包含所有原始参考图片和旧校园模型。
- 某些 reference assets 因版权、许可或体积原因仅保存在本地；原始官方图片、
  全景大图、未授权摄影资料、DAE 和大型二进制模型不上传。
- 仓库中的 metadata / notes **不代表对原始资料的再分发许可**。
- 约 **14.2 GB** 的旧 Virtual Campus / GTA 资产不提交、不复制进仓库、
  不使用 Git LFS 上传；仅保留 inventory、metadata、provenance 和 reuse decision。
- 旧资产只有在明确允许复用后才会单独进入正式版本。
- 字体保留其 [OFL notice](assets/fonts/OFL.txt)。生成纹理的来源与派生过程见
  [资产说明](docs/ASSET_PROVENANCE.md)；这不构成对整个项目的版权许可判断。

仓库根据所有者明确授权公开；公开可读不等于已授予开源或原始参考资料再分发许可。

**License pending / All rights reserved unless otherwise stated.**
尚未为整个项目确定许可证；各文件已有的独立许可声明仍予保留。
