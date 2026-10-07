extends Node3D
func _ready() -> void:
	var world: Node3D=load("res://world/campus_master/CampusMaster.tscn").instantiate();add_child(world)
	var qa:=Node.new();qa.set_script(load("res://tests/ExteriorBaselineQA.gd"));qa.world=world;world.add_child(qa)
