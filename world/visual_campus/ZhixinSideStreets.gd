extends RefCounted
## V81 official aerial92544949: side road and parking behind the Zhixin wing.
## Topology/materials reference-led, all dimensions and bay positions fitted.
const K:=preload("res://world/visual_campus/VisualCampusKit.gd")
const R:=preload("res://world/visual_campus/LibraryRearRoad.gd")
const S:=preload("res://world/visual_campus/StartZoneLandscape.gd")
const V:=preload("res://world/visual_campus/CampusVegetation.gd")
const G:=2.24

static func build(root:Node3D,builder) -> void:
	var n:=K.holder(root,"ZhixinSideStreetsV81")
	for r:Dictionary in builder.data.routes:
		if not r.id in ["zhixin_shaw_end_branch","zhixin_rear_parking_access"]:continue
		builder.ribbon(n,r.points,r.width,"414b4c",32,.18)
		if r.id=="zhixin_shaw_end_branch":
			for side in [-1,1]:
				var walk:=R.offset(r.points,5.6 if side==1 else -5.8)
				# V216: terminate at the perimeter-road inner edge, not its centreline.
				for p:Array in walk:p[0]=maxf(float(p[0]),-170.35)
				if side==1:
					# V252: leave the photographed grass verge before the court wall.
					# This is visual paving only; the existing ground/rail collision stays.
					for j in range(walk.size()-1):
						var a:Array=walk[j].duplicate();var b:Array=walk[j+1].duplicate()
						var court_strip:bool=(float(a[0])+float(b[0]))*.5>=-66 and (float(a[0])+float(b[0]))*.5<=-22
						if court_strip:a[2]=-676.56;b[2]=-676.56
						builder.ribbon(n,[a,b],2.02 if court_strip else 2.35,"89877d" if court_strip else "918c7c",87 if court_strip else 65,.1595)
				else:
					# V253 photo222613: road kerb meets lawn here, not a parallel brick walk.
					# Keep the crossing and both ends; metres remain fitted.
					for j in range(walk.size()-1):
						var mid:float=(float(walk[j][0])+float(walk[j+1][0]))*.5
						if mid>-62 and mid<-24:continue
						builder.ribbon(n,[walk[j],walk[j+1]],2.0,"918c7c",65,.13)
				# The rear parking junction cuts both the kerb and its painted boundary.
				var edge:=R.offset(r.points,side*4.18)
				var run:Array=[]
				for p:Array in edge:
					if p[0]>-14:continue # rounded mouth owns this corner
					if (p[0]>-83 and p[0]<-69) or (side==1 and p[0]>-69 and p[0]<-25):
						if run.size()>1:builder.ribbon(n,run,.26,"bcc0b3",26,.20)
						run=[]
					else:run.append(p)
				if run.size()>1:builder.ribbon(n,run,.26,"bcc0b3",26,.20)
			for x in range(-165,-16,9):
				if abs(x+76)<10 or x>-27:continue
				K.box(n,Vector3(x,G+.20,-682),Vector3(3,.018,.12),"cbb356",false,22)
		else:
			# Keep the building-side walking strip separate from the car aisle.
			builder.ribbon(n,R.offset(r.points,-4.7),2.8,"a8aa9b",26,.13)
	# V82 the former parking row overlapped DaoYuan's corrected rear terrace.
	# Its service aisle remains; bays move to the source-observed basketball side.
	K.box(n,Vector3(-65.3,G+.105,-735),Vector3(6.6,.035,82),"a8aa9b",false,26)
	for x in [-107,-154]:S.street_lamp(n,Vector3(x,G,-676.2),1)
	# One crossing across the branch continues the established Main Square footway.
	# V87 crossing and tactile pads are built with the photographed guardrail openings.
	# An actual open mouth at the main road, rather than driving across decorative pavement.
	var north:Array=[];var south:Array=[]
	for i in 17:
		var t:float=float(i)/16
		var a:Vector2=Vector2(-14,-678).lerp(Vector2(-4.5,-678),t).lerp(Vector2(-4.5,-678).lerp(Vector2(-4.5,-670),t),t)
		var c:Vector2=Vector2(-4.5,-694).lerp(Vector2(-4.5,-686),t).lerp(Vector2(-4.5,-686).lerp(Vector2(-14,-686),t),t)
		north.append([a.x,G,a.y]);south.append([c.x,G,c.y])
	var outline:Array=north.duplicate();outline.append([2,G,-670]);outline.append([2,G,-694]);outline.append_array(south)
	var vertices:=PackedVector3Array();var centre:=Vector3(-4.5,G+.23,-682)
	for i in outline.size():
		var a:=Vector3(outline[i][0],G+.23,outline[i][2]);var j: int=(i+1)%outline.size();var c:=Vector3(outline[j][0],G+.23,outline[j][2])
		vertices.append_array(K.quad(centre,a,c,centre))
	K.surface(n,vertices,"414b4c",32)
	for edge:Array in [north,south]:builder.ribbon(n,edge,.14,"dee0d3",22,.247)
	K.finish(n)
	preload("res://world/visual_campus/OldLibraryStreet.gd").build(root,builder)
