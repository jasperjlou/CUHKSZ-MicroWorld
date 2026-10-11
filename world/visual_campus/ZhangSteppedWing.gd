extends RefCounted
## V134: contour traced from the actual horizontal slab projection, not a rectangle.
## Uniform .4625 local fit pinned to the retained rear joint; not a global site registration.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const LEGACY:Array[Vector2]=[Vector2(-379,-229),Vector2(-336.5,-229),Vector2(-327.5,-212.5),Vector2(-334.1,-208.5),Vector2(-334.1,-191.9),Vector2(-350.3,-191.9),Vector2(-350.3,-178.1),Vector2(-334.1,-178.1),Vector2(-334.1,-141),Vector2(-379,-141)]
const FRONT:=16.26
static func outline(stepped:bool=true)->PackedVector2Array:
	var p:=PackedVector2Array()
	var shape:Array[Vector2]=[]
	shape.assign(LEGACY if stepped else [LEGACY[0],LEGACY[1],LEGACY[2],LEGACY[3],LEGACY[8],LEGACY[9]])
	for v:Vector2 in shape:p.append(Vector2(-34.3,-24.44)+(v-LEGACY[0])*.4625)
	return p
static func point(p:Vector2,y:float)->Vector3:return Vector3(p.x,y,p.y)
static func slab(n:Node3D,p:PackedVector2Array,y:float)->void:
	var indices:=Geometry2D.triangulate_polygon(p);var vertices:=PackedVector3Array();var bottom:=PackedVector3Array()
	for i in range(0,indices.size(),3):
		var a:=point(p[indices[i]],y+.125);var b:=point(p[indices[i+1]],y+.125);var c:=point(p[indices[i+2]],y+.125)
		if (b-a).cross(c-a).y>0:vertices.append_array(PackedVector3Array([a,c,b]))
		else:vertices.append_array(PackedVector3Array([a,b,c]))
		bottom.append_array(PackedVector3Array([vertices[-1]-Vector3.UP*.25,vertices[-2]-Vector3.UP*.25,vertices[-3]-Vector3.UP*.25]))
	K.surface(n,vertices,"b4b6ac",42,true);K.surface(n,bottom,"c0c2b8",22)
	for i in p.size():
		var a:=point(p[i],y);var c:=point(p[(i+1)%p.size()],y);var d:=c-a
		K.box(n,(a+c)/2,Vector3(d.length(),.25,.08),"b4b6ac",false,15,atan2(-d.z,d.x))
static func facade(n:Node3D,a:Vector2,c:Vector2,screened:bool)->void:
	var length:=a.distance_to(c);var count:=maxi(1,roundi(length/2.1));var bay:=length/count
	var yaw:=atan2(-(c.y-a.y),c.x-a.x);var basis:=Basis(Vector3.UP,yaw);var middle:=point((a+c)/2,0)
	var width:=minf(bay-.34,1.38 if screened else .82)
	for y in [4.8,8.5]:
		for i in count:
			var x:float=(i+.5)*bay-length/2
			for side in [-1,1]:
				var sw:float=(bay-width)/2
				K.box(n,middle+basis*Vector3(x+side*(width/2+sw/2),y+1.85,0),Vector3(sw,3.7,.30),"b7ad9e",true,15,yaw)
				K.box(n,middle+basis*Vector3(x,y+1.85+side*1.49,0),Vector3(width,.72,.30),"b7ad9e",true,15,yaw)
			K.window(n,middle+basis*Vector3(x,y+1.85,-.06),width,2.26,yaw+PI)
			var collider:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(width,2.26,.10)
			collider.shape=shape;collider.position=middle+basis*Vector3(x,y+1.85,-.06);collider.rotation.y=yaw;n.get_node("Solid").add_child(collider)
			if screened:
				for f in 4:K.box(n,middle+basis*Vector3(x-width/2+(f+.5)*width/4,y+1.85,-.22),Vector3(.055,2.26,.30),"94725b",false,4,yaw)
static func build(b:Node3D,stepped:bool=true)->void:
	var n:=K.holder(b,"ZhangSteppedLowWingV134" if stepped else "CShortLowWingV138");var p:=outline(stepped)
	for y in [4.8,8.5,12.2]:slab(n,p,y)
	# The fitted high return is .7 narrower at this end; close its exposed seam.
	K.box(n,Vector3(-33.95,8.5,-24.44),Vector3(.70,7.4,.30),"b7ad9e",true,15)
	for i in range(1,p.size()):
		var a:Vector2=p[i];var c:Vector2=p[(i+1)%p.size()]
		# Rear meets the existing high wing. The front has one shared public door
		# on both occupied levels, aligning to the retained photo-gallery bridge.
		if i==p.size()-2:
			facade(n,a,Vector2(-19.3 if stepped else -18.8,FRONT),false);facade(n,Vector2(-24.6,FRONT),c,false)
			for y in [4.8,8.5]:K.box(n,Vector3(-21.95 if stepped else -21.70,y+3.34,FRONT),Vector3(5.3 if stepped else 5.8,.72,.30),"b7ad9e",true,15)
		else:facade(n,a,c,i in [2,3,4,5,6,7])
		# Roof edge follows every notch; no bridge over the roof's open recess.
		var edges:Array=[[a,c]]
		if stepped and i==p.size()-2:edges=[[a,Vector2(-19.8,FRONT)],[Vector2(-23.2,FRONT),c]]
		for edge:Array in edges:
			var ea:Vector2=edge[0];var ec:Vector2=edge[1];var d:=ec-ea;var yaw:=atan2(-d.y,d.x)
			K.box(n,point((ea+ec)/2,12.84),Vector3(d.length(),1.02,.22),"b7ad9e",true,15,yaw)
			K.box(n,point((ea+ec)/2,13.38),Vector3(d.length()+.08,.06,.29),"bec0b3",false,15,yaw)
	# Recess floor-to-soffit beams and supports follow the actual stepped outline.
	for x in [-32,-25,-16]:
		for z in [-19,-10,4,12]:
			if Geometry2D.is_point_in_polygon(Vector2(x,z),p):K.column(n,Vector3(x,0,z),4.675,.50)
	# Historical roof green, inset within the continuous outer strip. No grass in public aisle.
	K.box(n,Vector3(-29.0,12.44,-3),Vector3(5.2,.23,27),"858a7d",true,15)
	K.box(n,Vector3(-29.0,12.57,-3),Vector3(4.9,.025,26.7),"72845a",false,2)
	K.finish(n)
