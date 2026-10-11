extends RefCounted
## V117: long rising stone forecourt + short broad stair, read against anniversary2023 and plans.
## Heights/lengths are fitted. Keep G/2F datum; do not translate the whole library into terrain.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Core=preload("res://world/visual_campus/LibraryServiceCores.gd")
const HALF_WIDTH=6.8
const TOP=1.2
const FOOT=9.2
const END=38.0
const FOOT_Y=2.0
const END_Y=.135

static func origin()->Vector3:return P.point2(1174.5,710)
static func along()->Vector3:return (P.point2(1274,610)-P.point2(1075,810)).normalized()
static func outward()->Vector3:
	var a:=along();return Vector3(-a.z,0,a.x)
static func point(x:float,z:float,y:float)->Vector3:return origin()+along()*x+outward()*z+Vector3.UP*y
static func coords(p:Vector2)->Vector2:
	var delta:=Vector3(p.x,0,p.y)-origin();return Vector2(delta.dot(along()),delta.dot(outward()))
static func surface_y(z:float)->float:
	if z<=TOP:return 4.4
	if z<=FOOT:return lerpf(4.4,FOOT_Y,(z-TOP)/(FOOT-TOP))
	return lerpf(FOOT_Y,END_Y,clampf((z-FOOT)/(END-FOOT),0,1))
static func ceiling_y(p:Vector2)->float:
	var q:=coords(p)
	return minf(4.12,surface_y(q.y)-.28) if absf(q.x)<=HALF_WIDTH and q.y>TOP else 4.12
static func local_poly(polygon:PackedVector2Array)->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in polygon:result.append(coords(p))
	return result
static func building_poly(polygon:PackedVector2Array)->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in polygon:
		var q:=point(p.x,p.y,0);result.append(Vector2(q.x,q.z))
	return result
static func cut_upper_floor(polygon:PackedVector2Array)->Array[PackedVector2Array]:
	# The complete library2F deck must not fill the exterior stair opening above116.
	var local:=local_poly(polygon);var result:Array[PackedVector2Array]=[]
	for rect in [Rect2(-200,-200,200-HALF_WIDTH,400),Rect2(HALF_WIDTH,-200,200-HALF_WIDTH,400),Rect2(-HALF_WIDTH,-200,HALF_WIDTH*2,200+TOP)]:
		for part:PackedVector2Array in Geometry2D.intersect_polygons(local,Core.rect_poly(rect)):result.append(building_poly(part))
	return result
static func closed_stack_ceiling(n:Node3D,polygon:PackedVector2Array)->void:
	var local:=local_poly(polygon)
	# Piecewise planar soffit and matching side upstands. No occupied room is filled with earth.
	for rect in [Rect2(-200,-200,200-HALF_WIDTH,400),Rect2(HALF_WIDTH,-200,200-HALF_WIDTH,400),Rect2(-HALF_WIDTH,-200,HALF_WIDTH*2,200+TOP),Rect2(-HALF_WIDTH,TOP,HALF_WIDTH*2,FOOT-TOP),Rect2(-HALF_WIDTH,FOOT,HALF_WIDTH*2,200-FOOT)]:
		for part:PackedVector2Array in Geometry2D.intersect_polygons(local,Core.rect_poly(rect)):
			var vertices:=PackedVector3Array();var idx:=Geometry2D.triangulate_polygon(part)
			var covered:bool=is_equal_approx(rect.position.x,-HALF_WIDTH) and rect.position.y>0
			for j in range(0,idx.size(),3):
				var tri: Array[Vector3]=[]
				for k in 3:
					var q:=part[idx[j+k]];tri.append(point(q.x,q.y,surface_y(q.y)-.28 if covered else 4.12))
				# Interior soffit is visible/collidable from below.
				if (tri[1]-tri[0]).cross(tri[2]-tri[0]).y<0:tri.reverse()
				vertices.append_array(PackedVector3Array(tri))
			# Close the soffit as a shallow slab; its top remains below the walking ramp.
			var solid:=vertices.duplicate()
			for i in range(0,vertices.size(),3):
				var a:=vertices[i];var b:=vertices[i+1];var c:=vertices[i+2];var lift:=Vector3.UP*.12
				solid.append_array(PackedVector3Array([a+lift,c+lift,b+lift]))
				for edge:Array in [[a,b],[b,c],[c,a]]:
					var u:Vector3=edge[0];var v:Vector3=edge[1]
					solid.append_array(PackedVector3Array([u,v,v+lift,u,v+lift,u+lift]))
			var roof:=K.surface(n,solid,"bfc2b6",22,true)
			roof.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	# Close each side exactly at polygon intersections; sampled short boxes left end pinholes.
	for side in [-1,1]:
		var x:float=side*HALF_WIDTH;var zs:Array[float]=[]
		for i in local.size():
			var a:=local[i];var b:=local[(i+1)%local.size()]
			if (a.x-x)*(b.x-x)>0 or absf(b.x-a.x)<.00001:continue
			zs.append(lerpf(a.y,b.y,(x-a.x)/(b.x-a.x)))
		if zs.size()<2:continue
		zs.sort();var lo:=maxf(TOP,zs[0]);var hi:=zs[-1]
		if hi<=lo:continue
		var cuts:Array[float]=[lo,hi]
		if FOOT>lo and FOOT<hi:cuts.append(FOOT)
		cuts.sort()
		for i in range(cuts.size()-1):
			var u:float=cuts[i];var v:float=cuts[i+1]
			var a:=point(x,u,surface_y(u)-.28);var b:=point(x,v,surface_y(v)-.28)
			var c:=point(x,v,4.12);var d:=point(x,u,4.12)
			var upstand:=K.surface(n,PackedVector3Array([a,b,c,a,c,d,a,c,b,a,d,c]),"bfc2b6",22,true)
			upstand.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED

