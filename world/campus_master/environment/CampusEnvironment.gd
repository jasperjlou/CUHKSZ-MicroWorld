extends RefCounted
const G := preload("res://world/campus_master/CampusGeometry.gd")
const K := preload("res://world/campus_master/architecture/modules/ArchitectureKit.gd")
const E := preload("res://world/campus_master/environment/EnvironmentKit.gd")
static var data: Dictionary={}
static var stats: Dictionary={}

static func load_data() -> void:
	data=JSON.parse_string(FileAccess.get_file_as_string("res://systems/data/campus_environment_zones.json"))

static func node(parent: Node3D,id: String,record: Dictionary) -> Node3D:
	var result:=Node3D.new();result.name=id;parent.add_child(result)
	result.set_meta("confidence",record.confidence);result.set_meta("replaceable",true)
	result.set_meta("inference_basis",record.inference_basis);result.set_meta("environment_record",record)
	return result

static func points(record: Dictionary) -> Array[Vector3]:
	var list: Array[Vector3]=[]
	for p: Array in record.geometry:list.append(G.vec(p))
	return list

static func clear(p: Vector3,margin: float=3.0,ignore: String="") -> bool:
	if Geometry2D.is_point_in_polygon(Vector2(p.x,p.z),G.shore()):return false
	for o: Dictionary in G.master.objects:
		if o.id==ignore:continue
		if o.category in ["building","track","court"] and absf(p.x-o.center[0])<o.footprint_width/2+margin and absf(p.z-o.center[2])<o.footprint_depth/2+margin:return false
	for route: Dictionary in data.routes+data.entrance_connections:
		for i in range(route.geometry.size()-1):
			var a:=Vector2(route.geometry[i][0],route.geometry[i][2]);var b:=Vector2(route.geometry[i+1][0],route.geometry[i+1][2])
			if Vector2(p.x,p.z).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(p.x,p.z),a,b))<route.width/2+margin:return false
	return true

static func build(world: Node3D) -> void:
	load_data();stats={"routes":0,"entrances":0,"corridors":0,"trees":0,"lamps":0,"benches":0,"noticeboards":0,"junctions":0,"stops":0,"stairs":0,"ramps":0}
	var root:=Node3D.new();root.name="CampusEnvironmentV3";world.add_child(root)
	root.set_meta("environment_version","V3");root.set_meta("module_catalog",E.MODULES);root.set_meta("material_palette",E.PALETTE)
	var circulation:=node(root,"Circulation",data.zones[0])
	for r: Dictionary in data.routes:
		var pts:=points(r);var vehicle: bool=r.category=="vehicle"
		var material: String="Campus_Asphalt" if vehicle else "Campus_LakePath" if "lake" in r.id or "middle" in r.id else "Campus_WarmPaving" if "upper" in r.id or "shaw" in r.id else "Campus_LightStone"
		E.ribbon(circulation,pts,r.width,material,.25 if vehicle else .3)
		for side in [-1,1]:
			var edge: Array[Vector3]=[]
			for i in pts.size():
				var tangent: Vector3=pts[mini(i+1,pts.size()-1)]-pts[maxi(0,i-1)]
				var normal:=Vector3(tangent.z,0,-tangent.x).normalized()
				edge.append(pts[i]+normal*side*(r.width/2+.18))
			E.ribbon(circulation,edge,.36,"Campus_DarkStone" if vehicle else "Campus_Concrete",.29 if vehicle else .32)
		if vehicle:
			for i in range(pts.size()-1):
				var a: Vector3=pts[i];var b: Vector3=pts[i+1];var length:=a.distance_to(b)
				for distance in range(6,int(length)-4,16):
					var p:=a.lerp(b,distance/length)
					var mark:=E.box(circulation,E.ground(p.x,p.z)+Vector3.UP*.31,Vector3(.12,.025,3),"Campus_SignLight")
					mark.rotation.y=atan2(b.x-a.x,b.z-a.z)
		stats.routes+=1
	# Broaden junctions without changing route topology or road centre-lines.
	for n: Dictionary in G.paths.nodes:
		var degree:=0;var radius:=2.5
		for r: Dictionary in G.master.roads+G.paths.paths:
			if n.id in r.nodes:degree+=1;radius=maxf(radius,r.width*.55)
		if degree<3:continue
		var center:=G.vec(n.position);var verts:=PackedVector3Array()
		for i in 24:
			var a:=center+Vector3(cos(i*TAU/24),0,sin(i*TAU/24))*radius
			var b:=center+Vector3(cos((i+1)*TAU/24),0,sin((i+1)*TAU/24))*radius
			verts.append_array(PackedVector3Array([E.ground(center.x,center.z)+Vector3.UP*.34,E.ground(a.x,a.z)+Vector3.UP*.34,E.ground(b.x,b.z)+Vector3.UP*.34]))
		var patch:=G.surface(circulation,verts,Color(E.PALETTE.Campus_Concrete));patch.material_override=K.material(E.PALETTE.Campus_Concrete)
		stats.junctions+=1
		# Limited crossing bars at real authored pedestrian convergence, not city roads.
		if n.id in ["upper_west","lake_junction","lower_central","admin_entry","sports_entry"]:
			for x in range(-2,3):E.patch(circulation,center+Vector3(x*.9,0,0),.5,4,"Campus_SignLight",.36)
	E.bake(circulation)
	for zone: Dictionary in data.zones:
		var zroot:=node(root,zone.id,zone)
		vegetation(zroot,zone)
		E.bake(zroot)
	entrances(root,world)
	furniture(root)
	landmarks(root,world)
	root.set_meta("statistics",stats.duplicate())

