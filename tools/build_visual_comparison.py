"""Local reference/model viewer. Links original source images; never repaints references."""
from pathlib import Path
from html import escape
root=Path(__file__).resolve().parents[1]
original='references/visual_build_20261008/originals/'
court=original+'central-courtyard-20261010/'
teaching=original+'teaching-public-spaces-20261010/'
site=original+'site-landscape-20261010/'
conference=original+'conference-centre-20261010/'
western=original+'western-campus-20261010/'
plan=original+'massing-plan-20261010/'
library_plan=original+'library-plan-20261010/'
start_zone=original+'landmark-instances/'
rocco='https://www.rocco.hk/?lang=en&view=projects,typology,featured-project&p=comprehensive-master-plan-and-phase-one-construction-of-the-chinese-university-of-hong-kong-shenzhen-campu'
panorama='https://campusvr-en.cuhk.edu.cn/?scene_id='
architect='https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ'
pairs=[
 ('v31：下园旧楼群排列修正',original+'official-campus-map-20260512.jpg','tests/artifacts/courtyard-refined-corridor-square-cluster.png','https://www.cuhk.edu.cn/zh-hans/page/4908',
  '诚道楼移到主广场山侧，与知仁楼形成前排；乐天楼在后侧。入口、庭院、服务路和导航点同步调整。导览图支持相邻关系，坐标米数和未见轮廓仍为拟合。'),
 ('v31：逸夫街角与连续步道',start_zone+'east-road/e81370978a0c09ff.jpg','tests/artifacts/courtyard-refined-corridor-shaw.png',panorama+'116443798',
  '补连续灰色块材铺装、树池和街灯，修正临街大实墙。路径由学生中心穿连廊接到逸夫，再折向主广场。具体路幅和曲线没有测绘配准。'),
 ('v31：科研楼下层悬挑',start_zone+'research/3f66bff99ec6e7e8.jpg','tests/artifacts/courtyard-refined-corridor-research-canopy.png',panorama+'116443791',
  '新增圆柱悬挑雨棚、水平分缝、梁底和铺地，接通到体育馆的步道。塔楼上半部仍沿用估计体量，不能据背门照片确认整楼高度。'),
 ('东门：白框成对窗与遮阳连桥',original+'east-gate-20261010/a9236392da79eb05.jpg','tests/artifacts/scope-review-east-gate-entry.png',panorama+'116410030',
  '两翼改成对白框窗；左侧到达面有窗，右侧到达面保留宽实墙，补不同材质的底层遮阳、连桥竖片及连续入口铺装。既有锚点和估计层高保留；照片机位、具体层数和窗组数量未测绘配准。'),
 ('逸夫西座：院落与背山边界',start_zone+'shaw-west/aca6809e91fdbdbf.jpg','tests/artifacts/shaw-hill-court.png',panorama+'116440787',
  '退开穿入楼底的草坡，补连续后侧地面、挡土墙、栏杆和种植。原图用于山侧边界关系；墙线、标高、道路走线和相机均不同，不能当作测绘配准。'),
 ('实验楼通道：实墙窄窗与横向玻璃带',start_zone+'labs/f5d6456371e1d237.jpg','tests/artifacts/research-detail-passage.png',panorama+'116697227',
  'A 楼改平滑浅墙，B 楼去掉误用的整面铜色竖片，补横向玻璃与深色遮阳板；通道换灰色长条地面。保留既有锚点，宽度、层高和跨廊位置仍为拟合。'),
 ('涂辉龙楼：道路侧悬挂遮阳',start_zone+'labs/2147002f506c512c.jpg','tests/artifacts/research-detail-tu-arcade.png',panorama+'116697227',
  '将铜色悬挂竖片放到面向景观的外廊，补支架、斜撑、条灯和贯通铺地。模型保留地面连续性；照片中的外缘栏杆和现场高差未据此逐段复刻。'),
 ('涂辉龙楼：窗鳍与退进平台',start_zone+'east-road/5ddf26ad59a7c61b.jpg','tests/artifacts/research-detail-tu-road.png',panorama+'116443797',
  '道路侧保留密竖向窗鳍，补两层退进平台；既有室外楼梯接入下层平台。平台尺度及凹口位置为拟合，未验证上层实验室内部。'),
 ('逸夫东座：深灰墙与白色百叶框',start_zone+'east-road/b1b49ff45838776e.jpg','tests/artifacts/shaw-east-detail-louver.png',panorama+'116443797',
  '修正原通用浅色石墙，采用深灰涂料、蓝灰玻璃及突出白框百叶。端面构件朝向已修正。照片支持构造特征，重复数量、具体尺寸和未见立面仍有推断。'),
 ('逸夫东座：门廊与公共前场',start_zone+'east-road/e776d587b1739b7f.jpg','tests/artifacts/shaw-east-detail-entry.png',panorama+'116443797',
  '补连续石铺前场、条灯、排水和玻璃门洞；两块实心底层改为可进入休憩空间，院内楼梯接齐公共连桥。照片展示道路侧材质与底层气质，不是新房间和连桥平面的直接证明。'),
 ('逸夫西座：凸窗框与错层露台',start_zone+'shaw-west/30d64af40d89a68c.jpg','tests/artifacts/shaw-west-detail-terraces.png',panorama+'116440787',
  '按官方近景细化白色凸窗框、窗下金属栏板、蓝灰玻璃、空调百叶和暖色两层露台；保留原楼高，窗距、露台位置与深度仍为模型拟合。'),
 ('逸夫西座：玻璃雨棚与公共底层',start_zone+'shaw-west/9297605c287b2efe.jpg','tests/artifacts/shaw-west-detail-entry.png',panorama+'116440787',
  '移除盖住院落的大屋盖，改成局部玻璃雨棚、连续铺装和室外楼梯。新休憩室及平台连接是适配当前模型的公共空间，不代表实测室内平面。'),
 ('中庭：三侧连廊、庭园与阶梯',court+'wwj-courtyard-aerial.jpg','tests/artifacts/courtyard-enclosure-whole.png',architect,
  '原两段 L 形廊补为三侧围合，并接入学生中心与图书馆；下层增加四组种植庭园和阶梯座席。整体机位、尺度不同，具体地下平面与采光顶尚未完整复原。'),
 ('中庭：下层玻璃廊与开放入口',court+'wwj-courtyard.jpg','tests/artifacts/courtyard-enclosure-lower-arcade.png',architect,
  '参考图用于确定多层廊道、立柱、种植与铺装关系；模型把原贴在实墙上的玻璃改成两处可进入门洞和休憩廊。内部功能、门数与家具为建模推断，非该广角照片的逐项复刻。'),
 ('下园整体：楼群与连续背山林冠',court+'wwj-courtyard-aerial.jpg','tests/artifacts/lower-integration-main-lawn.png',architect,
  '此图为 v24 整体景观阶段；后续 v25 已重做中庭围合与低层空间，最新状态见顶部中庭组和全区巡查。具体等高线和树位未测绘。'),
 ('教学 A：暖墙高窗与混凝土长廊',plan+'teaching-a-arcade/008ff94b7c91df45.jpg','tests/artifacts/teaching-a-entry-long-hall.png',panorama+'116440778',
  '原低木条雨棚改为高混凝土梁柱空间，补暖墙高窗、深色竖片和灰板地面。8.5 m 基准和高窗分组为适配模型的估计。'),
 ('教学 A：通高玻璃与经管学院内廊',plan+'teaching-a-arcade/c17c62d4995b6df6.jpg','tests/artifacts/teaching-a-entry-glazed-entry.png',panorama+'116440778',
  '补通高玻璃框、开放门扇、内廊吊顶与灯，原门边柱移出开口。具体廊深、门宽仍为拟合，保留院落与楼梯连接。'),
 ('教学 A：面向前场的悬挂遮阳',plan+'teaching-a-arcade/a18399d16793953e.jpg','tests/artifacts/teaching-a-entry-outer-screen.png',panorama+'116440778',
  '遮阳集中在外侧上部，补横向支架、细斜撑及墙边管线。构件间距和尺寸为模型估计；画面方位不代表已标定真北。'),
 ('图书馆 G 层：玻璃共享门厅',original+'library-spaces/ground-floor/07b83db0ab0918ba.jpg','tests/artifacts/library-lobby-g-room.png',panorama+'41566368',
  '补白框透明玻璃、暖色网格顶棚、方灯、圆桌及蓝橙椅。房间尺度、桌椅数量及门洞布局仍为拟合。'),
 ('图书馆 G 层：木片墙与接待空间',original+'library-spaces/ground-floor/44d1b10cb7e8cbae.jpg','tests/artifacts/library-lobby-g-collaboration.png',panorama+'41566368',
  '区分压制木片墙、低反光地毯和浅色台面，替换原占位石台；未按完整室内平面还原。'),
 ('图书馆入口：深座席与正常楼梯',original+'library-spaces/second-floor-entry/20062e7e4fcbe2d0.jpg','tests/artifacts/library-lobby-stair-seating.png',panorama+'41830774',
  '宽座席由密集小踏步改成八排深台阶，保留旁边正常楼梯，增加斜侧板、种植和密集吊顶。八排及具体尺寸是模型估计。'),
 ('行政楼：背山坡地与平台衔接',plan+'administration-hill/d1d0083d866158d5.jpg','tests/artifacts/admin-hill-overall.png',panorama+'116443781',
  '原来的平地与高直墙改为连续坡地、平台出口和服务道路缓坡。照片支持背山种植及高低层关系；等高线、具体标高和步道走线是拟合，不能当作测绘复原。'),
 ('行政楼：白色格栅与暖色下层窗带',court+'administration-mall/1c635b4b3b76834d.jpg','tests/artifacts/admin-public-front.png',panorama+'116440794',
  '拆分原整面通高白色竖格栅，下方补独立暖色窗带和水平收口；低翼白墙去掉砖格材质。高度沿用现有模型，未按该照片透视测量。'),
 ('行政楼：退进门厅与连续前场',court+'administration-mall/1c635b4b3b76834d.jpg','tests/artifacts/admin-public-forecourt.png',panorama+'116440794',
  '两翼底层由空架改为退进玻璃入口，前场补连续石铺装、回纹、花槽与种植边界。门厅内部平面和家具为功能性推断。'),
 ('行政楼：后平台绿化与横向屏风',plan+'administration-back/917b06144ac84b46.jpg','tests/artifacts/admin-public-rear-garden.png',panorama+'116443793',
  '补后平台低种植槽、树木和横向设备屏风；既有台阶与侧通道保留。平台至背山坡地的高度衔接仍需细化。'),
 ('教学 C：高窗长廊与外露梁柱',teaching+'tc-arcade/54bcd67ba155d2e1.jpg','tests/artifacts/teaching-arcade-c-long-hall.png',panorama+'41566307',
  '低雨棚改为高窗长廊，补白色横带、通透玻璃、混凝土梁柱、悬挂遮阳和灰色长条地面。8.5 m 为适配已有二层的模型基准，非现场测得净高。'),
 ('教学 C：反向廊道与服务管线',teaching+'tc-arcade/8caaefb6b68a3bfe.jpg','tests/artifacts/teaching-arcade-c-reverse.png',panorama+'41566307',
  '核对柱廊另一观看方向，补内侧管线、灯具和高位遮阳支架。未复制全景中的活动海报，门后空间与房间分配仍为推断。'),
 ('教学 B：门厅延伸到内廊',teaching+'tb-lobby/57affc6fd2b0c3af.jpg','tests/artifacts/teaching-arcade-b-lobby.png',panorama+'41566303',
  '原封闭小门厅打开后墙，改成贯通内廊；延续穿孔格栅顶棚与条灯，展示架移出通行中线。走廊长度、侧室和后出口具体位置为拟合。'),
 ('主广场道路：暖色步道与路缘',start_zone+'main-square/670416078f8c450b.jpg','tests/artifacts/start-street-avenue.png',panorama+'116440774',
  '补连续暖色步道、路缘过街开口、弯臂路灯和排水口。沿用局部坐标，宽度及道路走线为适配模型的估计；不将画面前后当作真北方向。'),
 ('乐天楼：连续红砖前场',start_zone+'le-tian/72f9fab671de3e32.jpg','tests/artifacts/start-street-le-tian-court.png',panorama+'116846253',
  '将入口孤立铺装接到主路，采用全景可见的红砖、玻璃门廊与种植边界关系。树木、座椅数量和空地尺度为建模估计。'),
 ('道远楼：树荫与入口连接',start_zone+'dao-yuan/4b678b7dd6ba267e.jpg','tests/artifacts/start-street-dao-yuan.png',panorama+'116440775',
  '入口增加红砖步行区、石质绿化边界、树荫与座椅；原先穿过楼体的道路移至楼外，具体走线尚未测绘确认。'),
 ('乐天楼：窄窗与玻璃入口',start_zone+'le-tian/3e44d11f2f5485f8.jpg','tests/artifacts/start-public-le-tian-entry.png',panorama+'116846253',
  '移除从相邻立面误套的设备栏架，改灰色窗间墙、独立窄窗、青色玻璃和统一雨棚。入口退进与室内布置仍按现有模型估计。'),
 ('知仁楼：成对窗与设备栏架',start_zone+'zhi-ren/d82b49269650e992.jpg','tests/artifacts/start-public-zhi-ren.png',panorama+'116846254',
  '单窗模板换成成对竖窗，设备栏架由实心盒子改为浅平台、侧框与细横条；补架空层梁柱和公共入口。'),
 ('知新楼：窗带、白色端墙与玻璃转角',start_zone+'main-square/b7a2777768128043.jpg','tests/artifacts/start-public-zhi-xin.png',panorama+'116440774',
  '长翼恢复横向窗带，面向前场的端墙留白安置楼名，首层青色玻璃封合到转角；机位和比例未测绘配准，不能按左右判断真北。'),
 ('学生中心：黄色餐厅外廊',court+'student-canteen/e0b494b5bf779646.jpg','tests/artifacts/student-public-yellow-arcade.png',panorama+'116440789',
  '按官方外廊重做黄色面砖、深色玻璃、连续梁柱、桌椅与悬挂织物。素色织物表达空间节奏，室内分配和家具数量仍为推断。'),
 ('学生中心：入口红色高墙',court+'student-canteen/314d97d5358e898f.jpg','tests/artifacts/student-public-red-wall.png',panorama+'116440789',
  '通用窗格改成大片红色墙面、竖向细构件与可进入后厅门；具体门洞分配与层高按保留模型估计。'),
 ('学生中心：双内院与屋顶收边',court+'wwj-courtyard-aerial.jpg','tests/artifacts/student-public-courts.png',architect,
  '连续外轮廓和两院落女儿墙替代各楼翼之间的重复横墙，补合横翼与前翼屋顶；增加两侧可走二层回廊。宽深比例仍适配现有锚点。'),
 ('图书馆：后侧凹口与两翼平面',library_plan+'official-library-floor-5.jpg','tests/artifacts/library-plan-plan.png','https://library.cuhk.edu.cn/floor-maps',
  '官方五层导览确认明显后侧凹口和两翼关系；模型已移除原先整面平背墙。两图方向与比例不同，不能按画面左右判断真北；尺寸仍适配保留锚点。'),
 ('图书馆：三层室外研习露台',library_plan+'official-library-floor-3.jpg','tests/artifacts/library-plan-terrace.png','https://library.cuhk.edu.cn/floor-maps',
  '三层图明确标出室外研习区。模型补可走露台、门洞、栏杆与座椅；露台尺度、家具及连接楼梯位置为建模推断。'),
 ('图书馆：三层阅读空间',library_plan+'official-library-floor-3.jpg','tests/artifacts/library-plan-study.png','https://library.cuhk.edu.cn/floor-maps',
  '新增二层至三层楼梯、真实楼板洞口、完整顶棚、桌椅及书架。此处展示可用空间与楼层关系，尚未按室内实拍还原陈设。'),
 ('教学 B/C/D：斜向院落平面',plan+'architect-plans/f378f6f2b544179e.jpg','tests/artifacts/plan-refined-teaching-plan.png',rocco,
  '建筑师屋顶平面配合校方地图确认三栋斜翼院落，模型已去掉三套相似的四面围合矩形。图纸与模型画面旋转不同，模型间距与纵横比例仍适配保留锚点。'),
 ('行政楼：背面与四层平台',plan+'administration-back/879a0df90f5b94a7.jpg','tests/artifacts/plan-refined-administration-back.png',panorama+'116443793',
  '根据后门/背山全景补齐四排成组横窗、玻璃转角和可走平台；校方七层改造公告佐证高层部分存在，米制高度仍是估计。'),
 ('教学 A：首层长廊',plan+'teaching-a-arcade/008ff94b7c91df45.jpg','tests/artifacts/plan-refined-a-arcade.png',panorama+'116440778',
  '新增暖色墙体、深色竖向遮阳、贯通门厅与经管学院标识；避免把 A 与三栋斜翼教学楼做成同一形体。'),
 ('体育馆：深入口与竖向遮阳',western+'sports-front/be4f24969ae128b5.jpg','tests/artifacts/western-refined-sports-entrance.png',panorama+'116440784',
  '重建高门廊、深梁、左侧暗色遮阳和短台阶；入口玻璃留出真实门洞。尺寸为拟合值。'),
 ('体育馆：运动场立面',western+'track/ee2a9044b341b7e2.jpg','tests/artifacts/western-refined-sports-field.png',panorama+'116443789',
  '按场侧观看方向核对折线屋脊和彩色遮阳的左右关系，增加架空底层与上层连续外廊。与运动场的间距仍沿用现有锚点。'),
 ('体育馆：接待厅',western+'reception/c5c752ae108ab534.jpg','tests/artifacts/western-refined-reception.png',panorama+'116440785',
  '浅色接待台、肋状吊顶和玻璃旁红色座椅。没有据一张门厅全景虚构完整体育馆内部分区。'),
 ('旧校门：独立石柱',western+'old-gate/7e58ee842bb3de0d.jpg','tests/artifacts/western-refined-old-gate.png',panorama+'116410028',
  '删除原先跨路横梁，改为两根带挑臂的独立石柱，补校名墙、隔离柱与斑马线；方位沿用现有校园局部坐标。'),
 ('逸夫国际会议中心：入口',conference+'front/c9c0834ca1054763.jpg','tests/artifacts/conference-refined-entrance.png',panorama+'116443785',
  '高玻璃门厅、白色楼名带、交替竖向构件和玻璃平台栏杆；入口高差与整体宽度按保留锚点拟合。'),
 ('会议中心：门厅与楼梯',conference+'lobby/6770aebeff81f311.jpg','tests/artifacts/conference-refined-foyer.png',panorama+'41792321',
  '对照石材墙面、木饰面、玻璃栏杆和楼梯。未重建官方校徽，也未宣称完整室内平面或座席复原。'),
 ('会议中心：下层柱廊',conference+'avenue/42bad02147dd8b39.jpg','tests/artifacts/conference-refined-lower-arcade.png',panorama+'116443783',
  '对照悬挑厅体下的柱廊、石墙、入口门和铺装。厅体层高 15 m 另有校方历史招标依据，总楼高仍是估算。'),
 ('图书馆池侧：金属外壳与通高遮阳',site+'lotus-pond/926142ea507ee528.jpg','tests/artifacts/library-plan-pond.png',panorama+'116440795',
  '三排深凹窗、铜色窗侧、通高金色遮阳和屋顶收边。v15 结合官方楼层图区分两侧曲率，池侧更平；具体曲率仍为拟合值。'),
 ('南门与林荫入口',site+'south-gate/c7c86b7629f5d983.jpg','tests/artifacts/landscape-finish-south-gate.png',panorama+'116410029',
  '参考低矮校名石墙、侧向门岗与树阵；位置按校方地图中的教学 A/B 间隙拟合，米制尺寸未测绘。'),
 ('荷花池与学生中心池侧',site+'lotus-pond/0cd12a71726acaee.jpg','tests/artifacts/landscape-refined-pond-student.png',panorama+'116440795',
  '已纠正原先脱离两楼的占位水池，参考池岸、黄色凹廊、高位开口与红色遮阳段。池面面积和水深为估算。'),
 ('图书馆、学生中心之间的水院',court+'wwj-courtyard-aerial.jpg','tests/artifacts/landscape-refined-central-water-court.png',architect,
  '航拍支持池塘位于两栋楼之间、下沉庭院后侧的关系。模型视角与原图相反，不应据画面左右判断真北。'),
 ('学生中心与中庭',court+'wwj-courtyard-aerial.jpg','tests/artifacts/landscape-finish-district.png',architect,
  '核对灰白窄窗、通高开口、双内院和多层连廊。模型仍沿用现有建筑锚点，中庭尺度是拟合值。'),
 ('大学图书馆',court+'wwj-courtyard-aerial.jpg','tests/artifacts/library-plan-roof.png',architect,
  'v15 重新处理后侧双翼凹口和折线采光体，并增加三层露台。正面仍沿用已核对入口；宽深比和屋顶高度尚未测绘配准到航拍。'),
 ('行政楼',court+'administration-mall/1c635b4b3b76834d.jpg','tests/artifacts/plan-refined-administration-front.png',panorama+'116440794',
  '核对白色竖向低翼、上部遮阳连桥与中间宽台阶；v14 结合后侧四排窗和七层公告补高主体。两幅图片机位不同。'),
 ('教学 A：折返楼梯',teaching+'ta-square/bc9bf17f9d822fc2.jpg','tests/artifacts/teaching-refined-a-switchback.png',panorama+'116443786',
  '对照具体楼梯、开放回廊与窄窗的构造；回廊的连接布局与尺寸为建模推断。'),
 ('教学 B：门厅',teaching+'tb-lobby/57affc6fd2b0c3af.jpg','tests/artifacts/teaching-refined-b-lobby.png',panorama+'41566303',
  '对照深色网格顶棚、门厅展板及院系标识。没有复制现成海报或人员照片。'),
 ('教学 C：沿街柱廊',teaching+'tc-arcade/54bcd67ba155d2e1.jpg','tests/artifacts/teaching-refined-c-arcade.png',panorama+'41566307',
  '对照玻璃门面、梁柱、悬挂遮阳片与开放步道。已移除多余重复柱列。'),
 ('教学组团',original+'teaching-official-aerial.jpg','tests/artifacts/plan-refined-c-oblique.png','https://www.cuhk.edu.cn/zh-hans/article/2278',
  '校方航拍与建筑师平面互相核对，B/C/D 改为斜向长楼翼。模型保留东门局部坐标，不声称与航拍同向或同尺度。')]
