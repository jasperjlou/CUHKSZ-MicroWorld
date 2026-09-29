extends RefCounted
const Junction := preload("res://world/JunctionLayout.gd")
## Candidate references never certify the geographic location of authored paving.
static var data: Dictionary = {}

static func load_data() -> Dictionary:
	if data.is_empty():
		data = JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/ground_survey.json"))
	return data

static func observe(position: Vector3) -> Dictionary:
	var section := "AUTHORED_LAKE"
	var title := "湖区原型步道"
	var candidates: Array[String] = []
	if position.z > 79:
		section = "AUTHORED_B"
		title = "林缘原型连接段"
		candidates = ["GroundSegment_D03"]
	elif position.z > 42:
		section = "AUTHORED_A"
		title = "入口原型铺地"
		candidates = ["GroundSegment_D01","GroundSegment_D02"]
	var schema := load_data()
	var construction: Dictionary = {}
	if position.z > 112:
		construction = Junction.section(position)
		section = construction.id
		title = construction.name_zh
	return {"authored_section":section,"name_zh":title,"reference_candidates":candidates,"registration":"unknown","reference_segments":schema.segments.duplicate(true),"coverage":schema.coverage.duplicate(true),"gap_review":schema.get("gap_review",[]).duplicate(true),"phase_e_ready":true,"next_unknown":"","new_path_enabled":true,"candidate_mapping_is_localization":false,"construction":construction,"construction_policy":"evidence-aware inference","blocking_unknowns":0,"historical_evidence_scope":"gap_review records earlier source uncertainty, not current construction gates","playable_gap_resolution":[{"id":"GAP_A","confidence":"inferred","closed":true,"replaceable":true},{"id":"GAP_B","confidence":"placeholder","closed":true,"replaceable":true}]}

static func label_text(position: Vector3) -> String:
	var state := observe(position)
	var confidence: String = state.construction.get("confidence","inferred")
	var title: String = preload("res://systems/FrontierSurvey.gd").confidence_zh(confidence)
	var lines: Array[String] = ["当前地面：%s" % state.name_zh,"置信状态：%s；可替换：是" % title,"连接甲：推断，已通行","接入乙：临时占位，已通行","第一岔路已开放；按资料推理建设"]
	var basis: Array = state.construction.get("inference_basis",[])
	if not basis.is_empty():
		var reference_id := RegEx.new()
		reference_id.compile("FIELD_[0-9–-]+(与[0-9–-]+)?")
		lines.append("依据：%s" % reference_id.sub(basis[0],"实拍照片",true))
	return "\n".join(lines)

static func evidence_counts(gaps: Array) -> Array[String]:
	var result: Array[String] = []
	for gap: Dictionary in gaps:
		result.append("%s %d 处" % ["甲" if gap.id == "GAP_A" else "乙",gap.reviewed_references.size()])
	return result
