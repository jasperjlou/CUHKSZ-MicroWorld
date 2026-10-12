extends RefCounted
## V188: architect-described exterior G-to-2F rising gallery behind the curved fins.
## Historic built photo/plan + G panorama establish the route; widths/heights fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const Entry=preload("res://world/visual_campus/LibraryEntryPavilion.gd")
const WIDTH:float=2.2

static func route()->Array[Vector3]:
	var front:=P.front3();var points:Array[Vector3]=[]
	for i in range(4,11):
		var tangent:Vector2=(front[mini(i+1,10)]-front[maxi(i-1,4)]).normalized()
		var p:Vector2=front[i]+Vector2(tangent.y,-tangent.x)*2.4
		points.append(Vector3(p.x,0,p.y))
	var total:float=0
	for i in range(1,points.size()):total+=points[i].distance_to(points[i-1])
	var travel:float=0
	for i in range(1,points.size()):
		travel+=Vector2(points[i].x-points[i-1].x,points[i].z-points[i-1].z).length()
		points[i].y=4.4*travel/total
	var start:=points[0];points.push_front(start-Vector3(2.8,0,0))
	# Turn around the outside of the mapped diagonal service core to the 2F entry terrace.
	points.append(Vector3(9,4.4,23))
	points.append(Entry.dp(-7.7,1.0))
	points.append(Entry.dp(-4,1.0))
	# Round sharp corners so the constant-width rail does not pinch the turning path.
	var smooth:Array[Vector3]=[points[0]]
	for i in range(1,points.size()-1):
		var prev:=points[i-1];var at:=points[i];var next:=points[i+1]
		var incoming:=Vector3(at.x-prev.x,0,at.z-prev.z).normalized()
		var outgoing:=Vector3(next.x-at.x,0,next.z-at.z).normalized()
		if incoming.dot(outgoing)>.65:
			smooth.append(at);continue
		var radius:=minf(2.8,minf(at.distance_to(prev),at.distance_to(next))*.35)
		var a:=at.move_toward(prev,radius);var b:=at.move_toward(next,radius)
		for j in range(6):
			var t:float=j/5.0;var u:float=1-t
			smooth.append(a*u*u+at*2*u*t+b*t*t)
	smooth.append(points[-1])
	return smooth

static func side_vectors(points:Array[Vector3])->Array[Vector3]:
	var sides:Array[Vector3]=[]
	for i in points.size():
		var a:=points[maxi(0,i-1)];var b:=points[mini(points.size()-1,i+1)]
		var dir:=Vector3(b.x-a.x,0,b.z-a.z).normalized()
		sides.append(Vector3(-dir.z,0,dir.x)*WIDTH/2)
	return sides

static func double_face(n:Node3D,a:Vector3,b:Vector3,c:Vector3,d:Vector3,color:String,solid:bool=false)->void:
	K.surface(n,PackedVector3Array([a,b,c,a,c,d,a,c,b,a,d,c]),color,22,solid)

static func guard(n:Node3D,a:Vector3,b:Vector3)->void:
	var dir:=b-a;var count:=maxi(1,int(ceil(dir.length()/.17)))
	for i in range(count+1):K.box(n,a.lerp(b,float(i)/count)+Vector3.UP*.54,Vector3(.032,1.08,.032),"697579",false,11)
	var rail:=K.holder(n,"GreyHandrail",(a+b)/2+Vector3.UP*1.08)
	rail.basis=Basis.looking_at(dir.normalized(),Vector3.UP)
	K.box(rail,Vector3.ZERO,Vector3(.055,.06,dir.length()),"6d797c",false,11);K.finish(rail)
	# Invisible continuous guard keeps players between balusters without hundreds of shapes.
	var fence:=K.surface(n,PackedVector3Array([a,b,b+Vector3.UP*1.05,a,b+Vector3.UP*1.05,a+Vector3.UP*1.05,a,b+Vector3.UP*1.05,b,a,a+Vector3.UP*1.05,b+Vector3.UP*1.05]),"697579",22,true)
	fence.hide()

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryRisingOuterGalleryV188")
	var points:=route();var sides:=side_vectors(points)
	for i in range(points.size()-1):
		var a:=points[i];var b:=points[i+1];var u:=sides[i];var v:=sides[i+1]
		# Keep the accepted collision datum; a thin finish clears the existing 2F deck.
		var deck:=K.surface(n,K.quad(a-u,a+u,b+v,b-v),"a7aaa5",58,true)
		deck.hide()
		var finish:=Vector3.UP*.015
		K.surface(n,K.quad(a-u+finish,a+u+finish,b+v+finish,b-v+finish),"a7aaa5",58)
		var top:=K.quad(a-u,a+u,b+v,b-v);var down:=PackedVector3Array()
		for j in range(0,top.size(),3):down.append_array(PackedVector3Array([top[j]-Vector3.UP*.28,top[j+2]-Vector3.UP*.28,top[j+1]-Vector3.UP*.28]))
		K.surface(n,down,"d0d0c5",22,true)
		for sign in [-1,1]:
			var edge_a:Vector3=a+u*sign;var edge_b:Vector3=b+v*sign
			double_face(n,edge_a,edge_b,edge_b-Vector3.UP*.34,edge_a-Vector3.UP*.34,"747d7e")
			guard(n,edge_a,edge_b)
	K.finish(n)