static func entrances(parent: Node3D,world: Node3D) -> void:
	var root:=node(parent,"Entrances",data.zones[0])
	for r: Dictionary in data.entrance_connections:
		var pts:=points(r);var building: Node3D=world.objects[r.building_id]
		var o: Dictionary=building.get_meta("spatial_record")
		var warm: bool=o.region=="upper" or "shaw" in o.id
		var material: String="Campus_WarmPaving" if warm else "Campus_LightStone"
		var route:=node(root,r.id,r)
		E.ribbon(route,pts,r.width,material,.34)
		var outside: Vector3=pts[1]
		E.patch(route,outside,minf(o.footprint_width*.5,26) if r.tier=="A" else 9,7,material,.33)
		# Leave the entrance and central walking lane open; furniture sits outside both.
		for side in [-1,1]:
			var p:=E.ground(outside.x+side*8,outside.z+1.5)
			if clear(p,1.2,o.id):
				E.planter(route,p,r.tier=="A")
				if r.tier=="A":E.bench(route,p+Vector3(0,0,3),warm);stats.benches+=1
		if r.covered:
			var a: Vector3=pts[0]+Vector3(0,0,3)
			var b: Vector3=outside+Vector3(0,0,2)
			E.corridor(route,a,b);stats.corridors+=1
		if building.has_meta("courtyard_local"):
			E.patch(route,building.position,minf(22,o.footprint_width*.29),o.footprint_depth*.32,"Campus_CourtPaving",.29)
		if r.tier=="A" or o.id=="amenity":
			var signpos:=E.ground(outside.x+5,outside.z+3)
			E.wayfinding(route,signpos,o.name_zh+"\n"+o.name_en)
			if o.id in ["ling","muse","diligentia","harmonia","student_centre","shaw_east","amenity"]:
				E.notice(route,E.ground(outside.x-10,outside.z+3));stats.noticeboards+=1
		# Decorative side steps describe a pad edge; the centre remains the ramped terrain.
		var drop: float=outside.y-pts[0].y
		if absf(drop)>.45 and r.tier=="A":
			for i in 3:
				var p:=E.ground(outside.x+12,outside.z+i*.5)
				E.box(route,p+Vector3.UP*(.06+i*.05),Vector3(2,.12,.5),"Campus_Concrete")
			stats.stairs+=1;stats.ramps+=1
		E.bake(route);stats.entrances+=1

static func vegetation(root: Node3D,zone: Dictionary) -> void:
	var b: Array=zone.bounds;var spacing: int=zone.tree_spacing
	var families: Array=[[],[],[],[],[]];var trunks: Array[Transform3D]=[]
	for x in range(int(b[0])+8,int(b[2])-5,spacing):
		for z in range(int(b[1])+8,int(b[3])-5,spacing):
			# Stable irregular groups, with open lake views and public arrival axes.
			var p:=E.ground(x+sin(x*.17+z*.09)*7,z+cos(x*.13-z*.11)*6)
			if zone.environment_type=="scenic" and ((p.x>120 and p.z>45 and p.z<190) or (p.x< -120 and p.z>0 and p.z<95)):continue
			if not clear(p,6):continue
			var family:=absi(int(x/spacing)+int(z/spacing))%3
			var height: float=9 if zone.environment_type=="slope" else 6 if family==0 else 8 if family==1 else 4
			var radius: float=3.7 if family==0 else 1.4 if family==1 else 2.4
			families[family].append(Transform3D(Basis.IDENTITY.scaled(Vector3(radius,height*.38,radius)),p+Vector3.UP*height*.76))
			trunks.append(Transform3D(Basis.IDENTITY.scaled(Vector3(.25,height*.56,.25)),p+Vector3.UP*height*.28))
			if family==2:families[3].append(Transform3D(Basis.IDENTITY.scaled(Vector3(2,.6,1.5)),p+Vector3(3,.6,0)))
			stats.trees+=1
	# Fifth family is low planter vegetation, spatially different from canopy families.
	for i in families[2].size():
		var p: Vector3=families[2][i].origin
		families[4].append(Transform3D(Basis.IDENTITY.scaled(Vector3(1,.4,1)),E.ground(p.x-3,p.z)+Vector3.UP*.45))
	K.batch(root,trunks,Vector3.ONE,"977052")
	for family in 5:
		if families[family].is_empty():continue
		var mesh:=SphereMesh.new();mesh.radius=1;mesh.height=2;mesh.radial_segments=7;mesh.rings=3
		var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=mesh;mm.instance_count=families[family].size()
		for i in mm.instance_count:mm.set_instance_transform(i,families[family][i])
		var node:=MultiMeshInstance3D.new();node.name=["CanopyTrees","SlenderTrees","OrnamentalTrees","ShrubClusters","PlanterVegetation"][family]
		node.multimesh=mm;node.material_override=K.material(["688468","627b67","879469","6a825a","718660"][family]);root.add_child(node)
		if family>=3:node.visibility_range_end=180;node.visibility_range_end_margin=30

