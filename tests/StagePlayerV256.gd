extends "res://tests/StageCameraV218.gd"
func op(x:float,z:float,y:float=0)->Vector3:return Vector3(-37.2+z,2.24+y,-733-x)
func shot(_label:String)->void:pass
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode;var label:String="first" if mode else "third"
		await fixture(Vector3(-60,2.24,-676.5),[Vector3(-44,2.24,-676.5),Vector3(-20.5,2.24,-676.5),Vector3(-20.5,2.24,-687.4),Vector3(-14,2.24,-687.4),Vector3(-10.2,2.24,-689.3),Vector3(-8.1,2.24,-693),Vector3(-8.1,2.24,-733),Vector3(-20,2.24,-733),Vector3(-44,2.24,-733)],label+"-street-court")
		await fixture(op(0,-7),[op(0,-10),op(-3.4,-10),op(-3.4,-15),op(-25.5,-15),op(-25.5,-18),op(-25.5,-20.5),op(-25.5,-18),op(-25.5,-15),op(-29.1,-15),op(-29.1,-20.5),op(-29.1,-15),op(-3.4,-15),op(-3.4,-10),op(0,-10),op(0,-7)],label+"-cozy-core")
	check("camera volumes clear",overlap_frames==0);check("body-to-camera segments clear",blocked_frames==0)
	FileAccess.open("res://tests/artifacts/stage_player_v256.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"scope":"V252-V255 street/court/cozy in two modes and endpoint rotations;not full campus"},"\t"))
	print("STAGE_PLAYER_V256 legs=",legs.size()," samples=",samples," errors=",errors);quit(0 if errors.is_empty() else 1)
