extends RefCounted
## Continuous frontage from SC/Shaw to the old square and Research/Sports junction.
## Official map fixes adjacency; panorama 116443798 fixes paving and street character.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const V := preload("res://world/visual_campus/CampusVegetation.gd")
const S := preload("res://world/visual_campus/StartZoneLandscape.gd")
const G := 2.24

static func slab(b: Node3D,x: float,z: float,w: float,d: float,kind: int=6) -> void:
	K.box(b,Vector3(x,G+.081,z),Vector3(w,.028,d),"717978" if kind==6 else "a58473",false,kind)

static func tree_bed(b: Node3D,x: float,z: float,w: float,d: float,seed: int) -> void:
	K.box(b,Vector3(x,G+.10,z),Vector3(w,.15,d),"5c5845",false,4)
	V.shrub(b,Vector3(x,G+.20,z),Vector3(w-.3,.48,d-.3),seed)
	K.tree(b,Vector3(x,G+.13,z),10.3+float(seed%4)*.5,seed)

static func build(root: Node3D,builder) -> void:
	var b:=K.holder(root,"LowerCorridorV31")
	# The authored route and the visible paving share one polyline, including the turn.
	for r: Dictionary in builder.data.routes:
		if r.id in ["library_shaw_approach","shaw_west_approach","research_canopy_access","research_sports_walk"]:
			builder.ribbon(b,r.points,r.width,"737b7b",6,.069)
	# V75 owns the paver promenade, tree strip and side branch, avoiding duplicate beds.
	preload("res://world/visual_campus/ShawPromenade.gd").build(root,builder)
	# Garden edge stops at the underpass stair, leaving the straight route at x=30 open.
	for z in [-412,-455,-478]:
		tree_bed(b,21,z,5,7,absi(z)+6)
	for z in [-414,-476]:S.street_lamp(b,Vector3(35,G,z),1)
	for z in [-488,-519,-550]:
		if z<-500:continue # V84 water and its own planted banks occupy this old placeholder.
		tree_bed(b,21,z,7,9,absi(z)+120)
		tree_bed(b,-20,z-8,8,11,absi(z)+141)
	# V50 owns the continuous curved corner and its crossing/landscape.
	# StartZoneGrade owns the raised classroom courts and rear lane.
	# Research frontage: a shaded, edged approach and one continuous Sports Hall forecourt.
	slab(b,71,-840,26,62)
	slab(b,29,-853,65,9)
	# V63: beds follow the outside of the redirected road, not its carriageway/apron.
	for p: Vector2 in [Vector2(57,-793),Vector2(72,-791),Vector2(86,-789),Vector2(115,-790),Vector2(15,-825),Vector2(53,-870)]:
		tree_bed(b,p.x,p.y,6,8,absi(int(p.x+p.y)))
	tree_bed(b,37,-816,4,6,64816)
	for z in [-806,-825,-867]:
		S.street_lamp(b,Vector3(48 if z==-825 else 56,G,z),-1)
		S.grate(b,60,z)
	for z in [-817,-862]:K.bench(b,Vector3(78,G,z),PI/2)
	# Flush joint/drain bands unify previously disconnected rectangular paving pieces.
	for x in [60,82]:
		for interval: Vector2 in [Vector2(-811,-832),Vector2(-856,-870)]:
			S.strip(b,Vector2(x,interval.x),Vector2(x,interval.y),.18,.11,"596b60",11)
	for x in [8,24,39,54]:S.grate(b,x,-856.6,PI/2)
	K.finish(b)
