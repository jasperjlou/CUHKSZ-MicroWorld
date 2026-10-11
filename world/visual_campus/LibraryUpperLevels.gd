extends RefCounted
## Official 1–6F wayfinding plans establish voids and level relationships, not survey dimensions.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const L := preload("res://world/visual_campus/LandmarkBuildings.gd")

static func front(x: float,w: float,d: float) -> float:
	# Bent entrance-facing wing traced in relative plan proportions, fitted to retained anchors.
	var control:=PackedVector2Array([Vector2(-43,4),Vector2(-36,7),Vector2(-34,29),Vector2(-24,29),Vector2(-14,29),Vector2(-4,33),Vector2(8,25),Vector2(20,12),Vector2(31,8),Vector2(43,4)])
	var u:=clampf(x*86.0/w,-43,43)
	for i in range(control.size()-1):
		if u<=control[i+1].x:return lerpf(control[i].y,control[i+1].y,(u-control[i].x)/(control[i+1].x-control[i].x))*d/58.0
	return 4*d/58.0

static func side_x(z: float,w: float,d: float,side: int) -> float:
	var t:=clampf((z+d*.47)/(d*.47+front(w/2,w,d)),0,1)
	return side*(w/2-(1.5 if side<0 else 7.2)*sin(t*PI))

static func rear(w: float,d: float) -> PackedVector2Array:
	# Ordered from the non-pond end to the pond end. The rear V stays open above 3F.
	return PackedVector2Array([Vector2(w/2,-d*.47),Vector2(w*.27,-d*.50),Vector2(w*.22,-d*.24),Vector2(0,-d*.105),Vector2(-w*.22,-d*.225),Vector2(-w*.25,-d*.47),Vector2(-w/2,-d*.47)])

static func outline(w: float,d: float) -> PackedVector2Array:
	var p:=PackedVector2Array()
	for i in 49:
		var x: float=-w/2+i*w/48;p.append(Vector2(x,front(x,w,d)))
	var zf:=front(w/2,w,d)
	for i in range(1,29):
		var z:=lerpf(zf,-d*.47,i/28.0);p.append(Vector2(side_x(z,w,d,1),z))
	var back:=rear(w,d)
	for i in range(1,back.size()):p.append(back[i])
	for i in range(1,28):
		var z:=lerpf(-d*.47,zf,i/28.0);p.append(Vector2(side_x(z,w,d,-1),z))
	return p

static func roof_y(p: Vector2,w: float,d: float) -> float:
	var u:=p.x/(w/2)
	var edge:=26.0+1.9*u*u+.48*sin(u*PI*1.5)
	return lerpf(26.3,edge,clampf((p.y+d*.47)/(front(p.x,w,d)+d*.47),0,1))

static func sheet(b: Node3D,p: PackedVector2Array,y: float,hex: String,kind: int,solid: bool=false,roof: bool=false,w: float=86,d: float=58,downward: bool=false) -> void:
	var ids:=Geometry2D.triangulate_polygon(p);var v:=PackedVector3Array()
	for i in range(0,ids.size(),3):
		var a:=Vector3(p[ids[i]].x,roof_y(p[ids[i]],w,d) if roof else y,p[ids[i]].y)
		var c:=Vector3(p[ids[i+1]].x,roof_y(p[ids[i+1]],w,d) if roof else y,p[ids[i+1]].y)
		var e:=Vector3(p[ids[i+2]].x,roof_y(p[ids[i+2]],w,d) if roof else y,p[ids[i+2]].y)
		v.append_array(PackedVector3Array([a,e,c] if ((c-a).cross(e-a).y>0)!=downward else [a,c,e]))
	if not v.is_empty():K.surface(b,v,hex,kind,solid)

static func slab_piece(b: Node3D,outline_points: PackedVector2Array,rect: Rect2) -> void:
	var q:=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
	for clipped: PackedVector2Array in Geometry2D.intersect_polygons(outline_points,q):
		sheet(b,clipped,8.8,"b6b4a7",12,true)
		var ids:=Geometry2D.triangulate_polygon(clipped);var down:=PackedVector3Array()
		for i in range(0,ids.size(),3):
			var a:=Vector3(clipped[ids[i]].x,8.48,clipped[ids[i]].y);var c:=Vector3(clipped[ids[i+1]].x,8.48,clipped[ids[i+1]].y);var e:=Vector3(clipped[ids[i+2]].x,8.48,clipped[ids[i+2]].y)
			down.append_array(PackedVector3Array([a,c,e] if (c-a).cross(e-a).y>0 else [a,e,c]))
		if not down.is_empty():K.surface(b,down,"b2b4a9",15)

