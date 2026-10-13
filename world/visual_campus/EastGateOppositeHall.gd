extends RefCounted
## V193: observed folded glass silhouette, not a registered venue identity.
## The official gate panorama determines visible folds; gmp photos inform framing.
## Off-campus context only: unseen interior and exact metric placement remain open.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")

static func line(mesh: PackedVector3Array,a: Vector3,b: Vector3,normal: Vector3,width: float) -> void:
	var side: Vector3=(b-a).normalized().cross(normal).normalized()*width*.5
	# A shallow raised cap on each side avoids coplanar glass/frame flicker.
	for sign_value in [-1,1]:
		var lift: Vector3=normal*.03*float(sign_value)
		mesh.append_array(K.quad(a-side+lift,a+side+lift,b+side+lift,b-side+lift))

static func pane(root: Node3D,a: Vector3,b: Vector3,c: Vector3,color: String,frame: PackedVector3Array) -> void:
	var normal: Vector3=(b-a).cross(c-a).normalized()
	var surface:=K.surface(root,PackedVector3Array([a,b,c]),color,5)
	var glass:=StandardMaterial3D.new();glass.albedo_color=Color(color);glass.metallic=.20;glass.roughness=.36;glass.cull_mode=BaseMaterial3D.CULL_DISABLED
	surface.material_override=glass
	for pair in [[a,b],[b,c],[c,a]]:line(frame,pair[0],pair[1],normal,.25)
	# Triangular glazing divisions lie in the facet, not a screen-facing texture.
	for i in range(1,9):
		var t:=float(i)/9
		line(frame,a.lerp(b,t),a.lerp(c,t),normal,.065)
		line(frame,b.lerp(a,t),b.lerp(c,t),normal,.065)
		line(frame,c.lerp(a,t),c.lerp(b,t),normal,.065)

static func build(root: Node3D) -> void:
	var b:=K.holder(root,"EastGateOppositeFoldedHallV193",Vector3(29,0,176))
	b.set_meta("identity","Observed opposite folded hall;candidate Universiade natatorium,not confirmed")
	b.set_meta("fitted","176x78m envelope;3..29m facets;position and orientation fitted to gate view")
	var framing:=PackedVector3Array()
	for i in 4:
		var x:float=-88+i*44
		var left:=Vector3(x,15,-25);var peak:=Vector3(x+22,29,-16)
		var right:=Vector3(x+44,15,-25);var foot:=Vector3(x+22,3,-34)
		pane(b,left,peak,foot,"6e9297",framing)
		pane(b,peak,right,foot,"83a3a5",framing)
		pane(b,peak,Vector3(x+22,21,44),right,"9cadad",framing)
		pane(b,left,Vector3(x+22,21,44),peak,"869da0",framing)
		pane(b,Vector3(x,15,44),Vector3(x+22,21,44),left,"7f9698",framing)
		pane(b,right,Vector3(x+22,21,44),Vector3(x+44,15,44),"8c9f9e",framing)
		# Ground glazing behind the facets supplies depth, no fictional room plan.
		K.box(b,Vector3(x+22,7,-23.5),Vector3(43.6,14,.18),"536f72",false,5)
		for j in range(1,11):K.box(b,Vector3(x+j*4,7,-23.7),Vector3(.08,14,.12),"607574",false,22)
		for y in [3.5,7.0,10.5,14.0]:K.box(b,Vector3(x+22,y,-23.7),Vector3(44,.08,.12),"607574",false,22)
	K.box(b,Vector3(0,.8,5),Vector3(176,1.6,78),"9caaa5",false,26)
	K.box(b,Vector3(0,7,44),Vector3(176,14,.2),"718984",false,22)
	for side in [-1,1]:K.box(b,Vector3(side*88,7,5),Vector3(.2,14,78),"627e80",false,5)
	var bars:=K.surface(b,framing,"455e61",22)
	var steel:=StandardMaterial3D.new();steel.albedo_color=Color("455e61");steel.roughness=.55;steel.cull_mode=BaseMaterial3D.CULL_DISABLED;bars.material_override=steel
	K.finish(b)