sections=[]
for i,(title,ref,model,url,note) in enumerate(pairs):
    for rel in [ref,model]:
        if not (root/rel).is_file():raise FileNotFoundError(rel)
    sections.append(f'''<section id="pair-{i}"><header><h2>{escape(title)}</h2><a href="{escape(url)}" target="_blank" rel="noreferrer">原始来源 ↗</a></header>
<p>{escape(note)}</p><div class="pair"><figure class="reference"><figcaption>参考照片</figcaption><a href="../{escape(ref)}"><img src="../{escape(ref)}" loading="lazy" alt="{escape(title)}参考"></a></figure>
<figure><figcaption>实机记录 · 对应建模阶段</figcaption><a href="../{escape(model)}"><img src="../{escape(model)}" loading="lazy" alt="{escape(title)}实机"></a></figure></div></section>''')
links=''.join(f'<a href="#pair-{i}">{escape(item[0])}</a>' for i,item in enumerate(pairs))
page='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>下园建模 · 实景对照</title><style>
:root{color-scheme:dark}*{box-sizing:border-box}body{margin:0;background:#191d20;color:#ecede7;font:15px/1.7 "Segoe UI","Microsoft YaHei",sans-serif}main{max-width:1680px;margin:auto;padding:32px}h1{font-size:32px;margin:0}h2{font-size:22px;margin:0}p{color:#b8c0bd;margin:10px 0 20px}a{color:#d2ba8b}nav{display:flex;gap:10px 24px;flex-wrap:wrap;margin:22px 0 32px}section{padding:24px 0 32px;border-top:1px solid #414848;scroll-margin-top:20px}header{display:flex;justify-content:space-between;align-items:center;gap:20px}.pair{display:grid;grid-template-columns:1fr 1fr;gap:18px}figure{margin:0;background:#111719}figcaption{padding:9px 12px;color:#c4ceca;font-size:13px}img{display:block;width:100%;height:440px;object-fit:contain;background:#111719}button{border:1px solid #63716b;background:#26312d;color:#e4e8df;padding:8px 14px;border-radius:5px;cursor:pointer}.model-only .reference{display:none}.model-only .pair{grid-template-columns:1fr}.model-only img{height:620px}@media(max-width:850px){main{padding:18px}.pair{grid-template-columns:1fr}img{height:auto;max-height:600px}}
</style><main><h1>下园建模 · 实景对照</h1><p>2026-10-10 · v30。左侧保留原始参考，右侧为对应阶段的实际游戏画面；机位不一致，尺寸与未可见部分仍有推断。点击图片可打开原文件。<a href="LOWER_CAMPUS_SCOPE_REVIEW.html">查看当前全区巡查</a> · <a href="LOWER_CAMPUS_COMPLETION_REVIEW.md">范围与验收说明</a></p>
<button onclick="document.body.classList.toggle('model-only');this.textContent=document.body.classList.contains('model-only')?'恢复并排对照':'放大实机画面'">放大实机画面</button><nav>'''+links+'</nav>'+''.join(sections)+'</main></html>'
output=root/'docs/LOWER_CAMPUS_VISUAL_COMPARE.html'
output.write_text(page,encoding='utf-8')
print(f'{output}\n{len(pairs)} verified reference/model pairs, local only')
