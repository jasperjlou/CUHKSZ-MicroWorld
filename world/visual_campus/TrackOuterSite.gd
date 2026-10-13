extends RefCounted
## V176: anniversary aerial shows a raised field, planted outside bank and lower L-shaped street.
## 4 m relief, alignments/widths and tie-in grade are photographic fits, not survey.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const V=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const LOW:=-1.76
const ROAD:Array[Vector3]=[Vector3(-112,G,-960),Vector3(-134,1.24,-980),Vector3(-146,LOW,-1000),Vector3(-146,LOW,-1100),Vector3(-144.63,LOW,-1106.89),Vector3(-140.73,LOW,-1112.73),Vector3(-134.89,LOW,-1116.63),Vector3(-128,LOW,-1118),Vector3(110,LOW,-1118)]

static func half_width(i:int)->float:return 3.5 if i==0 else (6.5 if i==1 else 9.0)
static func normal(i:int)->Vector2:
	var before:=ROAD[i]-ROAD[maxi(0,i-1)];var after:=ROAD[mini(ROAD.size()-1,i+1)]-ROAD[i]
	var d:Vector2=(Vector2(before.x,before.z).normalized()+Vector2(after.x,after.z).normalized()).normalized()
	return Vector2(-d.y,d.x)
static func edge(i:int,amount:float,lift:float)->Vector3:
	var n:=normal(i);return ROAD[i]+Vector3(n.x*amount,lift,n.y*amount)
static func walk_point(i:int)->Vector3:return edge(i,half_width(i)+5.8,.10)

static func fitted_height(x:float,z:float,base:float)->float:
	if z> -944 or x>150:return base
	var lx:float=x+14;var lz:float=z+1030
	var radius:=Vector2(maxf(absf(lx)-42.195,0),lz).length()
	var outside:float=maxf(1-smoothstep(-12,8,lz),1-smoothstep(-74,-50,lx))*(1-smoothstep(58,78,lz))
	var mask:float=smoothstep(-210,-190,x)*(1-smoothstep(120,150,x))
	var result:float=base-4*smoothstep(54.2,73.5,radius)*outside*mask
	# Grade the actual street and both sidewalks continuously, including the campus tie-in.
	var p:=Vector2(x,z);var best:=10000.0;var target:=base;var width:=9.0;var segment:=0;var station:=0.0
	for i in ROAD.size()-1:
		var a:=Vector2(ROAD[i].x,ROAD[i].z);var c:=Vector2(ROAD[i+1].x,ROAD[i+1].z);var d:=c-a
		var t:=clampf((p-a).dot(d)/d.length_squared(),0,1);var gap:=p.distance_to(a+d*t)
		if gap<best:best=gap;segment=i;station=t
	# Use the same shared cross-sections as the ribbons. Nearest-centreline
	# projection alone jumps in height across a bend when adjacent grades differ.
	var a:=Vector2(ROAD[segment].x,ROAD[segment].z);var c:=Vector2(ROAD[segment+1].x,ROAD[segment+1].z)
	var d:=c-a;var v:=p-a;var n0:=normal(segment);var dn:=normal(segment+1)-n0
	var qa:float=d.cross(dn);var qb:float=v.cross(dn)-d.cross(n0);var qc:float=v.cross(n0)
	for iteration in 4:
		var derivative:float=qb-2*qa*station
		if absf(derivative)<.00001:break
		station=clampf(station-(qc+qb*station-qa*station*station)/derivative,0,1)
	target=lerpf(ROAD[segment].y,ROAD[segment+1].y,station);width=lerpf(half_width(segment),half_width(segment+1),station)
	return preload("res://world/visual_campus/SportsCorner.gd").fitted_height(x,z,lerpf(target,result,smoothstep(width+8,width+13,best)))

static func cell(builder,x:float,nx:float,z:float,nz:float)->PackedVector3Array:
	var out:=PackedVector3Array();var pitch:float=.75 if z> -1010 and x< -90 else 1.5
	var sx:=maxi(1,ceili((nx-x)/pitch));var sz:=maxi(1,ceili((nz-z)/pitch))
	for i in sx:
		for j in sz:
			var a:=lerpf(x,nx,float(i)/sx);var c:=lerpf(x,nx,float(i+1)/sx)
			var u:=lerpf(z,nz,float(j)/sz);var w:=lerpf(z,nz,float(j+1)/sz)
			out.append_array(K.quad(Vector3(a,builder.height(a,u),u),Vector3(c,builder.height(c,u),u),Vector3(c,builder.height(c,w),w),Vector3(a,builder.height(a,w),w)))
	return out

