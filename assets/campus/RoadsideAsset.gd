extends Node3D
const Kit := preload("res://world/MeshKit.gd")
@export_enum("curb","lamp") var asset_kind := "curb"
@export var segment_length := 2.0

func _ready() -> void:
	set_meta("source_reference_ids",["VR_116384446","VR_130095287"])
	set_meta("confidence",{"presence":"verified","dimensions":"inferred","placement":"inferred"})
	set_meta("authored_version","1.0.0-phase-b")
	if asset_kind == "curb":
		Kit.box(self,Vector3(0,0.08,0),Vector3(0.28,0.16,segment_length),Color("c2c3b4"))
	else:
		Kit.cylinder(self,Vector3(0,2.6,0),0.065,5.2,Color("acb5ad"))
		Kit.box(self,Vector3(0.6,5.15,0),Vector3(1.2,0.08,0.08),Color("acb5ad"))
		Kit.box(self,Vector3(1.2,5.10,0),Vector3(0.5,0.12,0.24),Color("445650"))
