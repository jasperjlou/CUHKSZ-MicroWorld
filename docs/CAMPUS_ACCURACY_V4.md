# Campus Accuracy V4

V4 是可替换的风格化外观重建，不是 GIS/BIM、真实距离或无障碍通行认证。

## 四个维度分开记录

机器记录：`systems/data/campus_accuracy_v4.json`，95 个对象；每个都有 current/target confidence、reference_ids、主路可见性、优先级、remaining_unknowns、replaceable，以及位置 / 建筑 / 环境 / 地形四维置信。

- 空间几何依然使用 verified / inferred / placeholder；本轮并未把推理坐标升级成 verified。
- 建筑形态另外使用 SUPPORTED / INFERRED；SUPPORTED 只指官方文字支持楼群数量或形态词汇，不代表精确平面、立面、尺度得到验证。
- 相对高差为 INFERRED_RELATIVE；接驳设施和运营信息仍 PLACEHOLDER。
- 建筑后立面为 INFERRED_REAR_FACADE。全景候选索引不等于本轮已观看全景。

[置信分布图](CAMPUS_ACCURACY_V4.svg) 是开发数据图。游戏 F1 显示最近对象四维状态；F6 打开独立热图。绿色只表示部分形态有资料支持，不能读成整栋已测绘。

## 44 栋外观覆盖

下表的“有”指渲染实现覆盖，不是实景相符证书。屋顶低围边/小型机房轮廓均为保守推理。所有建筑保留 V3 的位置与朝向。

| 对象 | 分级 | 正/侧/背立面 | 屋顶与入口 | 建筑形态置信 |
| --- | --- | --- | --- | --- |
| 道扬书院 `ling` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 思廷书院 `muse` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 学勤书院 `diligentia` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 祥波书院 `harmonia` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 永平书院 `duan` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 厚含书院 `minerva` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 第八书院 `eighth` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 服务中心 `amenity` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 上园健身设施（近似） `upper_gym` | C | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教职员宿舍1 `staff_1` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教职员宿舍2 `staff_2` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教职员宿舍3 `staff_3` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教职员宿舍4 `staff_4` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教职员宿舍5 `staff_5` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 音乐学院 `music` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 科研楼 `research` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 钟楼 `bell` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 志仁楼 `zhiren` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 乐天楼 `letian` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 诚道楼 `chengdao` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 逸夫书院（西座） `shaw_west` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 逸夫书院（东座） `shaw_east` | A | 有；背面推理 | 有；入口胶囊检查 | SUPPORTED |
| 大学体育馆 `sports_hall` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 综合运动馆 `sports_complex` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 知新楼 `zhixin` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 道远楼 `daoyuan` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 图书馆附馆 `library_annex` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 学生中心 `student_centre` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 大学图书馆 `library` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 涂辉龙楼 `hllu` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 李贤义楼 `leeyin` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 张灵斌楼 `zhangling` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教学楼C `teaching_c` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教学楼B `teaching_b` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 教学楼A `teaching_a` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 行政楼 `administration` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 逸夫国际会议中心 `conference` | A | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 会议楼II `conference_2` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 会议楼I `conference_1` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 礼文堂 `liwen` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 综合教学楼C座 `teaching_complex_c` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 综合教学楼D座 `teaching_complex_d` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 综合教学楼B座 `teaching_complex_b` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |
| 综合教学楼A座 `teaching_complex_a` | B | 有；背面推理 | 有；入口胶囊检查 | INFERRED |

## 本轮实景依据与边界

[Music 启用报道](https://www.cuhk.edu.cn/zh-hans/article/15580)支持七栋主要建筑、花瓣表演空间、U 形教学庭院和水平廊道。当前把五个教学/表演/服务体量放在音乐学院锚点，两个住宿体量留在第八书院锚点；这种空间分配、层数、尺寸与曲率为 inferred，不能把“七栋”当作七个位置均已证实。

[思廷](https://muse.cuhk.edu.cn/page/76)、[学勤](https://diligentia.cuhk.edu.cn/page/1051)、[校园生活](https://cuhk.edu.cn/zh-hans/campus-life)支持三栋宿舍或三栋联体组团的数量。道扬、祥波、永平、厚含采用各自比例与退台/院落布局；其具体楼数、开口和翼楼相对位置仍推理。

[校园介绍](https://admissions.cuhk.edu.cn/node/909)支持上中下园功能与道路/绿道词汇；车行道横向偏移是保守设计，不是该页面提供的道路测量。校门沿用 Campus Guide 的既有锚点，不新增“真实校门”。湖石题字和亭子词汇参考用户实拍；未把新增截图当作摄影原件。

`references/exterior_v4/source_decisions.json` 保留文字查阅决策；`building_coverage.json` 保留候选全景与 front/side/rear/roof 限制。原始图片、旧 GTA/DAE 不进入本次提交。

## 后续资料缺口（8 项，均不阻塞游玩）

1. 音乐学院：南侧入口至两座表演建筑连续斜视照片，确认两者曲面和高度关系。
2. 音乐学院：教学区北侧/屋顶斜视照片，确认三个 U 形体量与二栋住宿的实际分界。
3. 道扬/思廷/学勤：每院后侧至院落的一组连续照片，确认塔楼退台和廊道开口。
4. 祥波/永平/厚含：能同时看到至少两栋楼和道路的正侧面照片，校正各自翼楼关系。
5. 上园至湖区：跨坡顶、坡底各一张同方向照片，校正坡路方向、挡墙长度和相对高差。
6. 湖区：题字石至水库牌，以及亭子接桥的连续地面照片，校正彼此位置与岸边结构。
7. 下园：图书馆/学生中心/行政区的背面及高处斜视照片，校正屋顶、幕墙和公共庭院。
8. 校门/接驳站：站牌与路缘同框、以及校门两侧的照片；确认真实站点与步行入口。现有两站继续是运营占位。
