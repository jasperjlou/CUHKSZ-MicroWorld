extends RefCounted
## 2023 anniversary Central Mall image: stone field, inset lawns and transverse bands.
## Dimensions are fitted to the retained East Gate anchors, not survey measurements.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24

static func rect(a: Array) -> Rect2:
	return Rect2(a[0],a[1],a[2]-a[0],a[3]-a[1])

static func contains(regions: Array,p: Vector2) -> bool:
	for r: Dictionary in regions:
		if rect(r.bounds).has_point(p):return true
	return false

static func build(root: Node3D,builder) -> void:
	var regions: Array=builder.data.get("surface_regions",[])
	var holes: Array=builder.data.get("surface_exclusions",[])
	for r: Dictionary in regions:
		var b:=K.holder(root,"AnniversaryGround_"+r.id)
		var area:=rect(r.bounds);var xs: Array[float]=[area.position.x,area.end.x];var zs: Array[float]=[area.position.y,area.end.y]
		var exclusions: Array=[]
		if r.kind=="stone":
			for other: Dictionary in regions:
				if other.kind=="lawn" and area.intersects(rect(other.bounds)):exclusions.append(other)
			for hole: Dictionary in holes:
				if area.intersects(rect(hole.bounds)):exclusions.append(hole)
		for e: Dictionary in exclusions:
			var cut:=rect(e.bounds).intersection(area)
			for x in [cut.position.x,cut.end.x]:
				if not xs.has(x):xs.append(x)
			for z in [cut.position.y,cut.end.y]:
				if not zs.has(z):zs.append(z)
		xs.sort();zs.sort()
		var vertices:=PackedVector3Array()
		for ix in xs.size()-1:
			for iz in zs.size()-1:
				var x0:=xs[ix];var x1:=xs[ix+1];var z0:=zs[iz];var z1:=zs[iz+1]
				if contains(exclusions,Vector2((x0+x1)/2,(z0+z1)/2)):continue
				var y: float=G+(.112 if r.kind=="stone" else .113)
				if r.id=="library_mall":
					var cell:=PackedVector2Array([Vector2(x0,z0),Vector2(x1,z0),Vector2(x1,z1),Vector2(x0,z1)])
					for dry:PackedVector2Array in preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd").subtract([cell],preload("res://world/visual_campus/LibraryPoolFrontage.gd").outline()):
						vertices.append_array(preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd").floor_vertices([dry],y))
					continue
				vertices.append_array(K.quad(Vector3(x0,y,z0),Vector3(x1,y,z0),Vector3(x1,y,z1),Vector3(x0,y,z1)))
		if not vertices.is_empty():K.surface(b,vertices,r.get("color","aeb1ad"),26 if r.kind=="stone" else 3)
		if r.kind=="lawn":
			# Flush stone edging leaves all paths and lawn approaches accessible.
			for x in [area.position.x,area.end.x]:K.box(b,Vector3(x,G+.12,area.get_center().y),Vector3(.16,.04,area.size.y+.16),"c0c3bb",false,6)
			for z in [area.position.y,area.end.y]:K.box(b,Vector3(area.get_center().x,G+.12,z),Vector3(area.size.x,.04,.16),"c0c3bb",false,6)
		K.finish(b)
	var detail:=K.holder(root,"AnniversaryPavingDetails")
	# Narrow dark aggregate strips cross the entrance plaza, as in the aerial reference.
	for z in [-204,-210,-216,-222,-244,-250,-326,-332,-392,-398,-414]:
		var x1: float=11.0 if z<-253 and z>-383 else 42.0
		K.box(detail,Vector3((-37+x1)/2,G+.116,z),Vector3(x1+37,.008,.32),"737c79",false,26)
	# Tree wells replace isolated trunks growing through slabs.
	for z in range(-76,-436,-20):
		if z>-163:continue # V98 continuous planted beds, no isolated square wells.
		if z>=-202 and z<=-163:continue
		for side in [-1,1]:
			if side==-1 and z<-334:continue # V89 continuous grass, no square wells through it.
			if side==1 and z>-333 and z<-253:continue # V90 stone shore has no isolated tree wells.
			if z in [-96,-156,-276,-396] or (side==1 and z>-391 and z<-327):continue
			if preload("res://world/visual_campus/StudentLowerConcourse.gd").cutout(side*12,z):continue
			K.box(detail,Vector3(side*12,G+.13,z),Vector3(2.3,.03,2.3),"514f40",false,8)
			for edge in [-1,1]:
				K.box(detail,Vector3(side*12+edge*1.2,G+.15,z),Vector3(.15,.05,2.55),"b6b9b2",false,6)
				K.box(detail,Vector3(side*12,G+.15,z+edge*1.2),Vector3(2.3,.05,.15),"b6b9b2",false,6)
	# V54 relocates the adjoining Zhixin garden; its shrubs are in StartZoneGrade.
	K.finish(detail)
