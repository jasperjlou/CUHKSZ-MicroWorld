extends RefCounted
## Official Road by Library / graffiti-wall / Shaw East road sequence.
## Road profile is fitted between retained anchors; panorama has no survey heights/date.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const S := preload("res://world/visual_campus/StartZoneLandscape.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const G := 2.24

static func fitted_height(x: float,z: float,base: float) -> float:
	if x<=117 or x>=158 or z<=-355 or z>=-198:return base
	# Carry the descent through the full avenue instead of dropping at the admin patch edge.
	var target: float=rear_avenue_height(z)
	var across: float=smoothstep(117,130,x)*(1.0-smoothstep(145,158,x))
	var join: float=1.0-smoothstep(-201,-198,z)
	return lerpf(base,target,across*join)

static func rear_avenue_height(z:float)->float:
	var prior:float=lerpf(G,14.64,clampf((z+330.0)/130.0,0,1))
	var weight:float=smoothstep(-355,-334,z)*(1.0-smoothstep(-292,-267,z))
	return lerpf(prior,6.16,weight)

static func rear_court_height(x:float,z:float,base:float)->float:
	# V208:2F staff door at world6.64, three fitted160mm treads above rear asphalt.
	# Only this local court is tied to the building; blend to retained avenue grades.
	var across:float=smoothstep(104.4,108,x)*(1.0-smoothstep(128,130,x))
	var along:float=smoothstep(-355,-334,z)*(1.0-smoothstep(-292,-267,z))
	return lerpf(base,6.16,across*along)

static func offset(points: Array,amount: float) -> Array:
	var out: Array=[]
	for i in points.size():
		var a:=Vector2(points[maxi(0,i-1)][0],points[maxi(0,i-1)][2])
		var c:=Vector2(points[mini(points.size()-1,i+1)][0],points[mini(points.size()-1,i+1)][2])
		var tangent: Vector2=(c-a).normalized();var normal:=Vector2(tangent.y,-tangent.x)
		out.append([points[i][0]+normal.x*amount,G,points[i][2]+normal.y*amount])
	return out

static func ribbon_outside(builder,parent: Node3D,points: Array,width: float,hex: String,kind: int,lift: float,holes: Array) -> void:
	# Keep original bends/miter joins, cutting only the observed apron or doorway mouths.
	var run: Array=[]
	for i in range(points.size()-1):
		var a:=Vector3(points[i][0],G,points[i][2]);var b:=Vector3(points[i+1][0],G,points[i+1][2])
		var cuts: Array[float]=[0.0,1.0]
		if absf(b.z-a.z)>.001:
			for hole: Vector2 in holes:
				for z: float in [hole.x,hole.y]:
					var t: float=(z-a.z)/(b.z-a.z)
					if t>0 and t<1 and not cuts.has(t):cuts.append(t)
		cuts.sort()
		for j in range(cuts.size()-1):
			var p:=a.lerp(b,cuts[j]);var q:=a.lerp(b,cuts[j+1]);var skip:=false
			for hole: Vector2 in holes:
				if (p.z+q.z)/2>hole.x and (p.z+q.z)/2<hole.y:skip=true
			if skip:
				if run.size()>1:builder.ribbon(parent,run,width,hex,kind,lift)
				run=[]
			else:
				if run.is_empty():run.append([p.x,G,p.z])
				run.append([q.x,G,q.z])
	if run.size()>1:builder.ribbon(parent,run,width,hex,kind,lift)

