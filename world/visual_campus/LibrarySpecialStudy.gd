extends RefCounted
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Sixth := preload("res://world/visual_campus/LibrarySixthFloor.gd")

static func build(parent: Node3D) -> void:
	var n:=K.holder(parent,"LibraryFifthSpecialStudy");var y:=16.8
	# Rare-book room sits on the front side of the three-lift core in the 202401 plan.
	for x in [-32.0,-18.0]:K.box(n,Vector3(x,y+1.55,25.1),Vector3(.18,3.1,6.2),"d4d4c6",true,22)
	K.box(n,Vector3(-25,y+1.55,28.2),Vector3(14,3.1,.18),"d4d4c6",true,22)
	for span: Vector2 in [Vector2(-32,-22),Vector2(-19,-18)]:
		K.box(n,Vector3((span.x+span.y)/2,y+1.55,22),Vector3(span.y-span.x,3.1,.14),"bcc9c1",true,19)
	K.box(n,Vector3(-20.5,y+2.9,22),Vector3(3,.4,.18),"d4d4c6",false,22)
	K.label(n,"珍藏阅览室",Vector3(-20.5,y+2.9,21.88),.004).rotation.y=PI
	for x in [-28.0,-22.0]:Sixth.desk(n,Vector3(x,y,25.1))
	# Closed silence-cell envelopes; interior fit-out is not established by the map.
	Sixth.cell(n,501,Vector3(23,y,-15),PI/4,3.0,3.2)
	Sixth.cell(n,502,Vector3(28,y,-20),PI/4,3.0,3.2)
	K.label(n,"S501 / S502 · 静音研讨",Vector3(24,y+2.6,-11.9),.004)
	K.label(n,"Princeton University Press",Vector3(-29,y+2.3,-22),.0035)
	K.finish(n)
