extends RefCounted
## WWJ aerial and courtyard ground view; plan dimensions remain fitted to the retained district.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const LOW := -1.76
const G := 2.24

static func build(parent: Node3D) -> void:
	var b:=K.holder(parent,"CourtyardObservedPublicSpaces")
	# Ground-level aprons sit below the new side galleries, outside the sunken terrain opening.
	# North edge now uses LibraryPoolFrontage's shore at Z=-336..-332.5.
	# The old Z=-331 decorative slab falsely covered water with a non-colliding floor.
	for z in [-400]:
		K.box(b,Vector3(32,G+.06,z),Vector3(47,.055,4.6),"b2b0a1",false,12)
		for side in [-1,1]:K.box(b,Vector3(32,G+.10,z+side*2.12),Vector3(46,.02,.16),"707b6c",false,15)
	# Lower arcade roof and rear room floor form a real occupied recess beneath the eastern rim.
	K.box(b,Vector3(47.55,2.05,-360),Vector3(11.5,.38,34),"b6b7ad",true,15)
	K.box(b,Vector3(50.75,LOW-.13,-360),Vector3(6,.26,34),"aaa99c",true,12)
	K.box(b,Vector3(53.65,.17,-360),Vector3(.25,3.86,34.2),"aaa99b",true,15)
	for z in [-377,-343]:K.box(b,Vector3(50.75,.17,z),Vector3(6,3.86,.25),"b5b3a4",true,15)
	# Retaining wall is split into glass bays and doorway piers; no hidden solid wall behind glazing.
	for interval: Vector2 in [Vector2(-380,-377),Vector2(-343,-338)]:
		K.box(b,Vector3(48.2,.24,(interval.x+interval.y)/2),Vector3(.40,4,interval.y-interval.x),"9a9e96",true,15)
	K.box(b,Vector3(48.2,2.28,-359),Vector3(.65,.16,42.7),"b9bdb1",false,15)
	for z in [-377,-370.2,-363.4,-356.6,-349.8,-343]:
		K.box(b,Vector3(41.7,LOW+1.90,z),Vector3(.45,3.8,.45),"a5afa1",true,22)
		K.box(b,Vector3(41.7,LOW+1.65,z),Vector3(.47,3.3,.47),"768577",false,7)
		K.box(b,Vector3(48.15,LOW+1.9,z),Vector3(.30,3.8,.30),"b6b6a5",true,22)
	# Two entrances occupy central bays; infill outside door openings remains collidable glass.
	for i in 5:
		var z: float=-373.6+i*6.8
		K.box(b,Vector3(48.02,1.78,z),Vector3(.25,.45,6.5),"aa986f",false,22)
		var door: bool=i in [1,3]
		for half in [-1,1]:
			var length: float=2.03 if door else 3.24
			var zz: float=z+half*(2.23 if door else 1.64)
			K.box(b,Vector3(48.12,LOW+1.66,zz),Vector3(.085,3.25,length),"66847a",true,19)
			for edge in [-1,1]:K.box(b,Vector3(48.02,LOW+1.66,zz+edge*length/2),Vector3(.15,3.30,.065),"4c5d52",false,11)
		K.box(b,Vector3(48.01,LOW+.12,z),Vector3(.14,.10,6.5),"4c5d52",false,11)
		if door:
			var leaf:=K.holder(b,"OpenLowerGalleryDoor",Vector3(48.6,LOW,z+1.15))
			K.box(leaf,Vector3(0,1.6,0),Vector3(1.1,3.2,.07),"78968b",false,19)
			K.box(leaf,Vector3(.4,1.1,.07),Vector3(.055,.9,.055),"a7b1a0",false,11);K.finish(leaf)
		else:K.bench(b,Vector3(43.9,LOW,z),PI/2)
		K.box(b,Vector3(45,1.78,z),Vector3(1.4,.07,.17),"e2dcc7",false,17)
		K.box(b,Vector3(50.8,1.77,z),Vector3(1.7,.07,.17),"e2dcc7",false,17)
	for z in [-373,-360,-347]:
		K.bench(b,Vector3(52.6,LOW,z),PI/2)
		var light:=OmniLight3D.new();light.position=Vector3(50.8,1.15,z);light.light_energy=.55;light.omni_range=7;light.light_color=Color("f2e7cd");b.add_child(light)
	# Architect aerial + ground view show one sunken rectangular lawn; upper tree lawns are separate.
	# Remove the former four invented tree boxes and cross-strips through this lawn.
	K.box(b,Vector3(27.25,LOW+.075,-363.5),Vector3(15.5,.15,21),"899385",true,26)
	K.box(b,Vector3(27.25,LOW+.165,-363.5),Vector3(15.16,.025,20.66),"728754",false,3)
	for x in [19.32,35.18]:K.box(b,Vector3(x,LOW+.018,-363.5),Vector3(.16,.022,21.4),"536057",false,11)
	for z in [-352.82,-374.18]:K.box(b,Vector3(27.25,LOW+.018,z),Vector3(16.02,.022,.16),"536057",false,11)
	# Wide seating terraces flank the regular stair; they are not substituted for its walking ramp.
	for i in 8:
		var top: float=G-(i+1)*.5;var thickness:=maxf(.12,top-LOW)
		K.box(b,Vector3(41.4,LOW+thickness/2,-338-(i+.5)*1.3),Vector3(8.4,thickness,1.31),"b6b6a7",true,15)
		K.box(b,Vector3(41.4,top+.045,-338-(i+.6)*1.3),Vector3(7.8,.09,.50),"ad9067",false,4)
		if i in [1,5]:K.planter(b,Vector3(44.8,top,-338-(i+.5)*1.3))
	# Drainage keeps the paving edge legible at the foot of the façade.
	K.box(b,Vector3(40.75,LOW+.025,-361),Vector3(.23,.035,30),"556354",false,11)
	for i in 100:K.box(b,Vector3(40.75,LOW+.048,-375.85+i*.30),Vector3(.21,.012,.035),"9eaa96",false,11)
	K.finish(b)
