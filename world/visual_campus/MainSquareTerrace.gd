extends RefCounted
## V78: Main Square back/left/right views show an uninterrupted central lawn,
## with an end flight towards Shaw; the other end joins TowerPlaza short garden flights.
## Do not superimpose a new classroom stair on that existing garden. Metric sizes fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const P:=preload("res://world/visual_campus/ShawEastPodium.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24
const RISE:=2.4

static func fitted_height(x:float,z:float,base:float) -> float:
	if x<11.8 or x>142 or z<-780 or z>-631:return base
	var profile:float=smoothstep(-780,-770,z)*(1.0-smoothstep(-638,-631,z))
	var front:float=smoothstep(39.8,40.2,x)
	var ends:float=clampf((z+660)/12,0,1)
	return base+RISE*maxf(front,ends*smoothstep(15.8,16.2,x))*(1.0-smoothstep(134,142,x))*profile

static func build(root:Node3D) -> void:
	var n:=K.holder(root,"MainSquareEndStairsV78")
	# V143: stop the old broad terrace finish at the registered Shaw ground footprint.
	var west:=preload("res://world/visual_campus/ShawWestPlan.gd")
	var cuts:Dictionary=west.terrain_breaks()
	var xs:Array[float]=[40.2,134.0];var zs:Array[float]=[-767.0,-638.0]
	for x:float in cuts.x:
		if x>40.2 and x<134 and not xs.has(x):xs.append(x)
	for z:float in cuts.z:
		if z>-767 and z<-638 and not zs.has(z):zs.append(z)
	xs.sort();zs.sort()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var x:float=(xs[i]+xs[i+1])/2;var z:float=(zs[j]+zs[j+1])/2
			if not west.cutout(x,z):K.box(n,Vector3(x,G+RISE+.044,z),Vector3(xs[i+1]-xs[i],.06,zs[j+1]-zs[j]),"ac8676",false,7)
	# One lower lawn, replacing the three transverse stair cuts and their stone aprons.
	K.box(n,Vector3(26,G+.063,-703),Vector3(27,.045,86),"789265",false,3)
	for x in [12.4,39.6]:K.box(n,Vector3(x,G+.092,-703),Vector3(.18,.04,86),"b2b7a9",false,26)
	# The central retaining wall is continuous. No fabricated opening halfway across the lawn.
	K.box(n,Vector3(40,G+RISE/2,-715),Vector3(.52,RISE,110),"a6a392",true,26)
	K.box(n,Vector3(40,G+RISE+.06,-715),Vector3(.8,.12,110),"babbaa",false,26)
	# Upper wall-side path reaches both narrow classroom end doors.
	K.box(n,Vector3(42.6,G+RISE+.089,-704),Vector3(4.2,.022,112),"b2afa0",false,26)
	for data:Array in [[-660.0,-648.0,-643.0]]:
		var stair:=K.holder(n,"LawnEndFlight",Vector3(27,G,0))
		P.stair(stair,Vector3(0,0,data[0]),Vector3(0,RISE,data[1]),20)
		K.finish(stair)
		K.box(n,Vector3(30.1,G+RISE+.045,data[2]),Vector3(27.8,.06,10),"b1b3a7",false,26)
		var toe:float=data[0]+(-2 if data[0]>-700 else 2)
		K.box(n,Vector3(20,G+.079,toe),Vector3(24,.03,4),"b1b3a7",false,26)
		# Low verge planting remains at street level outside the raised flight.
		for i in 5:
			var t:float=(i+.5)/5;var z:float=lerpf(data[0],data[1],t)
			V.shrub(n,Vector3(14.3,G+.08,z),Vector3(2.4,.48,2),7800+i+absi(int(data[0])))
	# Sparse young trees at the wall edge leave the central field open in the reference view.
	for z in [-680,-719]:K.tree(n,Vector3(38.3,G,z),6.0,7800+absi(z),.9)
	# Upper passages retained; classroom and LeTian entrances stay on the upper terrace.
	for z in [-697]:K.box(n,Vector3(85,G+RISE+.083,z),Vector3(88,.022,6),"a88b79",false,7)
	for z in [-706,-716]:K.bench(n,Vector3(85,G+RISE,z),PI/2)
	K.finish(n)
