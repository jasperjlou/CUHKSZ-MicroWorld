extends RefCounted
## Anniversary2023: planted lawn alongside the approach, with thin diagonal stone strips.
## Extents, grades and tree count fitted; original geography not recalibrated.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
static func inner(z:float)->float:return lerpf(6.8,9.0,(z-9.2)/28.8)+.10
static func outer(z:float)->float:return lerpf(9.4,19.0,(z-10.5)/27.5)
static func lawn_point(x:float,z:float,point:Callable,height:Callable)->Vector3:
	var blend:=clampf((x-inner(z))/(outer(z)-inner(z)),0,1)
	return point.call(x,z,lerpf(height.call(z),.135,blend)+.025)
static func band(n:Node3D,z0:float,z1:float,point:Callable,height:Callable)->void:
	var vertices:=PackedVector3Array()
	for i in 8:
		var a:=lawn_point(lerpf(inner(z0),outer(z0),i/8.0),z0,point,height)
		var b:=lawn_point(lerpf(inner(z0),outer(z0),(i+1)/8.0),z0,point,height)
		var c:=lawn_point(lerpf(inner(z1),outer(z1),(i+1)/8.0),z1,point,height)
		var d:=lawn_point(lerpf(inner(z1),outer(z1),i/8.0),z1,point,height)
		vertices.append_array(K.quad(a,b,c,d))
	K.surface(n,vertices,"74875a",3,true)
static func build(n:Node3D,point:Callable,height:Callable)->void:
	for i in 11:band(n,10.5+i*2.5,13.0+i*2.5,point,height)
	# Thin stone ties cross the lawn diagonally; wider outer walk remains usable.
	for z in [14.0,19.0,24.0,29.0,34.0]:
		for i in 16:
			var t0:float=i/16.0;var t1:float=(i+1)/16.0
			var x0:float=lerpf(inner(z),outer(z+1.1),t0);var x1:float=lerpf(inner(z),outer(z+1.1),t1)
			var z0:float=z+t0*1.1;var z1:float=z+t1*1.1
			var a:=lawn_point(x0,z0-.095,point,height)+Vector3.UP*.035
			var b:=lawn_point(x1,z1-.095,point,height)+Vector3.UP*.035
			var c:=lawn_point(x1,z1+.095,point,height)+Vector3.UP*.035
			var d:=lawn_point(x0,z0+.095,point,height)+Vector3.UP*.035
			K.surface(n,K.quad(a,b,c,d),"b6bbb0",26)
	for z in [10.5,38.0]:
		var a:=lawn_point(inner(z),z,point,height);var b:=lawn_point(outer(z),z,point,height)
		K.surface(n,K.quad(a,b,b+Vector3(0,0,.13),a+Vector3(0,0,.13)),"a0aa98",26)
	var a:Vector3=point.call(outer(10.5),10.5,.135);var b:Vector3=point.call(outer(38),38,.135)
	var across:Vector3=(point.call(1,0,0)-point.call(0,0,0)).normalized()
	K.surface(n,K.quad(a,b,b+across*2.1,a+across*2.1),"9ea69b",26,true)
	# Drainage sits flush in the outer path, with no raised transverse obstacle.
	for i in 64:
		var p:=a.lerp(b,(i+.5)/64.0)+across*.17+Vector3.UP*.018
		K.box(n,p,Vector3(.12,.018,.30),"5f6b60",false,11)
	for z in [23.0,29.0,35.0]:
		K.tree(n,lawn_point(lerpf(inner(z),outer(z),.66),z,point,height),7.8,11800+int(z),1.45)
