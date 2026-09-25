# 校园资产研究

核查：2026-09-25。标记：VERIFIED=直接证据；LIKELY=有依据的推断；UNVERIFIED=尚未验证；NOT_FOUND=在列明范围未找到。访问失败单列，不能写成“资产不存在”。以下为摘要，文件级证据见 [恢复记录](VIRTUAL_CAMPUS_RECOVERY.md) 与 [机器目录](asset_catalog.json)。

## 1. Existing Asset Map

| 项目 | 已证实内容 | 当前用途 |
|---|---|---|
| [virtual-campus-v2](https://github.com/newbie-at-cuhksz/virtual-campus-v2) | VERIFIED：2021 年 Blender/Magicavoxel/Unity 校园资产，分支与历史仍可恢复 | LICENSE_UNCLEAR；研究副本，不进入发布资产 |
| [CUHK(SZ) Metaverse，学校报道](https://cuhk.edu.cn/zh-hans/article/6912) | VERIFIED：蔡玮团队的 2021 年校园多人原型；学生参与实地比对和 low-poly 建模、网络同步 | CONTACTABLE；参考校园风格与工作流 |
| [Metaverse for Social Good](https://sizheng-fan.github.io/publication/2021_MM/metaverse.pdf) | VERIFIED：Duan/Li/Fan/Lin/Wu/Cai，ACM MM 2021，Unity 原型、第一/第三人称与数字经济设计 | REFERENCE_ONLY；论文公开不是资产许可 |
| [Newbie at CUHKSZ](https://mypage.cuhk.edu.cn/academics/caiwei/paper/papers/HaoWSDC2023.pdf) | VERIFIED：Wu/Sun/Duan/Cai，ICCE 2023，体素迎新解谜、校园人物与传统 | REFERENCE_ONLY；与 Metaverse 有关联，但不可断言所有源码/模型版本相同 |
| [NAIS Lab](https://naislab.cn/) | VERIFIED：王方鑫团队页面列出 3DGS Campus，使用扫描和无人机数据展示校园 | CONTACTABLE；mesh、下载许可、完整覆盖范围 UNVERIFIED |
| [GauU-Scene](https://saliteta.github.io/CUHKSZ_SMBU/) | VERIFIED：Xiong/Zheng/Liu/Li，2024 数据集，有上下园航拍、LiDAR/PLY、COLMAP 与公开项目页 | 需申请许可；不能把它自动归属 NAIS 的同一项目 |
| [官方 720°校园全景](https://campusvr.cuhk.edu.cn/) | VERIFIED：官方全景入口存在；本机 TLS handshake 失败，网络阅读器也超时 | REFERENCE_ONLY；场景图与节点坐标 UNVERIFIED |
| [建筑师项目页](https://wwjarch.com/The-Chinese-University-of-Hong-Kong-Shenzhen-Phase-ll) | VERIFIED：山水、院落、连廊、平台的空间设计描述与项目照片 | REFERENCE_ONLY；没有公开 BIM/游戏模型许可 |

### NAIS 与测绘数据的区别

NAIS 的公开负责人为 Fangxin Wang，邮箱 `wangfangxin@cuhk.edu.cn`，隶属 SSE/FNii。网页证实存在校园 3DGS 展示，但未证实采集年份、操作者、设备型号、厘米精度、建筑清单或授权下载入口。当前页面直连遇证书过期，未绕过证书校验；搜索索引可读取项目简介。以上缺项均 **UNVERIFIED**，不从实验室成员名单猜项目成员。

GauU-Scene 是另一条可核实的数据线索：作者页记载 Matrice 300 + Zenmuse L1、上下园 RGB 与点云、坐标 EPSG:32650，点云密度约 20 cm/point；“密度”不是“测量精度”。页面列的上下园原始数据合计约 26 GB，不是可直接加载的游戏资产包。下载流程要求先取得许可再联系作者；表单本次阅读返回 401，未提交。网站代码许可不能替代数据许可。

### 全景与官方参考覆盖

[官方招生说明](https://admissions.cuhk.edu.cn/node/909) 确认上园生活区、中园绿化/神仙湖与上下园连接、下园教学与公共设施。不能把正在建设的“神仙湖校园”医学院项目等同于既有神仙湖步行区。

[一期图集](https://10.cuhk.edu.cn/phase-i-campus) 有上下园、书院、教学楼、体育馆；[启动区图集](https://10.cuhk.edu.cn/start-zone) 有道远、知新、志仁/诚道；[二期图集](https://10.cuhk.edu.cn/phase-ii-campus) 有教学、会议、科研与运动建筑。图集可供立面/体量参考，不能直接当贴图。

旧仓库 [Issue #2](https://github.com/newbie-at-cuhksz/virtual-campus-v2/issues/2) 留有 [720yun 导览](https://720yun.com/t/b2vkuqqer8b?scene_id=42010961) 和 [照片文件夹](https://drive.google.com/drive/folders/1fJrTygVDeB0aG-kCSMYE5aX25NWVKtfI)。原 URL 的 `42010961` 已不在当前返回配置内。后续直接读取 720yun 公共 HTML 成功，提取 **294 个场景节点、445 条跳转边**，作者显示“视拓三维”；保存于 `campus_reference_graph.json`。已核实航拍、上下园、图书馆、会议楼、室内场所与神仙湖节点。热点 `ath/atv` 是图像内角度，不是地理方位；跳转不是步行通路。经纬度和真实可通行图仍 **UNVERIFIED**。未批量抓全景瓦片或将照片纳入工程。

## 2. Reusability

| 类型 | 能提供什么 | 到可玩场景还缺什么 | 结论 |
|---|---|---|---|
| 旧 low-poly Blender | 建筑体量、现成网格 | 权属清理、单位/朝向、材料烘焙、减面、碰撞、语义 | CONVERTIBLE（以授权为前提），目前 LICENSE_UNCLEAR |
| Unity scene/prefab | 物件组合、位置参考 | Unity 组件不可直接视为 Godot 行为；商业依赖逐项核查 | REFERENCE_ONLY |
| 3DGS | 外观/空间感、视点参考 | 非水密网格，无可靠碰撞/导航/交互对象；需重建 | REFERENCE_ONLY |
| LiDAR PLY | 尺度、地形、高程 | 坐标变换、地面分割、重建/重拓扑、遮挡补全 | CONVERTIBLE，成本高且需授权 |
| COLMAP | 相机位姿与重建对齐 | 坐标/尺度校准，不能直接作为道路导航图 | REFERENCE_ONLY |
| 航拍高模/BIM | 屋顶/建筑形体 | 面数、材质、室内删减、可达空间重设计 | 当前未取得具许可资产 |
| 原创模块 | 直接可控的几何与行为 | 通过视觉/性能/导航验收 | DIRECTLY_USABLE |

## 3. Use For World

- **高桌晚宴区**：从连廊、庭院、玻璃门厅及正式聚会照片提取空间语言，用原创模块实现，不宣称复刻某一真实宴会厅。
- **神仙湖**：作为上下园之间的地标、风景路线和未来事件点；先收集岸线/出入口/路面坡度参考，不能用航拍屋顶数据推断步行通路。
- **上下园**：旧上园/教学建筑模型值得申请许可；先建立区域图，再逐区制作，避免一次导入整校园。
- **道路与公交站**：旧仓库有站棚、路障文件；模型不能提供班次或真实站点名称，时刻表需要另行核实。
- **教学区**：旧 TA/TBCD/启动区单体可能适合重拓扑统一风格，获授权后逐栋验收。

## 4. Recovery & Search Coverage

Git 全分支、历史删除文件、LFS、issues/comments、forks、tags/releases/PRs 已检查。检索还覆盖 GitHub、GitLab/Gitee、Bilibili/YouTube、学校/SSE/FNii、建筑师与论文页面，关键词包括中英文“港中深虚拟校园/元宇宙/数字孪生/建模/点云/BIM/3DGS/新手村”。在这些检索中 **NOT_FOUND**：具有明确可再分发许可、可直接导入 Godot 的完整校园包。公共微信文章及毕业设计未找到可验证授权下载，不能据此断言不存在私人留档。

恢复优先级：旧 `model_combine` 建筑 → 作者权属清单 → 单体试转 glTF → 真实可达性验收。NAIS/GauU 用于空间参考，不作为本轮依赖。研究已获得可恢复文件，因此不继续无界搜索拖延实现。

## 5. Strategy

本轮选择原创一致风格的 low-poly 模块；恢复副本隔离在 `.tools/`。区域语义、碰撞和交互与视觉同时制作。细节见 [资产策略](WORLD_ASSET_STRATEGY.md)、[来源台账](ASSET_PROVENANCE.md) 和 [扩展计划](WORLD_EXPANSION_PLAN.md)。
