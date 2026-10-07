extends Label
const Env:=preload("res://world/campus_exterior/ExteriorEnvironment.gd")
var world: Node3D
var accuracy: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_accuracy_v4.json"))
const ZH: Dictionary={"UPPER_COLLEGE_CORE":"上园书院核心","UPPER_RESIDENTIAL_EDGE":"教职员宿舍边缘","UPPER_SERVICE_AREA":"上园服务区","UPPER_SPORTS":"上园运动区","UPPER_TO_MIDDLE_TRANSITION":"上园至湖区过渡","FAIRY_LAKE_NORTH":"神仙湖北岸","FAIRY_LAKE_WEST":"神仙湖西岸","FAIRY_LAKE_EAST":"神仙湖东岸","FAIRY_LAKE_SOUTH":"神仙湖南岸","MIDDLE_MUSIC_AREA":"音乐学院周边","LOWER_SPORTS":"下园运动区","LOWER_LIBRARY_STUDENT_CORE":"图书馆与学生中心","LOWER_ACADEMIC_CORE":"下园教学院落","LOWER_ADMIN_CONFERENCE":"行政与会议区","LOWER_SHAW":"逸夫书院周边","LOWER_GATE_EDGE":"下园校门边缘"}

func _process(_delta: float) -> void:
	visible=world.show_labels
	if not visible:return
	var p: Vector3=world.player.position
	var zone_name: String="校园连接段"
	for zone: Dictionary in Env.data.zones:
		var b: Array=zone.bounds
		if p.x>=b[0] and p.x<=b[2] and p.z>=b[1] and p.z<=b[3]:zone_name=ZH[zone.id];break
	var closest: String="";var distance: float=INF
	for id: String in world.objects:
		var root: Node3D=world.objects[id]
		if root.position.distance_to(p)<distance:distance=root.position.distance_to(p);closest=id
	var detail: String=""
	for record: Dictionary in accuracy.records:
		if record.id==closest:
			var architecture: String="资料支持形态；尺寸推定" if record.architecture_confidence=="SUPPORTED" else "推定"
			detail="\n最近对象："+world.objects[closest].get_meta("spatial_record").name_zh+"\n位置：推定　建筑："+architecture+"\n环境：推定　地形：相对高差推定";break
	text="环境置信：推定 · 可替换\n所在分区："+zone_name+detail+"\n接驳设施：占位 · 运营信息未确认\n[F6] 置信热图（绿：部分形态支持，橙：推定，红：占位）"
