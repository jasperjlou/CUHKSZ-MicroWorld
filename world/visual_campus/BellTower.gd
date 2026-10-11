extends RefCounted
## V63: photographed fourteen eaves; metric dimensions and base registration are fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const P := preload("res://world/visual_campus/ShawEastPodium.gd")

static func eave(b: Node3D,y: float,width: float) -> void:
	# Shallow upturned outer edge, with an underside and fascia, not a solid storey.
	var vertices:=PackedVector3Array()
	for side in 4:
		var basis:=Basis(Vector3.UP,side*PI/2)
		for strip in 5:
			var t0:=strip/5.0;var t1:=(strip+1)/5.0
			var z0:=2.0+(width/2-2.0)*t0;var z1:=2.0+(width/2-2.0)*t1
			var w0:=z0;var w1:=z1
			var q:=K.quad(basis*Vector3(-w0,y+.22*t0*t0,z0),basis*Vector3(w0,y+.22*t0*t0,z0),basis*Vector3(w1,y+.22*t1*t1,z1),basis*Vector3(-w1,y+.22*t1*t1,z1))
			vertices.append_array(q)
			for j in range(0,q.size(),3):vertices.append_array(PackedVector3Array([q[j]-Vector3.UP*.18,q[j+2]-Vector3.UP*.18,q[j+1]-Vector3.UP*.18]))
		var edge:=K.holder(b,"EaveEdge",Vector3.ZERO);edge.rotation.y=side*PI/2
		K.box(edge,Vector3(0,y+.12,width/2),Vector3(width,.2,.08),"d9d9cd",false,22)
		K.finish(edge)
	K.surface(b,vertices,"d9d9cf",22)

static func build(b: Node3D) -> void:
	# V64: the garden approaches on stepped terraces, not across a vehicle road.
	# Raised entry datum is a photo proportion fit; side street flights remain at ground.
	K.box(b,Vector3(0,.9,0),Vector3(14,1.8,14),"a0a59d",true,26)
	# Dark glazed lower enclosure with grey structural columns and an overhanging canopy.
	K.box(b,Vector3(0,4.45,0),Vector3(7.6,7.7,7.6),"485957",true,19)
	for x in [-4.6,4.6]:
		for z in [-4.6,4.6]:K.box(b,Vector3(x,4.45,z),Vector3(.65,7.7,.65),"858c87",true,22)
	for side in 4:
		var face:=K.holder(b,"BaseFacade");face.rotation.y=side*PI/2
		for x in [-3.8,-1.3,1.3,3.8]:K.box(face,Vector3(x,4.35,3.88),Vector3(.09,7.5,.14),"b5bab0",false,11)
		K.box(face,Vector3(0,3.4,3.9),Vector3(7.8,.18,.18),"a9b0a6",false,11)
		K.finish(face)
	eave(b,8.5,14)
	# Two visible outside flights reach a guarded back landing. Its Research bridge is unresolved.
	K.box(b,Vector3(0,2.7,-10),Vector3(22,5.4,6),"929990",true,22)
	K.box(b,Vector3(0,5.45,-10),Vector3(22,.1,6),"a8aea4",true,26)
	for x in [-9.0,9.0]:P.stair(b,Vector3(x,0,7),Vector3(x,5.5,-7),3.5)
	P.rail(b,Vector3(-11,5.5,-13),Vector3(11,5.5,-13))
	for x in [-11.0,11.0]:P.rail(b,Vector3(x,5.5,-13),Vector3(x,5.5,-7))
	P.rail(b,Vector3(-7,5.5,-7),Vector3(7,5.5,-7))
	# Open gold frame, dark centre, visible alternating stair flights and fourteen tapering eaves.
	K.box(b,Vector3(0,29.75,0),Vector3(1.8,42.5,1.8),"565947",false,22)
	K.box(b,Vector3(0,29.75,0),Vector3(4.1,42.5,.18),"b69d4d",false,22)
	for x in [-2.3,2.3]:
		for z in [-2.3,2.3]:K.box(b,Vector3(x,29.75,z),Vector3(.5,42.5,.5),"c7a529",false,22)
	for i in 14:
		var y:=12.2+i*3.0;var width:=lerpf(10.5,7.4,i/13.0)
		eave(b,y,width)
		for side in 4:
			var face:=K.holder(b,"TowerGallery");face.rotation.y=side*PI/2
			K.box(face,Vector3(0,y+.67,width/2-.28),Vector3(width-.6,.055,.055),"bbc4b5",false,11)
			for j in 9:K.box(face,Vector3(lerpf(-width/2+.4,width/2-.4,j/8.0),y+.35,width/2-.28),Vector3(.04,.65,.04),"a5b09f",false,11)
			if side%2==0 and i<13 and i%2==side/2:
				for j in 18:
					var t:float=j/17.0
					K.box(face,Vector3(lerpf(-1.9,1.9,t if i%2==0 else 1.0-t),y+.15+t*3,2),Vector3(.26,.13,.72),"bda441",false,22)
			if side%2==1 and i<13:
				for j in 15:K.box(face,Vector3(-1.7+j*.24,y+1.55,2.25),Vector3(.07,2.7,.08),"b5a043",false,11)
			K.finish(face)
	# Screened crown. No clock face is visible in the reference photographs.
	for side in 4:
		var face:=K.holder(b,"CrownScreen");face.rotation.y=side*PI/2
		K.box(face,Vector3(0,52.7,1.6),Vector3(3.2,2.8,.04),"a89543",false,11)
		for j in 13:K.box(face,Vector3(-1.6+j*.267,52.7,1.65),Vector3(.07,3,.1),"c6a637",false,11)
		for y in [51.3,52.7,54.1]:K.box(face,Vector3(0,y,1.65),Vector3(3.4,.09,.11),"c6a637",false,11)
		K.finish(face)
	K.finish(b)
