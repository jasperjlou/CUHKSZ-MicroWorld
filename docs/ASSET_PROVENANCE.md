# 资产来源与使用边界

最近核查：2026-09-26。正式游戏未导入第三方校园模型、扫描数据、航拍或全景贴图。下方 V0.6 记录保留当时状态；新实拍及纹理变更见 V0.6.5。

V0.7 神仙湖新增资产全部由 `FairyLakeBuilder.gd` 原创基础几何生成，复用项目字体、材质辅助与人物。局部构图观察来源为 VR_42078153、VR_42078154、LAKE_06、LAKE_09；没有下载并复制全景瓦片或照片纹理进入游戏。外观参考与具体坐标、尺寸、高差的证据分离记录，详见 `V07_SPATIAL_SLICE.md`。长椅、灯具、远处无名建筑与候车点为占位，不宣称准确现场资产。

| 资产 | 来源/作者 | 许可或依据 | 修改 | 随项目再分发 | 研究演示 |
|---|---|---|---|---|---|
| CampusBuilder / CampusLife 几何、人物、道具 | 本项目原创程序化模型 | 本次用户委托实现；未复制第三方网格 | 可 | 项目自产；尚未额外指定对外开源许可证 | 可 |
| 字体 NotoSansSC | 原项目 assets/fonts/OFL.txt | SIL Open Font License，保留许可证 | 按 OFL | 按 OFL | 可 |
| SoundCues 合成音效 | 原项目程序生成 | 本项目自产，无第三方采样 | 可 | 同工程 | 可 |
| virtual-campus-v2 建筑/树/人物 | 原学生团队及可能混合第三方商店资产 | **LICENSE_UNCLEAR**；仓库无整体 LICENSE，第三方依赖不能统一授权 | 未取得 | 未取得 | 未取得 |
| 官方 VR/720yun/照片 | 大学/拍摄者/平台，具体权利人待确认 | **REFERENCE_ONLY**；公开访问不是复制许可 | 未取得 | 未取得 | 仅引用来源链接 |
| NAIS 3DGS | NAIS Lab，具体采集团队未确认 | **LICENSE_UNCLEAR** | 未取得 | 未取得 | 需询问 |
| GauU-Scene 数据 | 作者团队，按申请流程 | 数据使用条款未取得，网站模板许可不适用于数据 | 未取得 | 未取得 | 需申请 |
| 建筑师照片/图纸 | Wang Weijen Architecture 等 | 版权所有，参考形体/空间组织 | 不复制源文件 | 不允许据网页推定 | 引用链接 |

V0.6 木牌仅保留竖排 `走路不看手机` 六字，删除旧版附加文案。当时无可用实拍，木纹与手写笔画由内置 imagegen 按文字规格生成，保存为 `assets/signs/walk_without_phone.png`。V0.6.5 收到实拍后改用下述新纹理。两个版本均不声称逐笔复原。晚宴时间、路线、海报、门厅均为玩法设计，不是现实活动通知。角色为虚构人物。

每次未来导入必须补齐 owner/source URL/version/hash/license/modify/redistribute/research-demo permission，再记入 `asset_catalog.json`。当许可缺失时保持 `imported=false`。研究恢复目录受 `.gitignore` 排除；不得将整个 Unity 资源目录打包进游戏。


## V0.6 资产与证据边界

- 新建 CampusIdentity 的墙柱、顶棚、纸张、导视、坡道、路段与站牌均为本项目原创几何。
- 木牌生成纹理没有第三方照片输入；正式游戏依赖全部在仓库内，不依赖 Codex 生成目录。
- 招募被试、注意力实验、TIDE、计算机与哲学、本科科研、高桌晚宴及三张小通知，文案由本轮用户直接指定。全部是虚构场景道具；装饰二维码不编码任何报名网址。没有伪造 CMU 官方招生通知。
- 实体海报与导视按 V0.6 要求中英双语；HUD、交互、对白、演示说明与结尾继续简体中文。
- `legacy_geometry_audit.json` 只记录旧 DAE 的对象名称、数值包围盒、顶点数量、变换矩阵和哈希，不包含网格、纹理或点云。旧 Blender、LFS 与 DAE 文件仍只在忽略的 `.tools/research/` 内。
- SoundCues 新增轻微合成风/室内基音。不是校园实录，也未使用第三方声音。

## V0.6.5 实拍参考更新（2026-09-26）

- USER_PLAQUE_001 为本轮新收到的用户实拍，原始字节与哈希保存在 references/user/originals/；具体摄影者与地点未知。
- 当前游戏使用 assets/signs/walk_without_phone_reference.png：内置 imagegen 依据实拍重新绘制的红褐木底/绿色六字纹理，不是原照裁切、逐笔复制或第三方模型。旧描述版保留历史文件，但已不被场景加载。派生哈希与依据见 references/user/plaque_analysis.json。
- 本轮新增顶板、铺地和板体仍为程序化原创几何，尺寸为游戏近似。正式运行依赖不读取 references/。
- 31条主资料、294条VR元数据均保留许可未知状态；19个研究原件被Git和Godot排除。主库参考可观察与原件可复制的权限独立。原照未进入游戏或发布包。
- 新来源入口：docs/REFERENCE_INDEX.md。旧模型专项审计覆盖4份DAE/123实例，输出的是数值分析，不是可导入游戏的网格。
