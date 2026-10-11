# 下园植被、光照与地面 · 2026-10-10

继续参考[南门林荫入口](https://campusvr-en.cuhk.edu.cn/?scene_id=116410029)和[图书馆池边](https://campusvr-en.cuhk.edu.cn/?scene_id=116440795)的树阵、透空树冠与铺地关系。现有 24 组建筑锚点、44 条路线和已验收的可走地面碰撞均保留。

## 实际修改

- `CampusVegetation.gd` / `CampusFoliage.gdshader`：以有分枝的树干和三维叶片簇替代实心球体；花盆和南门绿篱也改为叶片簇。叶片为双面几何，无下载树木贴图；树种和种植位置仍属于表现性估计。
- 植被按 48 m 区域和材质合并，保留视锥裁剪。整片林地不再因为一个角落可见而全部提交。实现参考 [Godot 空间着色器文档](https://docs.godotengine.org/en/4.4/tutorials/shaders/shader_reference/spatial_shader.html)的双面着色与背光参数。
- `VisualCampus.gd` / `CampusSurface.gdshader`：增强环境补光、适度降低直射光，降低草地饱和度；金属表面高光收敛；图书馆主屋顶改用高粗糙度屋面材质。
- `VisualCampusBuilder.gd`：场地边缘增加不参与碰撞的视觉背景地面和背山树丛，消除旧画面里近处草地突然接棕色天空的断层。它不作为新增校区、道路或可通行地理数据。

## 集中检查

`tests/LandscapeVisualCapture.gd` 检查南门、林荫大道、池边、图书馆屋顶、教学 A、教学 B 门厅、下沉中庭等 7 个视角。最终引擎日志无脚本或着色器错误；构建 766 ms。报告是 `tests/artifacts/landscape_visual_milestone.json`，日志为 `landscape-visual-final.log`。

初次渲染发现未分区的大型植被 MultiMesh 会提交过多不可见实例，因此进行了分区调整后的最终检查。相同机位的渲染器图元计数：

| 机位 | 分区前 | 分区后 |
| --- | ---: | ---: |
| 林荫大道 | 15,567,604 | 7,350,416 |
| 图书馆池边 | 16,649,888 | 3,391,968 |
| 图书馆屋顶 | 14,273,265 | 3,639,125 |
| 中庭全景 | 20,740,239 | 8,108,559 |

上述数字是渲染器提交的图元计数，包含相关绘制通道，不是模型唯一三角形数。分区会增加少量绘制调用。报告中的帧间隔只是本机 1440×900、固定模拟步长下的短时观察，不能视为游戏帧率承诺。建筑与道路碰撞未改动，因此复用此前有效通行结果，没有重复全校园跑图。

## 仍需继续

当前植被能透空、显露枝干，但树冠密度和林带连续性仍有提升空间；远处背景是过渡地面。教学楼组团平面比例、下园其余实例楼的细节覆盖仍须继续逐栋推进，Goal 不因本批画面检查通过而结束。

![林荫大道](../tests/artifacts/landscape-finish-avenue.png)

![图书馆池侧](../tests/artifacts/landscape-finish-pond.png)
