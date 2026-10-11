extends RefCounted
## User photographs 20261010_222336/346: lower stone path beside a retained railed platform.
## Route bends and all metre heights are fitted to the existing East Gate frame.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const F:=preload("res://world/visual_campus/ZhangPhotoFront.gd")
const G:=2.24
const LOW:=1.04

static func main_route() -> Array[Vector3]:
	return [Vector3(-29,G,-443),Vector3(-29,2.10,-449),Vector3(-29,1.68,-459),Vector3(-29,LOW,-477),Vector3(-34,LOW,-482),Vector3(-48,LOW,-484),Vector3(-68,LOW,-487),Vector3(-76,LOW,-493)]

static func pavilion_route() -> Array[Vector3]:
	return [Vector3(-29,LOW,-477),Vector3(-20,1.39,-484),Vector3(-8,G,-490),Vector3(0,G,-491)]

static func projected(route:Array[Vector3],p:Vector2) -> Vector2:
	var result:=Vector2(100000,G)
	for i in route.size()-1:
		var a:=Vector2(route[i].x,route[i].z);var c:=Vector2(route[i+1].x,route[i+1].z)
		var t:float=clampf((p-a).dot(c-a)/(c-a).length_squared(),0,1)
		var distance:float=p.distance_to(a.lerp(c,t))
		if distance<result.x:result=Vector2(distance,lerpf(route[i].y,route[i+1].y,t))
	return result

static func fitted_height(x:float,z:float,base:float) -> float:
	if x<-86 or x>5 or z>-441 or z<-501:return base
	# Preserve the building-side high platform until its retaining wall ends.
	if z>-477 and z<-444 and x<-32.50:return base
	var p:=Vector2(x,z);var a:=projected(main_route(),p);var c:=projected(pavilion_route(),p)
	var nearest:Vector2=a if a.x<c.x else c
	if nearest.x>7.5:return base
	return lerpf(nearest.y,base,smoothstep(2.3,7.5,nearest.x))

static func path(n:Node3D,builder,route:Array[Vector3],width:float,kind:int=26,color:String="92968b",offset:float=0) -> void:
	var vertices:=PackedVector3Array()
	var joins:Array[Vector3]=[]
	for i in route.size():
		var before:Vector3=route[i]-route[maxi(0,i-1)];var after:Vector3=route[mini(route.size()-1,i+1)]-route[i]
		before.y=0;after.y=0
		if before.length_squared()<.001:before=after
		if after.length_squared()<.001:after=before
		var left:=Vector3(-before.z,0,before.x).normalized();var right:=Vector3(-after.z,0,after.x).normalized()
		var bisector:Vector3=(left+right).normalized()
		joins.append(bisector/maxf(.55,bisector.dot(right)))
	for i in route.size()-1:
		var a:Vector3=route[i];var c:Vector3=route[i+1];var delta:=c-a;delta.y=0
		var count:int=maxi(1,ceili(delta.length()))
		for j in count:
			var t:float=float(j)/count;var tt:float=float(j+1)/count
			var right:Vector3=joins[i].lerp(joins[i+1],t);var end_right:Vector3=joins[i].lerp(joins[i+1],tt)
			var p:=a.lerp(c,t)+right*offset;var q:=a.lerp(c,tt)+end_right*offset
			var corners:Array[Vector3]=[p-right*width/2,p+right*width/2,q+end_right*width/2,q-end_right*width/2]
			for k in corners.size():corners[k].y=builder.height(corners[k].x,corners[k].z)+.075
			vertices.append_array(K.quad(corners[0],corners[1],corners[2],corners[3]))
	K.surface(n,vertices,color,kind,false) # The fitted continuous terrain is the walking collision.

static func lamp(n:Node3D,p:Vector3) -> void:
	K.box(n,p+Vector3.UP*1.85,Vector3(.13,3.7,.13),"454d47",false,11)
	for side in [-1,1]:K.box(n,p+Vector3(side*.13,3.28,0),Vector3(.045,.78,.065),"e7e5d0",false,17)
	K.box(n,p+Vector3(0,3.70,0),Vector3(.30,.055,.09),"e7e5d0",false,17)

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"ZhangWoodlandDescentV86")
	var route:=main_route();path(n,builder,route,4.4)
	path(n,builder,pavilion_route(),3.6)
	for side in [-1,1]:path(n,builder,route,.12,26,"aaa99c",side*2.24)
	# A narrow planted drain lies below the straight building-side retaining face.
	for z in range(-446,-477,-2):
		var low:float=builder.height(-32.2,z)
		K.box(n,Vector3(-32.38,(G+low)/2,z),Vector3(.24,maxf(.16,G-low),2.04),"a2a192",true,22)
		K.box(n,Vector3(-32.38,G+.04,z),Vector3(.36,.12,2.04),"b8b5a8",false,22)
		V.shrub(n,Vector3(-31.92,low+.08,z),Vector3(.58,.27,1.95),8600+absi(z))
	F.rail(n,Vector3(-32.4,G+.10,-461),30,PI/2)
	K.box(n,Vector3(-35.2,G+.035,-461),Vector3(5.4,.065,32),"a5a28f",false,26)
	# End wall closes the platform into the sloped planted bank; no unsupported hanging edge.
	K.box(n,Vector3(-35.2,(G+LOW)/2,-477.1),Vector3(5.5,G-LOW,.22),"a2a192",true,22)
	F.rail(n,Vector3(-35.2,G+.1,-477.1),5.5)
	# Staggered mature trunks, overlapping crowns, and low soil/leaf-litter patches.
	for i in 7:
		var z:float=-448-i*4.7
		for side in [-1,1]:
			var x:float=-32.0 if side<0 else -23.1+sin(i*1.9)*.7
			var zz:float=z+(1.6 if side>0 else 0)
			var y:float=builder.height(x,zz)
			K.tree(n,Vector3(x,y,zz),11.5+float(i%3)*1.2,8610+i*7+side,2.8)
			if side>0:
				var patch:=PackedVector3Array()
				for ring in 8:
					for j in 32:
						var corners:Array[Vector3]=[]
						for polar:Vector2 in [Vector2(ring,j),Vector2(ring+1,j),Vector2(ring+1,j+1),Vector2(ring,j+1)]:
							var angle:float=polar.y*TAU/32;var radius:float=polar.x/8
							var p:=Vector3(x+cos(angle)*1.55*radius,0,zz+sin(angle)*1.8*radius)
							p.y=builder.height(p.x,p.z)+.026;corners.append(p)
						patch.append_array(K.quad(corners[0],corners[1],corners[2],corners[3]))
				K.surface(n,patch,"746e52",8)
	for i in 5:
		var x:float=-15.5+(i%2)*3;var z:float=-453-i*6.1
		if x>-22 and x<-12 and z>-469 and z<-449:continue # V126 lower-service stair aperture, not planted ground.
		K.tree(n,Vector3(x,builder.height(x,z),z),12.2,8690+i,2.5)
		V.shrub(n,Vector3(x,builder.height(x,z),z),Vector3(3.1,.55,2.2),8770+i)
	for z in [-448,-460,-473]:lamp(n,Vector3(-25.8,builder.height(-25.8,z),z))
	# Low-level court approach joins the revised side stair without crossing the front guard.
	path(n,builder,[Vector3(-76,LOW,-493),Vector3(-74,LOW,-493)],3.2)
	K.finish(n)
