extends RefCounted
## V245: return of the hatched rear retained-earth band in published1F plan.
## Existing game frame: localz-29.3..-15.3 => worldx113.6..99.6,
## localx34 => worldz-506. Metres/profile fitted; no true-north claim.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const G=2.24
const X0=99.5
const X1=113.6
const Z=-506.0
const TOP=G+4.95-.28

static func build(root:Node3D,builder)->void:
	var n:=K.holder(root,"ShawRetainedEarthReturnV245")
	# Retain earth below the existing second-floor slab, closing its unsupported end.
	K.box(n,Vector3((X0+X1)/2,(G+TOP)/2,Z-.01),Vector3(X1-X0,TOP-G,.17),"747d75",true,22)
	# Exposed end of the retaining wall has a small concrete coping under the slab.
	K.box(n,Vector3((X0+X1)/2,TOP-.04,Z-.01),Vector3(X1-X0,.08,.23),"9b9e96",false,82)
	# Vertical construction joints follow the wall; they are finish, not openings.
	for x in range(101,113,3):
		var bottom:float=maxf(G,builder.height(x,Z+.20))
		var height:float=TOP-bottom
		if height>.08:K.box(n,Vector3(x,bottom+height/2,Z+.08),Vector3(.012,height,.012),"657069",false,11)
	K.finish(n)
