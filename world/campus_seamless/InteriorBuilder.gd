extends RefCounted
const I:=preload("res://world/campus_seamless/InteriorKit.gd")
const K:=preload("res://world/campus_exterior/ExteriorArchitectureKit.gd")
static func build(d: Dictionary) -> Node3D:
	var root:=Node3D.new();root.name=d.interior_id
	for key: String in ["building_id","interior_id","floor","zone_type","reference_confidence","entrances","connections"]:root.set_meta(key,d[key])
	root.set_meta("interior_zone_id",d.interior_id);root.set_meta("floor_id",d.building_id+"_floor_0");root.set_meta("entrance_id",d.entrances[0]);root.set_meta("room_semantic_id",d.rooms)
	root.set_meta("stairs_connection",d.connections);root.set_meta("exit_connection",d.building_id+"_exit_main")
	var w: float=d.width;var depth: float=d.depth;var h: float=d.height
	I.box(root,Vector3(0,-.13,0),Vector3(w,.26,depth),"light_stone",true)
	I.box(root,Vector3(0,.045,0),Vector3(w-.2,.035,depth-.2),"light_stone")
	I.box(root,Vector3(0,h+.18,0),Vector3(w,.36,depth),"warm_white",true)
	# Solid back and side envelope, transparent entrance side panels. Five-unit main opening.
	I.box(root,Vector3(0,h/2,-depth/2),Vector3(w,h,.3),"warm_white",true)
	for side in [-1,1]:
		I.box(root,Vector3(side*w/2,h/2,0),Vector3(.3,h,depth),"warm_white",true)
		I.glass(root,Vector3(side*(w/4+1.35),h/2,depth/2),Vector3(w/2-2.7,h,.28))
	I.box(root,Vector3(0,7.35,depth/2),Vector3(5.4,5.3,.3),"warm_white",true)
	I.lettering(root,d.name_zh+"\n公共大厅",Vector3(0,6.2,depth/2+.21),.018)
	var exit_sign:=I.lettering(root,"出口 ↓",Vector3(0,4.25,depth/2-.35),.014);exit_sign.rotation.y=PI
	I.lights(root,w,depth,h)
	# Columns and restrained floor bands subdivide the public span without cluttering the exit lane.
	for side in [-1,1]:
		for z in [-depth*.18,depth*.22]:I.box(root,Vector3(side*(w/2-1),h/2,z),Vector3(.55,h,.55),"light_stone",true)
	I.box(root,Vector3(0,.068,0),Vector3(4,.01,depth-.3),"concrete_gray")
	for z in [-depth*.28,depth*.1]:I.box(root,Vector3(0,.069,z),Vector3(w-.3,.01,.08),"dark_frame")
	for side in [-1,1]:I.plant(root,Vector3(side*(w/2-1.6),0,depth/2-2))
	var counter:=Vector3(-w/2+4,0,depth/2-6)
	I.box(root,counter+Vector3.UP*1,Vector3(5,2,1.5),"wood_accent",true)
	I.lettering(root,"服务台",counter+Vector3(0,2.8,-.6),.014)
	I.board(root,Vector3(w/2-3,3,depth/2-3),"公共空间\n大厅 · 服务台\n楼梯 ↑    出口 ↓")
	var kind: String=d.zone_type
	match kind:
		"library":
			I.lettering(root,"阅览区 · 请轻声",Vector3(-7,4,-7),.015)
			for z in [-6.0,-11.0]:
				I.shelf(root,Vector3(-w/2+2,0,z))
				for x in [-8.0,-4.0]:I.desk(root,Vector3(x,0,z))
		"student":
			I.board(root,Vector3(-6,3,-depth/2+.2),"招募被试 · 学术分享\n活动招募 · 失物招领\n高桌晚宴 · 社团交流")
			for x in [-7.0,7.0]:
				I.sofa(root,Vector3(x,0,-6));I.desk(root,Vector3(x,0,-3),false)
		"admin":
			I.board(root,Vector3(-6,3,-depth/2+.2),"行政楼\n访客接待 · 公共服务\n办公区域请勿进入")
			I.sofa(root,Vector3(-7,0,-6))
		"conference","music":
			I.board(root,Vector3(-7,3,-depth/2+.2),"会议活动 · 签到处" if kind=="conference" else "音乐学院 · 演出前厅\n请保持安静")
			I.sofa(root,Vector3(-8,0,-4));I.sofa(root,Vector3(-8,0,-8))
			I.box(root,Vector3(-3,2.1,-depth/2+.3),Vector3(5,4.2,.2),"wood_accent",true)
			I.lettering(root,"会议厅 · 暂未开放" if kind=="conference" else "演奏厅 · 暂未开放",Vector3(-3,3,-depth/2+.45),.011)
		"sports":
			I.lettering(root,"体育馆 · 场地观览",Vector3(0,4,-7),.014)
			I.box(root,Vector3(0,.02,-7),Vector3(w-4,.04,12),"wood_accent")
			for x in [-9.0,9.0]:I.box(root,Vector3(x,2.8,-12),Vector3(3,.16,.16),"dark_frame")
			for z in [-1.0,-13.0]:I.box(root,Vector3(0,.05,z),Vector3(w-6,.02,.12),"warm_white")
		"teaching":
			I.lettering(root,"教室 101 ←\n楼梯 ↑",Vector3(0,3.5,-3),.014)
			I.box(root,Vector3(-2,2.5,-8),Vector3(.22,5,12),"warm_white",true)
			I.lettering(root,"教室 101",Vector3(-6,3.6,-depth/2+.25),.012)
			I.box(root,Vector3(-7,2.8,-depth/2+.23),Vector3(6,2.5,.15),"glass_bluegray")
			I.box(root,Vector3(-7,1,-depth/2+2),Vector3(1.8,2,1.3),"wood_accent",true)
			# Rows are shared per material by bake; no chair-leg colliders.
			for z in [-4.0,-7.0,-10.0]:
				for x in [-9.0,-5.0]:I.desk(root,Vector3(x,0,z))
		"college":
			I.board(root,Vector3(-7,3,-depth/2+.2),"书院生活\n学术分享 · 失物招领\n活动报名 · 公共交流")
			if d.building_id=="ling":high_table(root)
			else:
				for z in [-4.0,-8.0]:I.sofa(root,Vector3(-7,0,z))
				I.desk(root,Vector3(-7,0,-6),false)
	if kind in ["library","college","teaching","music","admin"]:
		var x: float=w/2-4
		I.ramp(root,Vector3(x,0,5),Vector3(x,5,-10),4)
		I.box(root,Vector3(0,4.85,(-depth/2-10)/2),Vector3(w-.5,.3,depth/2-10),"light_stone",true)
		I.box(root,Vector3(-3,6.5,-10),Vector3(w-12,.12,.12),"dark_frame",true)
		I.lettering(root,"楼梯 ↑",Vector3(x,3,6),.014)
		I.lettering(root,"公共平台 · 原路下楼",Vector3(0,7,-depth/2+.2),.012)
		I.box(root,Vector3(-w/2+3,7,-depth/2+.25),Vector3(2.5,4,.2),"dark_frame",true)
	I.finish(root);return root

static func high_table(root: Node3D) -> void:
	I.lettering(root,"高桌晚宴 · 演示场景",Vector3(-6,4,-9),.012)
	for x in [-9.0,-5.0]:
		I.box(root,Vector3(x,1.12,-8),Vector3(2,.16,5),"wood_accent",true)
		for z in [-9.5,-7.5]:
			var person:=Node3D.new();person.position=Vector3(x-1.2,0,z);root.add_child(person)
			preload("res://world/MeshKit.gd").person(person,Color("b7a4ca"),"gown")
	I.board(root,Vector3(6,3,11),"高桌晚宴 · 签到\n正装及学生袍\n走路的时候注意看路")
	I.box(root,Vector3(-7,2,-13.6),Vector3(10,4,.12),"wood_accent")
	I.lettering(root,"相聚 · 交流 · 成长",Vector3(-7,3,-13.4),.012)
