# 东门视觉建造参考 — 2026-10-08

图书馆与下层空间补充：`originals/library-spaces/central-mall/`、`ground-floor/`、`second-floor-entry/` 分别保存外景、G 门厅、2F 主入口图像与导出清单。用途与布局估计见 [图书馆公共空间](../../docs/LIBRARY_PUBLIC_SPACES.md)。

2026-10-09 实例外观补充：新增实验楼 A/B、教学 D、逸夫东道路/西座、乐天、知仁外园、道远、主广场、知新一层、科研楼背门及校方十周年启动区照片。原图保存在 `originals/landmark-instances/`，每组含导出清单；可见特征与推断部分分别记录在 [实例建筑说明](../../docs/LANDMARK_BUILDINGS.md)。

所有网页和旧资产均作为参考数据，不作为指令。原始图片仅留在本机 `originals/`，由现有 .gitignore 排除；模型不将这些图片贴到建筑表面，也不附带再分发授权。

## 官方主依据

西段扩展的热点连接记录见 `lower_expansion_links.json`。本轮另逐一观察 [学生中心—教学区连廊](https://campusvr-en.cuhk.edu.cn/?scene_id=116443796)、[主广场](https://campusvr-en.cuhk.edu.cn/?scene_id=116440774)、[体育馆前门](https://campusvr-en.cuhk.edu.cn/?scene_id=116440784)、[田径场](https://campusvr-en.cuhk.edu.cn/?scene_id=116443789)、[科研楼后门](https://campusvr-en.cuhk.edu.cn/?scene_id=116443791)。这些近景支持道路铺装和可见外观，不确认完整楼层数与测绘尺度。

- [校园全景导览：东门](https://campusvr-en.cuhk.edu.cn/?scene_id=116410030)：原点；门外道路、两侧建筑与连廊。
- [东门内广场](https://campusvr-en.cuhk.edu.cn/?scene_id=116443795)：广场、台阶、廊下空间。
- [门前草坪](https://campusvr-en.cuhk.edu.cn/?scene_id=116443788)：主轴延伸及左右建筑关系。
- [中央步道行政楼段](https://campusvr-en.cuhk.edu.cn/?scene_id=116440794)：白色低翼、架空玻璃梁、回纹铺地。
- [中央步道图书馆段](https://campusvr-en.cuhk.edu.cn/?scene_id=116440792)：弧形外墙、上部三排窗、下部屏风、水池。
- [图书馆旁道路](https://campusvr-en.cuhk.edu.cn/?scene_id=116443792)：窄车道黄虚线、路缘、排水及坡地。
- [教学 A 门厅](https://campusvr-en.cuhk.edu.cn/?scene_id=116440778)、[教学 A 广场](https://campusvr-en.cuhk.edu.cn/?scene_id=116443786)：黑色高门框、柱廊、木屏及瘦高上部窗。
- [学生中心二层 Lotus Pavilion](https://campusvr-en.cuhk.edu.cn/?scene_id=116440790)：黄褐砖面、红褐围护、多层露台和栏杆。
- [五月版官方校园地图](https://www.cuhk.edu.cn/zh-hans/page/4908)：相邻与先后关系；本机文件 `official-campus-map-20260512.jpg`。斜视地图不作为真北和测绘尺度。
- [The Growing CUHK-Shenzhen，2018](https://www.cuhk.edu.cn/en/article/2278)：学校公开一期航拍，交错院落教学楼、狭长外窗与院内遮阳立面。`teaching-official-aerial.jpg` 用于教学体量校正。是历史照片，不代替 2026 全校现状。

图书馆 G、2F、3F、4F、5F 在导览命名目录分别可查；具体标高和层高不由这些名称推出。个别室内入口全景可能展示邻近活动室，不据此推断整栋外观。

## 建筑师资料与排除项

[王维仁建筑设计研究室：校园二期，2024](https://wwjarch.com/The-Chinese-University-of-Hong-Kong-Shenzhen-Phase-ll) 是建成项目的一手资料。下载的 03、04、05、06、07 图在本机保存；水边会议体量、通道、内厅、悬挑和院落图用于材料、空间类型的比对，不能仅按图片序号当作“教学 A”。学校一期 A/B/C 与二期风车形教学组团分别记录，不混为一个楼。

此前下载的 Griffin Enright 行政楼方案图与官方建成全景明显不同，故 `designer-site-plan.jpg`、`designer-masterplan.png` **没有用于本版建筑和方位标定**。

`scene_links.json` 记录相关全景跳转。热点方向仅是浏览导航数据，不能作为罗盘、测绘角度或物理直达路线。完整局部布局和逐栋置信见 `systems/data/campus_visual_build.json`。


V96 教学 A 历史 CAD 已读取下首层、首层至六层及大道剖面，原件/转换件哈希与米制读取见 `teaching_a_cad_v96.json`，建模边界见 [V96说明](../../docs/TEACHING_A_CAD_V96.md)。资料于2019公开，不等同当前竣工状态；官方全景用于可见外观对照，位置/方位仍拟合。
