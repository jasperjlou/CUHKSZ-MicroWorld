# 资产来源与使用边界

核查日：2026-09-25。本轮正式游戏未导入第三方校园模型、扫描数据、航拍或全景贴图。

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

`走路不看手机／抬头看路，也看看港中深。` 是为本游戏创作的校园幽默标牌，**不是学校真实告示的记录**。晚宴时间、路线、海报、门厅均为玩法设计，不是现实活动通知。角色为虚构人物。

每次未来导入必须补齐 owner/source URL/version/hash/license/modify/redistribute/research-demo permission，再记入 `asset_catalog.json`。当许可缺失时保持 `imported=false`。研究恢复目录受 `.gitignore` 排除；不得将整个 Unity 资源目录打包进游戏。