static func beam(b: Node3D,a: Vector3,c: Vector3,width: float,height: float,hex: String) -> void:
	K.box(b,(a+c)/2,Vector3(a.distance_to(c),height,width),hex,false,11,-atan2(c.z-a.z,c.x-a.x))

static func roof_shell(b: Node3D,w: float,d: float) -> void:
	# Roof strips end at the bent lantern edges. There is no hidden slab under its glazing.
	var polygon:=outline(w,d);var clips: Array[PackedVector2Array]=[]
	var core:=preload("res://world/visual_campus/LibraryServiceCores.gd")
	clips.append(core.rect_poly(Rect2(-150,-150,131,300)));clips.append(core.rect_poly(Rect2(24,-150,126,300)))
	var spine:=PackedVector2Array([Vector2(-19,2),Vector2(-5,-3),Vector2(10,-.5),Vector2(24,5)])
	for i in range(spine.size()-1):
		var a:=spine[i];var c:=spine[i+1]
		clips.append(PackedVector2Array([Vector2(a.x,-150),Vector2(c.x,-150),c-Vector2(0,4.2),a-Vector2(0,4.2)]))
		clips.append(PackedVector2Array([a+Vector2(0,4.2),c+Vector2(0,4.2),Vector2(c.x,150),Vector2(a.x,150)]))
	for clip in clips:
		for part: PackedVector2Array in Geometry2D.intersect_polygons(polygon,clip):
			sheet(b,part,0,"858b84",18,false,true,w,d)
			sheet(b,part,0,"d0d3c8",22,false,true,w,d,true)

static func lantern(b: Node3D) -> void:
	# Bent glazed ridge and solid folded end walls, read against the completed aerial.
	var spine: Array[Vector3]=[Vector3(-19,28.5,2),Vector3(-5,29.6,-3),Vector3(10,29.0,-.5),Vector3(24,28.2,5)]
	for i in range(spine.size()-1):
		var a:=spine[i];var c:=spine[i+1];var offset:=Vector3(0,-1.7,4.2)
		for side in [-1,1]:
			var shift:=Vector3(offset.x,offset.y,offset.z*side)
			K.surface(b,K.quad(a,c,c+shift,a+shift),"b3ced2",19)
			beam(b,a+shift,c+shift,.18,.24,"c6c9bd")
			for j in 12:
				var p:=a.lerp(c,j/11.0)
				var rib:=K.holder(b,"LanternRib",p+shift/2);rib.rotation.x=-atan2(shift.y,shift.z)
				K.box(rib,Vector3.ZERO,Vector3(.055,.06,shift.length()),"b3bab3",false,11);K.finish(rib)
			var bottom_a:=Vector3(a.x,roof_y(Vector2(a.x,a.z+shift.z),86,58),a.z+shift.z);var bottom_c:=Vector3(c.x,roof_y(Vector2(c.x,c.z+shift.z),86,58),c.z+shift.z)
			var wall:=PackedVector3Array([bottom_a,a+shift,c+shift,bottom_a,c+shift,bottom_c])
			wall.append_array(PackedVector3Array([bottom_a,c+shift,a+shift,bottom_a,bottom_c,c+shift]));K.surface(b,wall,"acb3a8",20)
		beam(b,a,c,.16,.18,"aab5af")
	for p: Vector3 in [spine[0],spine[-1]]:
		var end:=PackedVector3Array([p,p+Vector3(0,-1.7,-4.2),p+Vector3(0,-1.7,4.2),p,p+Vector3(0,-1.7,4.2),p+Vector3(0,-1.7,-4.2)])
		K.surface(b,end,"afb7ad",20)
		var a:=Vector3(p.x,roof_y(Vector2(p.x,p.z-4.2),86,58),p.z-4.2);var c:=Vector3(p.x,roof_y(Vector2(p.x,p.z+4.2),86,58),p.z+4.2)
		var sill:=K.quad(a,c,p+Vector3(0,-1.7,4.2),p+Vector3(0,-1.7,-4.2));var inner:=PackedVector3Array()
		for i in range(0,sill.size(),3):inner.append_array(PackedVector3Array([sill[i],sill[i+2],sill[i+1]]))
		K.surface(b,sill,"afb7ad",20);K.surface(b,inner,"d0d3c8",22)