static func asphalt_grid(parent: Node3D,builder,x0: float,x1: float,z0: float,z1: float) -> void:
	# Broad ribbons only subdivide lengthwise: on this cross-slope their flat
	# cross section intersects terrain. A fine two-dimensional mesh follows it.
	var vertices:=PackedVector3Array()
	var nx:=ceili(x1-x0);var nz:=ceili(z1-z0)
	for i in nx:
		for j in nz:
			var a:=Vector2(lerpf(x0,x1,float(i)/nx),lerpf(z0,z1,float(j)/nz))
			var c:=Vector2(lerpf(x0,x1,float(i+1)/nx),lerpf(z0,z1,float(j+1)/nz))
			# V194 owns the tiny canopy-pad overlap at this service apron end.
			if (a.x+c.x)/2>=127 and (a.x+c.x)/2<134:
				c.y=minf(c.y,-247.2)
				if c.y<=a.y:continue
			var ps: Array[Vector3]=[]
			for p: Vector2 in [a,Vector2(c.x,a.y),c,Vector2(a.x,c.y)]:ps.append(Vector3(p.x,builder.height(p.x,p.y)+.09,p.y))
			vertices.append_array(K.quad(ps[0],ps[1],ps[2],ps[3]))
	K.surface(parent,vertices,"626361",32)

static func build(root: Node3D,builder) -> void:
	var n:=K.holder(root,"LibraryRearShawAvenue")
	var points: Array=[]
	for r: Dictionary in builder.data.routes:
		if r.id=="library_rear_shaw_avenue":points=r.points
	if points.is_empty():return
	# The model and minimap share one authoritative continuous back-road polyline.
	builder.ribbon(n,points,6,"555954",32,.126)
	var apron:=Vector2(-333,-247)
	for side in [-1,1]:
		var openings: Array=[apron] if side==1 else []
		if side==1:openings.append_array(preload("res://world/visual_campus/StudentRearSite.gd").openings())
		ribbon_outside(builder,n,offset(points,side*3.12),.25,"bdc1b7",6,.16,openings)
		ribbon_outside(builder,n,offset(points,side*2.82),.18,"555f5a",11,.137,openings)
	# Trees and lamps stay behind the pedestrian strip, not in its clear walking width.
	for i in range(points.size()-1):
		var a:=Vector2(points[i][0],points[i][2]);var c:=Vector2(points[i+1][0],points[i+1][2])
		var delta: Vector2=c-a;var tangent:=delta.normalized();var normal:=Vector2(tangent.y,-tangent.x)
		for distance in range(10,int(delta.length())-7,24):
			var p: Vector2=a+tangent*distance+normal*7.7
			# Keep the corrected rear pedestrian apron clear; landscape positions are fitted.
			if p.y>=-428 and p.y<=-335:p=a+tangent*distance-normal*7.7
			var y: float=builder.height(p.x,p.y)
			if p.y<-335 or p.y>-236:
				K.tree(n,Vector3(p.x,y,p.y),10.5,absi(int(p.y)),1.5)
				V.shrub(n,Vector3(p.x,y,p.y),Vector3(2.4,.55,4.5),absi(int(p.y))+700)
			S.street_lamp(n,Vector3(p.x-1.6,builder.height(p.x-1.6,p.y),p.y),-1)
		for distance in range(3,int(delta.length())-3,9):
			var p: Vector2=a+tangent*distance
			K.box(n,Vector3(p.x,builder.height(p.x,p.y)+.146,p.y),Vector3(.12,.018,3),"cdb965",false,22,atan2(tangent.x,tangent.y))
	# Official panorama 70037189: coarse asphalt forecourt, not a stone plaza.
	# Keep retained grade; camera imagery cannot establish surveyed road elevations.
	var service:=K.holder(n,"LibraryAsphaltServiceApron")
	asphalt_grid(service,builder,105,134,-333,-247)
	# The porch/steps remain stone and sit above this small asphalt infill at their foot.
	asphalt_grid(service,builder,103.9,105,-331,-306)
	# V180 stair-toe drain is built in the registered rear portal frame.
	K.finish(service)
	for r: Dictionary in builder.data.routes:
		if r.id=="library_rear_walk":
			ribbon_outside(builder,n,r.points,r.width,"838c8a",26,.086,[Vector2(-365,-247),Vector2(-247.2,-236.8),Vector2(-420,-366)])
		elif r.id=="shaw_rear_to_front":
			builder.ribbon(n,r.points,r.width,"838c8a",26,.086)
	preload("res://world/visual_campus/StudentRearSite.gd").build(n,builder)
	K.finish(n)
