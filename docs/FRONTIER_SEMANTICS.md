## Phase D2：观察中的缺口记录

`ground_context.gap_review`附加两条参考层记录，含id、segment_id、status、closed、reviewed_references、evidence_count、source_family_count、matched_chain_links、missing_zh和required_evidence。资料数是去重全景数，不是独立佐证数。两条均unknown/closed=false，phase_e_ready=false；返回深拷贝，客户端修改不会污染证据门槛。

没有创建PEDESTRIAN_ACCESS_D01/JUNCTION_D01，没有把GAP_A/B注册为objects/destinations，没有正确路线提示。schema lake-4和动作接口不变。地理配准仍未知。

# Phase D 地面证据观察补充

`ground_context` 为lake-4兼容追加字段：authored_section/name_zh、reference_candidates、registration=unknown、reference_segments、coverage、next_unknown、new_path_enabled=false、candidate_mapping_is_localization=false。

参考段ID GroundSegment_D01–D04不进入世界对象/可导航目标，不代表现有路径位置。confidence限定local_reference_pedestrian_continuity，geometry_confidence独立；每段geometry_source/visual_source/evidence/conflict/missing_evidence分别维护。game_position=null，game_instantiated=false。只有获得真实配准和连续地面证据后才可建立实际junction/branches。

F1从同一运行时数据生成中文数量；观察使用深拷贝避免外部修改污染证据。JSON与参考矩阵相等性纳入资料验证。以下为Phase C历史契约。

# 前沿语义约定

V1.0 Phase C，兼容 lake-4。

`observe().frontier` 包含 id、name_zh、position、semantic_alias、zone、confidence、geographic_anchor、extension_enabled、sources、evidence_matrix。`FRONTIER_CONNECTOR_B` 为固定调查基准，不新增重复导航目标；navigate 仍用 UNKNOWN_CONNECTOR。

location.frontier_id 只在 ZONE_CONNECTOR_UNKNOWN 返回前沿ID，其他区域为空。location.geographic_anchor 为 unknown。zone 的 inferred 是原型划区置信度，不是校园地理定位精度。

终点整体 confidence=unknown，evidence.geometry/presence/position=placeholder。已建远景的 presence=verified 仅表示参考中存在这类外观；position=placeholder，geographic_anchor=unknown，建筑 identity=unknown。不要将一个字段的高等级传播给其他字段。

三组 REF_* 仅在参考证据文件中：type=reference_landmark、zone=reference_only、landmark=true、walkable=false、connector=false、obstacle=false、game_registered=false、game_position=null。它们没有虚构的游戏坐标，不加入 objects/destinations/known_landmarks，不可导航。

默认游戏HUD不展示研究数据；F1使用中文标签与编号展示来源，原始技术ID只在结构化观察和文档中出现。所有原有动作、verifier、计时和接驳语义保持不变。
