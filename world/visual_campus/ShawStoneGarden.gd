extends RefCounted
## V248: official2025 brochure PDFp4/printed03-04. Photo capture date unknown.
## Registered stone identity only; retained world placement and all dimensions fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")

static func triangle(v:PackedVector3Array,a:Vector3,b:Vector3,c:Vector3,out:Vector3)->void:
	# Godot clockwise front faces. Orient every side away from the stone centre.
	if (b-a).cross(c-a).dot(out)>0:v.append_array(PackedVector3Array([a,c,b]))
	else:v.append_array(PackedVector3Array([a,b,c]))

static func rock(n:Node3D)->void:
	var outline:Array[Vector2]=[Vector2(-3.12,.12),Vector2(-3.35,.50),Vector2(-3.15,1.22),Vector2(-2.72,1.84),Vector2(-1.92,2.10),Vector2(-.85,2.18),Vector2(.45,2.13),Vector2(1.65,2.03),Vector2(2.55,1.70),Vector2(3.02,1.18),Vector2(3.20,.48),Vector2(3.05,.12)]
	var centre:=Vector3(0,1.10,.70);var back:=Vector3(0,1.05,-.85)
	var mesh:=PackedVector3Array()
	for i in outline.size():
		var p:Vector2=outline[i];var q:Vector2=outline[(i+1)%outline.size()]
		var a:=Vector3(p.x,p.y,.28);var b:=Vector3(q.x,q.y,.28)
		var af:=Vector3(p.x*.86,1.10+(p.y-1.10)*.85,.70)
		var bf:=Vector3(q.x*.86,1.10+(q.y-1.10)*.85,.70)
		var ar:=Vector3(p.x*.90,1.05+(p.y-1.05)*.92,-.72)
		var br:=Vector3(q.x*.90,1.05+(q.y-1.05)*.92,-.72)
		triangle(mesh,centre,af,bf,Vector3.FORWARD*-1)
		triangle(mesh,af,a,b,(a+b)/2-Vector3(0,1.1,-.5))
		triangle(mesh,af,b,bf,(a+b)/2-Vector3(0,1.1,-.5))
		triangle(mesh,a,ar,br,(a+b)/2-Vector3(0,1.1,.28))
		triangle(mesh,a,br,b,(a+b)/2-Vector3(0,1.1,.28))
		triangle(mesh,back,br,ar,Vector3.FORWARD)
	var stone:=K.surface(n,mesh,"a3aaa2",84,true);stone.name="RoundedShawStoneV248"
	stone.set_meta("source","2025 brochure PDF4; photo date unknown; fitted shape")

static func blade(st:SurfaceTool,a:Vector3,tip:Vector3,width:float,tint:Color)->void:
	var d:Vector3=tip-a;var across:=d.cross(Vector3.UP).normalized()*width
	if across.length_squared()<.000001:across=Vector3.RIGHT*width
	var mid:Vector3=a.lerp(tip,.46)+Vector3.UP*.055
	for p:Vector3 in [a,mid-across,tip,a,tip,mid+across]:
		st.set_color(tint);st.set_uv(Vector2(.5,.5));st.add_vertex(p)

static func cycad(n:Node3D,st:SurfaceTool,p:Vector3,seed:int)->void:
	var rng:=RandomNumberGenerator.new();rng.seed=seed
	V.branch(n,p,p+Vector3.UP*.64,.14)
	for i in 17:
		var angle:float=i*2.39996;var dir:=Vector3(cos(angle),0,sin(angle))
		var side:=Vector3(-dir.z,0,dir.x);var length:float=rng.randf_range(1.10,1.70)
		var start:Vector3=p+Vector3.UP*.58
		var previous:Vector3=start
		for j in range(1,17):
			var t:float=float(j)/16
			var q:Vector3=start+dir*(length*t)+Vector3.UP*(sin(t*PI*.9)*.64-t*.20)
			V.branch(n,previous,q,.009);previous=q
			var leaf_length:float=sin(t*PI)*.32+.055
			for s:float in [-1,1]:
				blade(st,q,q+side*s*leaf_length+dir*.11-Vector3.UP*.025,.023,Color("35513a").lerp(Color("677c45"),rng.randf()*.55))

static func planting(n:Node3D)->void:
	V.setup()
	# Layered yellow-green front groundcover and dark-red accents, observed around stone.
	for i in 23:
		var a:float=PI*float(i)/22;var p:=Vector3(cos(a)*4.65,.16,sin(a)*1.56)
		V.shrub(n,p,Vector3(.82,.26,.58),24800+i)
		V.queue_instance(n,"leaf",Transform3D(Basis.from_scale(Vector3(.65,.28,.55)),p+Vector3.UP*.22),Color(1.50,1.27,.60))
	for p:Vector3 in [Vector3(-3.65,.15,.45),Vector3(-4.4,.15,-.35)]:
		for j in 7:
			var a:float=j*2.39996
			V.queue_instance(n,"leaf",Transform3D(Basis(Vector3.UP,a)*Basis.from_scale(Vector3(.52,.65,.52)),p+Vector3(cos(a)*.35,.55,sin(a)*.3)),Color(1.25,.52,.72))
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	cycad(n,st,Vector3(4.0,.16,-.20),2481)
	cycad(n,st,Vector3(-4.65,.16,-.60),2482)
	# Fine arching border leaves; stay inside the retained elliptical garden footprint.
	for i in 16:
		var a:float=PI*float(i)/15;var p:=Vector3(cos(a)*5.05,.16,sin(a)*1.48)
		for j in 11:
			var t:float=j*2.39996+i*.35
			blade(st,p,p+Vector3(cos(t)*.32,.30+float(j%4)*.055,sin(t)*.25),.025,Color("748549"))
	st.generate_normals();var leaves:=MeshInstance3D.new();leaves.name="CycadAndBorderLeavesV248";leaves.mesh=st.commit();leaves.material_override=V.leaf_material;n.add_child(leaves)
	# All plants are visual; the stone retains a real mesh collider.
