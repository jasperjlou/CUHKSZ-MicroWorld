extends RefCounted
## Small magenta/coral flowering patches visible above the official mural wall.
## Species, exact bloom season and positions are not asserted.
const B:=preload("res://world/visual_campus/RearRoadBank.gd")
static func build(root:Node3D,builder)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng:=RandomNumberGenerator.new();rng.seed=194700371
	var count:=0
	for z in range(B.BANK_MIN+10,B.BANK_MAX-8,4):
		if absf(z-B.STAIR_Z)<3:continue
		var x:float=B.toe(z,builder.rear_route)+B.RUN+1.8
		for i in 30:
			var xx:float=x+rng.randf_range(-1.05,1.05);var zz:float=z+rng.randf_range(-1.5,1.5)
			var p:=Vector3(xx,builder.height(xx,zz)+rng.randf_range(.75,1.10),zz)
			var basis:=Basis.from_euler(Vector3(rng.randf_range(-.6,.6),rng.randf()*TAU,rng.randf_range(-.4,.4)))
			var tint:=Color("a44868").lerp(Color("d57b66"),rng.randf()*.65)
			for petal in 3:
				var a:float=petal*TAU/3
				var tip:=Vector3(cos(a)*.09,.025,sin(a)*.09)
				var side:=Vector3(-sin(a)*.045,0,cos(a)*.045)
				st.set_color(tint);st.add_vertex(p);st.add_vertex(p+basis*(tip-side));st.add_vertex(p+basis*(tip+side))
			count+=1
	st.generate_normals()
	var node:=MeshInstance3D.new();node.name="RearBankFlowerPatchesV194";node.mesh=st.commit();node.set_meta("fitted_bloom_clusters",count)
	var material:=StandardMaterial3D.new();material.vertex_color_use_as_albedo=true;material.roughness=1;material.cull_mode=BaseMaterial3D.CULL_DISABLED;node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(node)
