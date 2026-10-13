extends RefCounted
## Scene116410029/pano70013463: wooded hill beyond the gate, edged hardscape.
## All distances, contours and planting counts are fitted, geographic north unresolved.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:float=2.24
static func rise(x:float,z:float)->float:
	return 26*smoothstep(204,280,-x)*(1-smoothstep(310,420,-x))*smoothstep(-320,-210,z)*(1-smoothstep(-130,-35,z))
static func wooded(x:float,z:float)->bool:
	return x< -204 and x> -420 and z> -320 and z< -35
static func paving(n:Node3D,builder,x0:float,x1:float,z0:float,z1:float,color:String,kind:int,lift:float)->void:
	var mesh:=PackedVector3Array()
	for x in range(floori(x0),ceili(x1),2):
		for z in range(floori(z0),ceili(z1),2):
			var a:=maxf(x,x0);var b:=minf(x+2,x1);var c:=maxf(z,z0);var d:=minf(z+2,z1)
			var points:Array[Vector3]=[Vector3(a,0,c),Vector3(b,0,c),Vector3(b,0,d),Vector3(a,0,d)]
			for i in 4:points[i].y=builder.height(points[i].x,points[i].z)+lift
			mesh.append_array(K.quad(points[0],points[1],points[2],points[3]))
	K.surface(n,mesh,color,kind)
static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"SouthGateContextV196")
	var trees:=K.holder(n,"OppositeWoodedHill")
	var rng:=RandomNumberGenerator.new();rng.seed=196700134
	var count:=0
	for z0 in range(-306,-44,10):
		for x0 in range(-406,-205,10):
			var x:float=x0+rng.randf_range(-2.8,2.8);var z:float=z0+rng.randf_range(-2.8,2.8)
			if rise(x,z)<.5:continue
			var h:float=builder.height(x,z) if x>=-220 else builder.backdrop_height(x,z)
			K.tree(trees,Vector3(x,h,z),rng.randf_range(9,16),196000+count,.9 if x< -250 else 1.5);count+=1
	K.finish(trees)
	for item:GeometryInstance3D in trees.find_children("*","GeometryInstance3D",true,false):item.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The source shows dense lower woodland, not exposed soil between tall trunks.
	# Share folded foliage geometry; small varied understory masses add no collision.
	var understory:=MultiMesh.new();understory.transform_format=MultiMesh.TRANSFORM_3D;understory.use_colors=true
	understory.mesh=preload("res://world/visual_campus/CampusForest.gd").crown_mesh()
	var entries:Array[Transform3D]=[];var lower_rng:=RandomNumberGenerator.new();lower_rng.seed=19613463
	for z0 in range(-306,-44,7):
		for x0 in range(-326,-204,7):
			var x:float=x0+lower_rng.randf_range(-1.2,1.2);var z:float=z0+lower_rng.randf_range(-1.2,1.2)
			if rise(x,z)<.5:continue
			var h:float=builder.height(x,z) if x>=-220 else builder.backdrop_height(x,z)
			var size:=Vector3(lower_rng.randf_range(4.2,5.6),lower_rng.randf_range(3.4,5.2),lower_rng.randf_range(4.2,5.6))
			entries.append(Transform3D(Basis(Vector3.UP,lower_rng.randf()*TAU)*Basis.from_scale(size),Vector3(x,h+size.y*.42,z)))
	understory.instance_count=entries.size()
	for i in entries.size():understory.set_instance_transform(i,entries[i]);understory.set_instance_color(i,Color(.76,.85,.68))
	var lower:=MultiMeshInstance3D.new();lower.name="LowWoodlandClusters";lower.multimesh=understory
	var material:=StandardMaterial3D.new();material.vertex_color_use_as_albedo=true;material.roughness=1;material.metallic_specular=.05;material.cull_mode=BaseMaterial3D.CULL_DISABLED
	lower.material_override=material;lower.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;n.add_child(lower)
	# Short continuation meets the retained x=-174 vehicle street at z=-180.
	# The extent is provisional; it does not assert the full perimeter alignment.
	paving(n,builder,-177.5,-170.5,-180,-144,"414b4c",2,.035)
	paving(n,builder,-181.5,-177.7,-244,-144,"979c96",31,.045)
	# South-gate pedestrian opening is kept flush and open.
	for span:Vector2 in [Vector2(-244,-183),Vector2(-174,-144)]:
		paving(n,builder,-177.9,-177.7,span.x,span.y,"b2b6af",26,.064)
		paving(n,builder,-181.5,-181.3,span.x,span.y,"b2b6af",26,.064)
		# Short graded rail sections follow the lowered outer street.
		for z0 in range(ceili(span.x),floori(span.y),3):
			var z1:float=minf(z0+3,span.y);var mid:float=(z0+z1)/2;var h:float=builder.height(-184,mid)
			K.box(n,Vector3(-184,h+.22,mid),Vector3(.45,.44,z1-z0),"93988e",true,26)
			K.box(n,Vector3(-184,h+.95,z0),Vector3(.08,1.46,.08),"424b44",false,11)
			for y in [.48,1.57]:K.box(n,Vector3(-184,h+y,mid),Vector3(.055,.055,z1-z0),"424b44",false,11)
			for z in range(z0,int(z1)):K.box(n,Vector3(-184,h+1,z),Vector3(.035,1.06,.035),"424b44",false,11)
			var body:=StaticBody3D.new();var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new()
			shape.size=Vector3(.12,1.6,z1-z0);collision.shape=shape;collision.position=Vector3(-184,h+.8,mid);body.add_child(collision);n.add_child(body)

	for z in range(-240,-142,8):
		if z> -186 and z< -170:continue
		V.shrub(n,Vector3(-187,builder.height(-187,z),z),Vector3(3.8,1.0,7.6),196900+absi(z))
		if z%16==0:K.tree(n,Vector3(-195,builder.height(-195,z),z),13+float(absi(z)%5),196700+absi(z))
	# Flush ties to the existing gate walkway, no high curb through the route.
	paving(n,builder,-184,-177.7,-183,-174,"979c96",31,.045)
	n.set_meta("forest_tree_count",count);n.set_meta("understory_cluster_count",entries.size());n.set_meta("source_scene",116410029)
	K.finish(n)
