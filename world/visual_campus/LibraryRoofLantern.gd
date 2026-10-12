extends RefCounted
## Connected folded lantern, supported by completed architect aerial and exploded roof.
## Roof extents/heights are fitted; public floor voids remain two distinct atria below.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Member=preload("res://world/visual_campus/LibraryRegisteredUpper.gd")
const RIDGE=[[450,750],[610,755],[672,764],[726,788],[777,835]]
const LEFT=[[450,690],[609,695],[650,690],[682,694],[717,705],[750,724],[788,757],[823,790]]
const RIGHT=[[450,809],[578,809],[612,814],[663,831],[701,852],[730,881]]
const EAVE=28.3
const PEAK=29.25

static func opening()->PackedVector2Array:
	var points:Array=LEFT.duplicate();var back:Array=RIGHT.duplicate();back.reverse();points.append_array(back)
	return P.polygon(points)

static func roof_panel(n:Node3D,side:Array)->void:
	var points:Array=side.duplicate();var ridge:Array=RIDGE.duplicate();ridge.reverse();points.append_array(ridge)
	var verts:=P.floor_vertices([P.polygon(points)],EAVE)
	for i in verts.size():
		for r in RIDGE:
			var q:=P.point(r[0],r[1])
			if Vector2(verts[i].x,verts[i].z).distance_to(Vector2(q.x,q.z))<.001:verts[i].y=PEAK;break
	K.surface(n,verts,"9bb3b5",19)

static func roof_y(p:Vector2)->float:
	return P.roof_height(p)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryConnectedRoofLanternV149");var boundary:=opening()
	roof_panel(n,LEFT);roof_panel(n,RIGHT)
	for i in boundary.size():
		var a:=boundary[i];var b:=boundary[(i+1)%boundary.size()];var mid:Vector2=(a+b)/2
		# Four-corner curb follows the roof pitch without gaps under a level box.
		var va:=Vector3(a.x,roof_y(a)-.05,a.y);var vb:=Vector3(b.x,roof_y(b)-.05,b.y)
		var vc:=Vector3(b.x,EAVE,b.y);var vd:=Vector3(a.x,EAVE,a.y)
		K.surface(n,PackedVector3Array([va,vb,vc,va,vc,vd,va,vc,vb,va,vd,vc]),"c4c7c0",13)
		Member.segment(n,Vector3(a.x,roof_y(a)+.025,a.y),Vector3(b.x,roof_y(b)+.025,b.y),.25,.06,"929c99",false,11)
		Member.segment(n,Vector3(a.x,EAVE,a.y),Vector3(b.x,EAVE,b.y),.085,.10,"a3b0ab",false,11)
	# Crossbars follow the bent ridge instead of crossing the light well as opaque slabs.
	var left_sections=[[450,690],[609,695],[682,694],[750,724],[823,790]]
	var right_sections=[[450,809],[612,814],[663,831],[701,852],[730,881]]
	for i in range(RIDGE.size()-1):
		var r0:=P.point(RIDGE[i][0],RIDGE[i][1],PEAK);var r1:=P.point(RIDGE[i+1][0],RIDGE[i+1][1],PEAK)
		Member.segment(n,r0,r1,.10,.12,"a8b6b0",false,11)
		var count:=maxi(1,int(ceil(r0.distance_to(r1)/1.15)))
		for j in range(count+1):
			if i>0 and j==0:continue
			var t:float=float(j)/count;var ridge:=r0.lerp(r1,t)
			for sections in [left_sections,right_sections]:
				var a:=P.point(sections[i][0],sections[i][1],EAVE);var b:=P.point(sections[i+1][0],sections[i+1][1],EAVE)
				Member.segment(n,a.lerp(b,t),ridge,.065,.085,"a8b6b0",false,11)
	for index in [0,4]:
		var a:=P.point(left_sections[index][0],left_sections[index][1],EAVE);var b:=P.point(right_sections[index][0],right_sections[index][1],EAVE);var ridge:=P.point(RIDGE[index][0],RIDGE[index][1],PEAK)
		K.surface(n,PackedVector3Array([a,b,ridge]),"9bb3b5",19)
	K.finish(n)
