extends RefCounted
## Names describe modeled public spaces, not unverified room uses.
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
static func inside(q:Vector2,u:float,v:float,w:float,h:float)->bool:
	return Rect2(u,v,w,h).has_point(q)
static func label(at:Vector3)->String:
	var q:=Vector2(100+(at.x-44)*P.PIXELS_PER_METRE,458-(at.z+400)*P.PIXELS_PER_METRE)
	var y:=at.y-2.24
	if absf(y)<.65:
		for area in [Rect2(310,85,394,157),Rect2(220,242,484,211),Rect2(317,453,387,150),Rect2(505,603,199,84)]:
			if area.has_point(q):return "学生中心 · 首层餐厅"
	if absf(y-4.4)<.65:
		if inside(q,428,85,277,315) or inside(q,560,400,145,100):return "学生中心 · 二层餐厅"
	# Invert the registered 3F similarity, so hall and room boundaries follow their actual model.
	var a:=P.third_to_first(0,0);var u:=P.third_to_first(1,0)-a;var v:=P.third_to_first(0,1)-a
	var raw:=Transform2D(u,v,a).affine_inverse()*q
	if absf(y-8.8)<.65:
		if inside(raw,425,505,369,186):return "学生中心 · 三层301多功能厅"
		if inside(raw,425,34,285,166):return "学生中心 · 三层公共隔间"
	return ""
