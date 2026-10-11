extends RefCounted
## V80 named aerial92544949 and crossing70040607: tree-lined road outside garden.
## Absolute grade, lane width, junction radii and planting positions remain fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const L:=preload("res://world/visual_campus/LibraryRearRoad.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const S:=preload("res://world/visual_campus/StartZoneLandscape.gd")
const G:=2.24

static func fitted_height(x:float,z:float,base:float,points:Array) -> float:
	if x<37 or x>154 or z<-816 or z>-737 or points.is_empty():return base
	var p:=Vector2(x,z);var best:=100.0;var closest:=p
	for i in range(points.size()-1):
		var a:=Vector2(points[i][0],points[i][2]);var c:=Vector2(points[i+1][0],points[i+1][2])
		if a.y<-816 and c.y<-816:continue
		var d:=c-a;var t:=clampf((p-a).dot(d)/maxf(d.length_squared(),.0001),0,1)
		var distance:float=p.distance_to(a+d*t)
		if distance<best:best=distance;closest=a+d*t
	# Service road ties into the same upper garden level, then descends towards the tower.
	for pair:Array in [[Vector2(143,-737),Vector2(143,-760)],[Vector2(143,-760),Vector2(130,-781)],[Vector2(130,-781),Vector2(130,-816)]]:
		var a:Vector2=pair[0];var d:Vector2=pair[1]-a;var t:=clampf((p-a).dot(d)/d.length_squared(),0,1)
		var distance:float=p.distance_to(a+d*t)
		if distance<best:best=distance;closest=a+d*t
	var target:float=G+2.4*smoothstep(45,78,closest.x)*smoothstep(-815,-782,closest.y)*(1.0-smoothstep(-755,-735,closest.y))
	# Level road and footway cross sections. Blend only in the planted bank beyond them.
	var result:float=lerpf(target,base,smoothstep(6.9,9.0,best))
	# A continuous diagonal approach must cut its own grade across the planted bank.
	# Merely draping paving on the bank leaves a short steep break at the bottom.
	var top:=Vector2(62,-765);var toe:=Vector2(54,-773);var delta:=toe-top
	var t:=clampf((p-top).dot(delta)/delta.length_squared(),0,1)
	var gap:float=p.distance_to(top+delta*t)
	var toe_y:float=G+2.4*smoothstep(45,78,54)
	var approach_y:float=lerpf(4.64,toe_y,t)
	return lerpf(approach_y,result,smoothstep(1.6,2.6,gap))

static func band(root:Node3D,builder,points:Array,lo:float,hi:float,color:String,kind:int,lift:float,solid:bool=false,taper_ends:bool=false,soft_edges:bool=false) -> void:
	var left:=L.offset(points,lo);var right:=L.offset(points,hi);var vertices:=PackedVector3Array()
	var cols:=maxi(1,ceili((hi-lo)/.65))
	for i in range(points.size()-1):
		var a:=Vector2(points[i][0],points[i][2]);var c:=Vector2(points[i+1][0],points[i+1][2]);var rows:=maxi(1,ceili(a.distance_to(c)))
		var aa:=Vector2(left[i][0],left[i][2]);var ab:=Vector2(right[i][0],right[i][2])
		var ca:=Vector2(left[i+1][0],left[i+1][2]);var cb:=Vector2(right[i+1][0],right[i+1][2])
		for j in rows:
			for k in cols:
				var ps:Array[Vector3]=[]
				for uv:Vector2 in [Vector2(float(k)/cols,float(j)/rows),Vector2(float(k+1)/cols,float(j)/rows),Vector2(float(k+1)/cols,float(j+1)/rows),Vector2(float(k)/cols,float(j+1)/rows)]:
					var p:=aa.lerp(ab,uv.x).lerp(ca.lerp(cb,uv.x),uv.y)
					var rise:float=lift
					if soft_edges:rise=.008+lift*smoothstep(0,.5,minf(uv.x,1.0-uv.x)*(hi-lo))
					if taper_ends:
						var start:=Vector2(points[0][0],points[0][2]);var end:=Vector2(points[-1][0],points[-1][2])
						# Project along the centre line, so the whole entrance edge meets the floor.
						var begin_direction:Vector2=(Vector2(points[1][0],points[1][2])-start).normalized()
						var end_direction:Vector2=(end-Vector2(points[-2][0],points[-2][2])).normalized()
						rise=.008+lift*clampf(minf((p-start).dot(begin_direction),(end-p).dot(end_direction))/1.5,0,1)
					ps.append(Vector3(p.x,builder.height(p.x,p.y)+rise,p.y))
				vertices.append_array(K.quad(ps[0],ps[1],ps[2],ps[3]))
	K.surface(root,vertices,color,kind,solid)

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"GardenRearStreetV80");var route:Array=[]
	for r:Dictionary in builder.data.routes:
		if r.id=="east_crossroad":
			for p:Array in r.points:
				if p[2]>=-823:route.append(p)
	if route.size()<2:return
	# Ochre pedestrian paving, narrow stone kerb, dark gutter and white road edge.
	band(n,builder,route,3.8,6.8,"ac997b",34,.16,true,false,true)
	band(n,builder,route,3.5,3.78,"c0c2b3",26,.20)
	band(n,builder,route,3.15,3.48,"59615b",22,.155)
	band(n,builder,route,2.98,3.11,"dddfd1",22,.17)
	band(n,builder,route,-3.75,-3.5,"b9bdad",26,.20)
	# Two diagonal garden approaches fit the retained terrace; these are not surveyed ramps.
	for path:Array in [[[105,G,-765.5],[117,G,-770],[125,G,-775.6]],[[62,G,-765],[59,G,-770],[54,G,-773]]]:
		band(n,builder,path,-1.4,1.4,"b1aa96",26,.17,true,true)
	# Keep planting between the existing deck and road-side paving, away from approach mouths.
	for x in [69,79,89,99]:
		var z:float=-768.8;var y:float=builder.height(x,z)
		K.box(n,Vector3(x,y+.09,z),Vector3(3.0,.14,2.8),"57533e",false,8)
		K.tree(n,Vector3(x,y+.14,z),10.0,8000+x,2.2)
		V.shrub(n,Vector3(x,y+.14,z),Vector3(3,.55,2.5),8100+x)
	for p:Vector2 in [Vector2(111,-774.7),Vector2(73,-771.9)]:
		S.street_lamp(n,Vector3(p.x,builder.height(p.x,p.y)+.17,p.y),1)
	# Flush inlet geometry conforms to the local road level, rather than a floating box.
	for p:Vector2 in [Vector2(98,-776.9),Vector2(68,-774.5),Vector2(41.7,-804)]:
		var y:float=builder.height(p.x,p.y)+.16
		K.box(n,Vector3(p.x,y,p.y),Vector3(.85,.02,.4),"414a45",false,22)
		for j in 6:K.box(n,Vector3(p.x-.35+j*.14,y+.016,p.y),Vector3(.032,.018,.34),"929b8e",false,22)
	K.finish(n)