static func ribbon(n:Node3D,z0:float,z1:float,half0:float,half1:float,y0:float,y1:float,solid:bool=true)->void:
	K.surface(n,K.quad(point(-half0,z0,y0),point(half0,z0,y0),point(half1,z1,y1),point(-half1,z1,y1)),"a9afa7",26,solid)
static func wall(n:Node3D,a:Vector3,b:Vector3)->void:
	var low_a:=Vector3(a.x,.02,a.z);var low_b:=Vector3(b.x,.02,b.z)
	var mesh:=PackedVector3Array([low_a,a,b,low_a,b,low_b,a,low_a,b,b,low_a,low_b])
	K.surface(n,mesh,"a5aba2",26,true)
static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibrarySourceAlignedOutdoorApproachV117")
	var a:=along();var yaw:float=-atan2(a.z,a.x)
	ribbon(n,-.08,TOP,HALF_WIDTH,HALF_WIDTH,4.4,4.4)
	# Thirteen broad stone treads; physical ramp follows the same endpoints.
	var count:=13;var run:float=(FOOT-TOP)/count;var rise:float=(4.4-FOOT_Y)/count
	for i in count:
		var z:float=TOP+(i+.5)*run;var y:float=4.4-i*rise
		K.box(n,point(0,z,y-.045),Vector3(HALF_WIDTH*2,.09,run+.012),"b5b8af",false,26,yaw)
		K.box(n,point(0,z+run/2,y-rise/2),Vector3(HALF_WIDTH*2,rise,.07),"a8aea5",false,26,yaw)
		# Short dark anti-slip inserts repeat across the width, as seen on the built stone steps.
		for x in [-5.6,-3.2,-.8,1.6,4.0,6.1]:K.box(n,point(x,z+run/2-.045,y+.004),Vector3(.38,.014,.065),"747e77",false,11,yaw)
	var walking:=K.surface(n,K.quad(point(-HALF_WIDTH,TOP,4.4),point(HALF_WIDTH,TOP,4.4),point(HALF_WIDTH,FOOT,FOOT_Y),point(-HALF_WIDTH,FOOT,FOOT_Y)),"b5b8af",26,true);walking.visible=false
	# Broad gently rising mall approach, rather than a freestanding diagonal stair.
	ribbon(n,FOOT,END,HALF_WIDTH,9.0,FOOT_Y,END_Y)
	ribbon(n,END,END+1.5,9.0,9.0,END_Y,0)
	for side in [-1,1]:
		wall(n,point(side*HALF_WIDTH,TOP,4.4-.14),point(side*HALF_WIDTH,FOOT,FOOT_Y-.14))
		wall(n,point(side*HALF_WIDTH,FOOT,FOOT_Y-.14),point(side*9.0,END,END_Y))
		# Side handrail follows the short stair; no crossrail obstructs either opening.
		for i in 9:
			var z:float=lerpf(TOP,FOOT,float(i)/8);var y:=surface_y(z)
			K.box(n,point(side*(HALF_WIDTH-.12),z,y+.52),Vector3(.05,1.04,.05),"7f897f",false,11,yaw)
		var rail:=K.holder(n,"ShortEntryHandrail",point(side*(HALF_WIDTH-.12),(TOP+FOOT)/2,(4.4+FOOT_Y)/2+1.07));rail.rotation.y=yaw;rail.rotation.x=atan2(4.4-FOOT_Y,FOOT-TOP)
		K.box(rail,Vector3.ZERO,Vector3(.06,.065,Vector2(FOOT-TOP,4.4-FOOT_Y).length()),"7f897f",false,11);K.finish(rail)
	# Photo-visible paired planting at the stairs, kept clear of the central pedestrian lane.
	for side in [-1,1]:
		var pos:=point(side*5.35,5.2,surface_y(5.2))
		K.box(n,pos+Vector3.UP*.35,Vector3(1.2,.7,1.2),"8d9589",false,26,yaw)
		K.tree(n,pos+Vector3.UP*.5,4.4,1170+side,1.15)
	for i in 7:
		var z:float=FOOT+2.8+i*3.8;var half:float=lerpf(HALF_WIDTH,9.0,(z-FOOT)/(END-FOOT))
		K.box(n,point(0,z,surface_y(z)+.012),Vector3(half*2,.018,.12),"7a857b",false,11,yaw)
		for side in [-1,1]:round_pot(n,point(side*(half-.65),z,surface_y(z)))
	preload("res://world/visual_campus/LibraryEntryLawn.gd").build(n,point, surface_y)
	K.finish(n)

static func round_pot(n:Node3D,p:Vector3)->void:
	# Anniversary view shows low pots with clipped rounded foliage, not timber crates.
	var pot:=MeshInstance3D.new();var cylinder:=CylinderMesh.new()
	cylinder.top_radius=.40;cylinder.bottom_radius=.28;cylinder.height=.46;cylinder.radial_segments=16
	pot.mesh=cylinder;pot.material_override=K.material("92998a",22);pot.position=p+Vector3.UP*.23;n.add_child(pot)
	var shrub:=MeshInstance3D.new();var crown:=SphereMesh.new();crown.radius=.55;crown.height=1.1;crown.radial_segments=20;crown.rings=12
	shrub.mesh=crown;shrub.material_override=K.material("536e3d",22);shrub.position=p+Vector3.UP*.99;n.add_child(shrub)
