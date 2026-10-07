extends Node3D
## Reusable public door, kinematic visual motion rather than a physics hinge.
const I:=preload("res://world/campus_seamless/InteriorKit.gd")
enum Type {OPEN_STATIC,AUTO_SLIDE,PUSH_VISUAL,EVENT_LOCKED}
var door_type: Type=Type.OPEN_STATIC
var leaves: Array[MeshInstance3D]=[]
var amount:=0.0
var open:=false
signal opening

func _ready() -> void:
	set_meta("door_type",Type.keys()[door_type])
	if door_type==Type.OPEN_STATIC:return
	for side in [-1,1]:leaves.append(I.box(self,Vector3(side*1.28,2.15,0),Vector3(2.5,4.3,.15),"glass_bluegray",true))
	if door_type==Type.EVENT_LOCKED:I.lettering(self,"暂未开放",Vector3(0,3,.2),.012)

func update(player_position: Vector3,delta: float) -> void:
	var p:=to_local(player_position)
	var wanted: bool=absf(p.x)<8 and absf(p.z)<9 and door_type!=Type.EVENT_LOCKED
	if wanted and not open:opening.emit()
	open=wanted;amount=move_toward(amount,1.0 if open else 0.0,delta*3)
	for j in leaves.size():
		var leaf: MeshInstance3D=leaves[j];var side: int=-1 if j==0 else 1
		leaf.position.x=side*(1.28+amount*2.6) if door_type==Type.AUTO_SLIDE else side*1.28
		leaf.rotation.y=side*amount*PI*.45 if door_type==Type.PUSH_VISUAL else 0.0
		leaf.get_child(0).collision_layer=0 if open or amount>.01 else 1