static func ribbon(n:Node3D,builder,left_extra:float,right_extra:float,side:int,color:String,kind:int,lift:float,solid:bool=false)->void:
	var vertices:=PackedVector3Array()
	for i in ROAD.size()-1:
		var lo0:float=side*half_width(i)+left_extra;var hi0:float=side*half_width(i)+right_extra
		var lo1:float=side*half_width(i+1)+left_extra;var hi1:float=side*half_width(i+1)+right_extra
		if side==0:lo0=-half_width(i);hi0=half_width(i);lo1=-half_width(i+1);hi1=half_width(i+1)
		var count:=maxi(1,ceili(ROAD[i].distance_to(ROAD[i+1])))
		var across:=maxi(1,ceili(maxf(hi0-lo0,hi1-lo1)/1.5)) if i<2 else 1
		for j in count:
			for k in across:
				var quad:Array[Vector3]=[]
				for uv:Vector2 in [Vector2(float(k)/across,float(j)/count),Vector2(float(k+1)/across,float(j)/count),Vector2(float(k+1)/across,float(j+1)/count),Vector2(float(k)/across,float(j+1)/count)]:
					var p:=edge(i,lerpf(lo0,hi0,uv.x),0).lerp(edge(i+1,lerpf(lo1,hi1,uv.x),0),uv.y)
					p.y=builder.height(p.x,p.z)+preload("res://world/visual_campus/SportsCorner.gd").crossing_lift(p.x,p.z,lift);quad.append(p)
				vertices.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	K.surface(n,vertices,color,kind,solid)

static func paint(n:Node3D,builder,offset:float,width:float,dashed:bool,color:String)->void:
	var out:=PackedVector3Array()
	for i in ROAD.size()-1:
		var count:=maxi(1,ceili(ROAD[i].distance_to(ROAD[i+1])))
		for j in count:
			if dashed and j%7>=3:continue
			var midpoint:=ROAD[i].lerp(ROAD[i+1],(float(j)+.5)/count)
			if midpoint.x> -110 and midpoint.x< -103 and midpoint.z< -1110:continue
			if dashed and absf(offset)+width>lerpf(half_width(i),half_width(i+1),float(j)/count)-.4:continue
			var quad:Array[Vector3]=[]
			for uv:Vector2 in [Vector2(0,float(j)/count),Vector2(1,float(j)/count),Vector2(1,float(j+1)/count),Vector2(0,float(j+1)/count)]:
				var p:=edge(i,offset+(uv.x-.5)*width,0).lerp(edge(i+1,offset+(uv.x-.5)*width,0),uv.y)
				p.y=builder.height(p.x,p.z)+.075;quad.append(p)
			out.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	K.surface(n,out,color,22)

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"TrackOuterBankStreetV176")
	ribbon(n,builder,0,0,0,"424b4b",2,.045,true)
	# Flat stone/cycle strips are walkable; shallow kerbs separate them from traffic.
	ribbon(n,builder,.20,3.10,1,"596660",2,.10,true)
	ribbon(n,builder,3.20,4.20,1,"526b3d",3,.10)
	ribbon(n,builder,4.30,7.30,1,"959b98",26,.10,true)
	ribbon(n,builder,-3.5,-.20,-1,"959b98",26,.10,true)
	for side in [-1,1]:ribbon(n,builder,-.12,.12,side,"a4aa9e",26,.14)
	# Continuous double yellow centre; white lane dashes, all draped to the street grade.
	for offset:float in [-.14,.14]:paint(n,builder,offset,.09,false,"c5b36b")
	for offset:float in [-4.5,4.5]:paint(n,builder,offset,.10,true,"d7d9ca")
	for i in ROAD.size()-1:
		var length:float=ROAD[i].distance_to(ROAD[i+1])
		# Tree/plant divider outside the cycle strip; trunks do not occupy the pedestrian line.
		if length>35:
			for k in range(1,int(length/13)):
				var t:=float(k*13)/length;var p:=edge(i,half_width(i)+3.7,0).lerp(edge(i+1,half_width(i+1)+3.7,0),t)
				p.y=builder.height(p.x,p.z)+.10;K.tree(n,p,6.0,1760+i*30+k)
	# Approximate planted bank masses, tied to the new terrain. No construction huts made permanent.
	for i in 25:
		var x:float=-106+i*8;var z:float=-1091-2*sin(i*.8)
		if x>86:continue
		if preload("res://world/visual_campus/SportsCorner.gd").sign_bank(x,z):continue
		var y:float=builder.height(x,z)
		V.shrub(n,Vector3(x,y+.06,z),Vector3(5.8,.6,4.6),17600+i)
		if i%2==0:K.tree(n,Vector3(x,y,z-2.8),6.8,17700+i)
	for z in range(-1020,-1080,-10):
		var x:float=-119;var y:float=builder.height(x,z)
		V.shrub(n,Vector3(x,y+.06,z),Vector3(5,.7,7),absi(z)+176)
	K.finish(n)
