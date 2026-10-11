extends RefCounted
## Rectilinear TA court/side paths from the ROCCO plans. All metric registration is fitted.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func paving(n: Node3D,x0: float,x1: float,z0: float,z1: float,finish: int=40) -> void:
	K.box(n,Vector3((x0+x1)/2,.065,(z0+z1)/2),Vector3(x1-x0,.035,z1-z0),"91978f" if finish==12 else "a2a69d",false,finish)

static func drain(n: Node3D,a: Vector2,c: Vector2) -> void:
	var delta:=c-a;var length:=delta.length();var yaw:=atan2(-delta.y,delta.x)
	K.box(n,Vector3((a.x+c.x)/2,.09,(a.y+c.y)/2),Vector3(length,.022,.28),"687269",false,11,yaw)
	for i in int(length/.22):
		var p:=a.lerp(c,(i+.5)*.22/length)
		K.box(n,Vector3(p.x,.108,p.y),Vector3(.045,.012,.24),"a9afa2",false,11,yaw)

static func build(b: Node3D,r: Dictionary) -> void:
	var n:=K.holder(b,"RectilinearCourtAndPerimeter")
	var shift: float=(float(r.depth)-47)*.46
	var front: float=22.09+shift
	var rear: float=front-(float(r.depth)-2.82)
	# Grey slab field continues below all four pilotis; leave no default lawn in the court.
	paving(n,-38,38,rear-1,front+1,12)
	# Both long sides and the rear strip join without cutting through classroom walls.
	paving(n,-42,-38,rear-5,front+15)
	paving(n,38,42,rear-5,front+15)
	paving(n,-42,42,rear-5,rear-1)
	for side in [-1,1]:drain(n,Vector2(side*37.7,rear-1),Vector2(side*37.7,front))
	drain(n,Vector2(-35,rear-1.4),Vector2(35,rear-1.4))
	# A clear central passage below the rear bar; flanking glazed bays remain recesses.
	paving(n,-5,5,rear-5,rear+18,12)
	for x in [-4.6,4.6]:K.box(n,Vector3(x,.105,rear+6.5),Vector3(.14,.018,22),"747b70",false,15)
	# Join the entrance-left rear stair landing at world (-54,-71.5), outside the TA corner.
	var gate_local_z: float=-54-float(r.position[0])
	paving(n,-45.5,-38,rear-5,gate_local_z+2)
	# Downstream return reaches the existing A/B inter-block avenue at world Z=-167.
	# The existing South Gate name wall occupies world X=-158, Z=-158..-176.
	# Turn campus-side before reaching it; do not draw a new path through the wall.
	var bypass_z: float=-147-float(r.position[0])
	var b_rear_z: float=-135.12-float(r.position[0])
	paving(n,38,42,rear-5,bypass_z+2)
	paving(n,38,54,bypass_z-2,bypass_z+2)
	paving(n,50,54,bypass_z-2,b_rear_z+2)
	# Separated low planting only outside the rear pedestrian strip; no invented interior lawn.
	for x in [-25,20]:
		K.box(n,Vector3(x,.20,rear-7.2),Vector3(9,.4,2.4),"959d8f",false,15)
		K.box(n,Vector3(x,.43,rear-7.2),Vector3(8.6,.08,2),"5b704a",false,3)
		K.tree(n,Vector3(x,.48,rear-7.2),6.2,9300+absi(x))
	K.finish(n)