static func build(b: Node3D,r: Dictionary,builder: RefCounted) -> void:
	var n:=K.holder(b,"LibraryPlanLevels");var w: float=r.width;var d: float=r.depth
	var lower_plan=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd");var p:PackedVector2Array=lower_plan.third_outline()
	preload("res://world/visual_campus/LibraryEntryLevels.gd").third_floor(n,p)
	# Infill stays at 3F only; higher levels retain the deep rear notch visible in plans 4/5.
	var terrace:PackedVector2Array=lower_plan.polygon3([[608,74],[764,74],[1013,329],[978,361],[887,272],[608,272]])
	sheet(n,terrace,8.8,"aaa795",6,true)
	for i in 3:
		var a:=Vector3(terrace[i].x,8.8,terrace[i].y);var c:=Vector3(terrace[i+1].x,8.8,terrace[i+1].y);beam(n,a+Vector3.UP*1.1,c+Vector3.UP*1.1,.08,.08,"62756b")
		for j in 9:K.box(n,a.lerp(c,j/8.0)+Vector3.UP*.54,Vector3(.05,1.08,.05),"62756b",false,11)
	for q in [[675,150],[800,250]]:
		var pos:Vector3=lower_plan.point3(q[0],q[1],8.8);K.bench(n,pos);K.planter(n,pos+Vector3(-2.1,0,-2.1))
	# Shallow reading bays are visible behind the 3F windows and on arrival from 2F.
	for x in [-27.0,26.0]:
		for z in [-16.0,-6.0,4.0]:
			K.box(n,Vector3(x,9.55,z),Vector3(6,.12,1.3),"a99571",false,4)
			for side in [-1,1]:K.box(n,Vector3(x+side*2.5,9.15,z),Vector3(.1,.7,.95),"68766e",false,11)
			for cx in [-1.8,0,1.8]:
				K.box(n,Vector3(x+cx,9.22,z+1),Vector3(.55,.08,.55),"8e6954",false,4)
				K.box(n,Vector3(x+cx,9.55,z+1.25),Vector3(.55,.65,.08),"8e6954",false,4)
				for lx in [-.21,.21]:
					for lz in [-.21,.21]:K.box(n,Vector3(x+cx+lx,9,z+1+lz),Vector3(.055,.4,.055),"607068",false,11)
	for x in [-17,18]:
		for z in [-1,5]:
			K.box(n,Vector3(x,9.65,z),Vector3(4.2,1.7,.8),"a39879",false,4)
			for row in 3:
				for j in 18:K.box(n,Vector3(x-1.9+j*.22,9.15+row*.45,z+.43),Vector3(.15,.34,.15),["6c7b75","8f785e","aa9673","6f6f72"][j%4],false,4)
	K.box(n,Vector3(-3.2,10.6,-5),Vector3(3.8,.7,.09),"546761",false,11)
	K.label(n,"3F · 开放研习",Vector3(-3.2,10.6,-4.93),.006)
	# Rear plinth and column bays make the low public frontage read as occupied space.
	K.box(n,Vector3(0,.032,-30.5),Vector3(88,.05,6.4),"aaa897",false,6)
	for x in [19,29,39]:
		K.column(n,Vector3(x,0,-26.5),8.6,.58)
		K.box(n,Vector3(x,4.32,-24.5),Vector3(7.8,.24,5.5),"a5aea2",false,6)
		K.box(n,Vector3(x,2.12,-25.4),Vector3(7.2,4.05,.12),"455c61",true,5)
		for dx in [-3.65,0,3.65]:K.box(n,Vector3(x+dx,2.12,-25.25),Vector3(.065,4.2,.08),"697c76",false,11)
		K.box(n,Vector3(x,6.65,-25.4),Vector3(7.2,4.2,.12),"546970",false,5)
	for x in [-7,7]:
		K.column(n,Vector3(x,0,-24),4.28,.55);K.bench(n,Vector3(x,0,-28))
	K.box(n,Vector3(0,4.28,-23.6),Vector3(15,.24,7),"abb2a7",false,6)
	preload("res://world/visual_campus/LibraryRearGlazing.gd").lower_entry(n)
	# Real upper slabs replace the previous full-width false ceiling over the atrium.
	preload("res://world/visual_campus/LibraryRegisteredUpper.gd").build(n)
	for x in [-27,27]:
		for z in [-18,-8,2,10]:K.box(n,Vector3(x,12.57,z),Vector3(5.5,.05,.11),"e0d4ae",false,17)
		var wing_light:=OmniLight3D.new();wing_light.position=Vector3(x,11.4,-15);wing_light.light_color=Color("f3ead5");wing_light.light_energy=.5;wing_light.omni_range=15;n.add_child(wing_light)
	for x in [-24,24]:
		K.box(n,Vector3(x,12.58,3.5),Vector3(.11,.05,8),"e0d4ae",false,17)
		var light:=OmniLight3D.new();light.position=Vector3(x,11.4,0);light.light_color=Color("f3ead5");light.light_energy=.45;light.omni_range=15;n.add_child(light)
	K.finish(n)
