# 世界资产策略

V0.5 实施选择：**原创风格化核心区 + 外部证据作空间参考**。真实楼宇和低多边形不是二选一：保留庭院、连廊、架空层、窗列、玻璃和绿化关系，压缩无事件距离，不追求逐砖复刻。

## 导入流水线

来源/授权 → 单位与轴向清理 → 材质简化/烘焙 → 风格统一 → 游戏网格 → LOD → 简化 collider → 可走面/navmesh → semantic object → interaction metadata → Agent API。

每一步都有独立验收：原文件不可变；改网格要记录版本；碰撞不能直接使用数百万面扫描；人物高约 3 个游戏单位（可读性夸张），连廊约 5 个单位；同类建筑保持统一门窗节奏。当前固定小地图继续使用经实走验证的路点，不为此引入新的导航研究模块；大区域才考虑 NavMesh。

## 资产分层

- **互动层**：玩家、老师、拍照同学、朋友、手机、签到入口。形状与动作优先，角色拥有稳定 ID；世界状态更新仍由既有系统负责。
- **生活层**：12 个确定性背景学生，正装/学生袍、聊天、看手机、缓慢走动。没有新任务、AI 或网络请求；统一随暂停、结束停止。
- **建筑层**：原创庭院与侧廊、节奏窗列、合影转角、可看见桌椅的暖色门厅。屋顶局部切开，服务固定第三人称镜头。
- **远景层**：低面数山体与绿化，不扩大可玩边界。无高精扫描依赖。

## 语义结构

`world/WorldRegion.gd` 是当前区域和导航锚点的单一来源；AgentEnvironment 直接引用相同 TARGETS。region_id/display_name/connections/navigation_entry_points/semantic_tags 将视觉空间与导航绑定。现有 action ID 和 verifier 不改变。

未来对象建议：

```json
{
  "object_id": "academic_building_01",
  "type": "Building",
  "region_id": "academic_area",
  "display_name": "待核实教学楼",
  "semantic_tags": ["teaching"],
  "entrances": [],
  "walkable": false,
  "interaction_ids": [],
  "source_asset_id": "pending",
  "spatial_confidence": "UNVERIFIED"
}
```

Path 另含 from/to、长度、坡度、是否台阶、walk_time、可达条件；BusStop 另含 route_ids、boarding_anchor、时刻表来源。未核实入口不能自动变成可导航点。游戏交互必须依赖同一真实碰撞世界，禁止给 Agent 隐藏传送路线。

## 转换代价（工程判断，不是来源事实）

已授权单体 Blender → Godot：低至中，主要是材质/比例/碰撞。完整旧 Unity 工程：中至高，商店依赖与脚本迁移风险明显。点云/3DGS → 可玩网格：高，需重建缺失表面、重拓扑及重新标语义；本轮不实施。官方 VR → 原创建筑参考：低，不能据全景直接测精确尺寸。