static func furniture(parent: Node3D) -> void:
	var root:=node(parent,"RouteFurniture",data.zones[0])
	var placed: Array[Vector3]=[]
	for r: Dictionary in data.routes:
		if r.category!="pedestrian":continue
		var pts:=points(r);var cadence:=60 if "lake" in r.id else 35 if "lower" in r.id or "library" in r.id else 45
		for i in range(pts.size()-1):
			var a: Vector3=pts[i];var b: Vector3=pts[i+1];var normal:=Vector3(b.z-a.z,0,a.x-b.x).normalized()
			for distance in range(12,int(a.distance_to(b))-5,cadence):
				var center:=a.lerp(b,distance/a.distance_to(b));var p:=center+normal*(r.width/2+3.3);p=E.ground(p.x,p.z)
				if not clear(p,1):continue
				var duplicate:=false
				for other: Vector3 in placed:
					if p.distance_to(other)<18:duplicate=true;break
				if duplicate:continue
				placed.append(p);E.lamp(root,p,"lake" in r.id);stats.lamps+=1
				if stats.lamps%3==0:
					var seat:=E.ground(p.x+normal.x*2.2,p.z+normal.z*2.2)
					if clear(seat,2):E.bench(root,seat);stats.benches+=1
				if stats.lamps%7==0:E.bin(root,p+Vector3(1.2,0,0))
	var signs: Dictionary={"upper_west":"上园书院 ←\nUpper Colleges\n神仙湖 → Fairy Lake","lake_junction":"神仙湖 ← Fairy Lake\n下园 → Lower Campus","music_entry":"音乐学院 ←\nSchool of Music\n体育设施 → Sports","lower_central":"图书馆 → Library\n学生中心 ↑ Student Centre","admin_entry":"行政楼 ↑ Administration\n会议中心 → Conference","shaw_entry":"逸夫书院 ↑ Shaw College\n下园 → Lower Campus"}
	for id: String in signs:
		var p:=G.point(id)+Vector3(7,0,5);p=E.ground(p.x,p.z)
		E.wayfinding(root,p,signs[id])
	E.bake(root)

static func landmarks(parent: Node3D,world: Node3D) -> void:
	var root:=node(parent,"LandmarkApproaches",data.zones[6])
	for id: String in ["lake_stone","reservoir_sign","lake_pavilion"]:
		var o: Dictionary=world.objects[id].get_meta("spatial_record");var p:=G.vec(o.center)
		E.patch(root,p,10 if id=="lake_pavilion" else 7,7,"Campus_LakePath",.35)
		if id=="reservoir_sign":
			E.box(root,p+Vector3(2,1.7,0),Vector3(1.05,3.4,.2),"Campus_SignLight")
			E.box(root,p+Vector3(2,2.8,.11),Vector3(.94,.55,.03),"547c96")
			E.label(root,p+Vector3(2,2.8,.14),"神仙岭水库",Color.WHITE,.0038)
			E.label(root,p+Vector3(2,1.6,.14),"管养房\n防汛仓库\n大坝\n溢洪道",Color("294d45"),.004)
		if id=="lake_pavilion":E.bench(root,E.ground(p.x+8,p.z+6),false);stats.benches+=1
	# Existing reference-inspired plaque is preserved in the frozen RC1 scene.
	# V3 reuses its visual vocabulary at an inferred Upper corridor location.
	var ling: Node3D=world.objects.ling;var p:=ling.position+Vector3(-6,0,ling.get_meta("spatial_record").footprint_depth/2)
	E.box(root,p+Vector3.UP*1.9,Vector3(.75,3.1,.12),"805549")
	E.label(root,p+Vector3(0,1.9,.09),"走\n路\n不\n看\n手\n机",Color("589075"),.007)
	for stop: Dictionary in data.stops:
		var s:=node(root,stop.id+"_environment",stop);s.set_meta("stop_id",stop.id);s.set_meta("boarding_point",G.vec(stop.boarding_point));s.set_meta("waiting_area",stop.waiting_area)
		var p:=G.vec(stop.position);E.patch(s,p,12,6,"Campus_Concrete",.36)
		E.wayfinding(s,p+Vector3(-4,0,-1),"校园接驳\nCampus Shuttle\n时刻信息待确认")
		E.bench(s,p+Vector3(3,0,-2));E.bin(s,p+Vector3(5,0,-2));stats.benches+=1
		for x in range(-5,6,2):E.patch(s,p+Vector3(x,0,4),1,1,"Campus_SignLight",.36)
		E.bake(s);stats.stops+=1
	E.bake(root)
