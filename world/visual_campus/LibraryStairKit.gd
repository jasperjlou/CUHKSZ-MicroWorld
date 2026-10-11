extends RefCounted
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func rail(b: Node3D,a: Vector3,c: Vector3) -> void:
	var delta:=c-a
	for i in 10:
		K.box(b,a.lerp(c,i/9.0)+Vector3.UP*.55,Vector3(.055,1.1,.055),"728078",false,11)
	var n:=K.holder(b,"SlopingLibraryRail",(a+c)/2+Vector3.UP*1.08)
	n.rotation.x=-atan2(delta.y,delta.z)
	K.box(n,Vector3.ZERO,Vector3(.08,.08,delta.length()),"a5916d",false,11);K.finish(n)

static func flight(n: Node3D,length: float,rise: float,width: float,with_rails: bool=true) -> void:
	for i in 28:
		var z: float=(i+.5)*length/28;var y: float=(i+1)*rise/28
		K.box(n,Vector3(0,y-.07,z),Vector3(width,.14,length/28+.02),"bdbcae",false,12)
		K.box(n,Vector3(0,y-.15,z-length/56),Vector3(width,.16,.06),"b5b5a7",false,12)
	var a:=Vector3(0,0,0);var c:=Vector3(0,rise,length)
	var ramp:=K.surface(n,K.quad(a-Vector3.RIGHT*width/2,a+Vector3.RIGHT*width/2,c+Vector3.RIGHT*width/2,c-Vector3.RIGHT*width/2),"bdbcae",12,true);ramp.visible=false
	var v:=K.quad(a+Vector3(-width/2,-.32,0),a+Vector3(width/2,-.32,0),c+Vector3(width/2,-.32,0),c+Vector3(-width/2,-.32,0));var down:=PackedVector3Array()
	for i in range(0,v.size(),3):down.append_array(PackedVector3Array([v[i],v[i+2],v[i+1]]))
	K.surface(n,down,"b8b9ac",22,true)
	if with_rails:
		for x in [-width/2-.15,width/2+.15]:rail(n,Vector3(x,0,0),Vector3(x,rise,length))

