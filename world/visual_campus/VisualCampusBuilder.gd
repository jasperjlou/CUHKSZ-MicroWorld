extends RefCounted
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const Teaching := preload("res://world/visual_campus/TeachingBlocks.gd")
const Lower := preload("res://world/visual_campus/LowerCampusBuildings.gd")
const Landmarks := preload("res://world/visual_campus/LandmarkBuildings.gd")
const Library := preload("res://world/visual_campus/LibrarySpaces.gd")
const LibraryShell := preload("res://world/visual_campus/LibraryEnvelope.gd")
const Student := preload("res://world/visual_campus/StudentCentre.gd")
const Courtyard := preload("res://world/visual_campus/CentralCourtyard.gd")
const BGrade:=preload("res://world/visual_campus/TeachingBLowerSite.gd")
const CGrade:=preload("res://world/visual_campus/TeachingCLowerSite.gd")
const ZhangGrade:=preload("res://world/visual_campus/ZhangCourtGround.gd")
const Services := preload("res://world/visual_campus/StudentLowerConcourse.gd")
const Administration := preload("res://world/visual_campus/AdministrationBuilding.gd")
const Site := preload("res://world/visual_campus/LowerCampusLandscape.gd")
const Conference := preload("res://world/visual_campus/ConferenceCentre.gd")
const Hill := preload("res://world/visual_campus/AdministrationHillside.gd")
const ShawWestPlan := preload("res://world/visual_campus/ShawWestPlan.gd")
const ShawHill := preload("res://world/visual_campus/ShawHillside.gd")
const StartGrade := preload("res://world/visual_campus/StartZoneGrade.gd")
const DaoGrade := preload("res://world/visual_campus/DaoYuanGrade.gd")
const ShawEastGrade := preload("res://world/visual_campus/ShawEastGrade.gd")
const LibraryRoad := preload("res://world/visual_campus/LibraryRearRoad.gd")
const RearBank := preload("res://world/visual_campus/RearRoadBank.gd")
const RearWoodland := preload("res://world/visual_campus/LibraryWoodlandEdge.gd")
const RearCanopy := preload("res://world/visual_campus/LibraryRearCanopy.gd")
const UpperWoodland := preload("res://world/visual_campus/UpperRearWoodland.gd")
const SouthContext := preload("res://world/visual_campus/SouthGateContext.gd")
const TeachingOuter := preload("res://world/visual_campus/TeachingOuterGrade.gd")
const GatePortal := preload("res://world/visual_campus/EastGatePortal.gd")
const GateGround := preload("res://world/visual_campus/EastGateGround.gd")
const ConferenceGround := preload("res://world/visual_campus/ConferenceAvenue.gd")
const ICCEntry := preload("res://world/visual_campus/ConferenceEntrySite.gd")
const Tower := preload("res://world/visual_campus/BellTower.gd")
const EntranceGroup := preload("res://world/visual_campus/EntranceConferenceGroup.gd")
const EntranceLake := preload("res://world/visual_campus/EntranceLakeSite.gd")
const Woodland := preload("res://world/visual_campus/ZhangWoodland.gd")
const PavilionLake := preload("res://world/visual_campus/PavilionPond.gd")
const LibraryPool := preload("res://world/visual_campus/LibraryPoolFrontage.gd")
const TeachingACad := preload("res://world/visual_campus/TeachingACadPlan.gd")
const GateTeaching := preload("res://world/visual_campus/EastGateTeachingLink.gd")
const ABRoad := preload("res://world/visual_campus/TeachingABRearRoad.gd")
const TrackSite := preload("res://world/visual_campus/TrackOuterSite.gd")
const WhitePlinth := preload("res://world/visual_campus/SportsWhitePlinth.gd")
const ResearchSite := preload("res://world/visual_campus/ResearchSite.gd")
var research_site_transform:=Transform3D.IDENTITY
var rear_route: Array=[]
var garden_rear_route: Array=[]
const GardenStreet:=preload("res://world/visual_campus/GardenBackStreet.gd")
var data: Dictionary
var root: Node3D
var buildings: Dictionary = {}

func point(a: Array) -> Vector3:
	return Vector3(float(a[0]),float(a[1]),float(a[2]))

func height(x: float,z: float) -> float:
	var t: Dictionary=data.terrain
	var level: float=float(t.upper_level)*clampf((float(t.stair_front_z)-z)/(float(t.stair_front_z)-float(t.stair_back_z)),0,1)
	level=GatePortal.fitted_height(x,z,level)
	level=GateGround.fitted_height(x,z,level)
	level=GateTeaching.fitted_height(x,z,level)
	level=ConferenceGround.fitted_height(x,z,level)
	level=EntranceLake.fitted_height(x,z,level)
	level=ShawEastGrade.fitted_height(x,z,level)
	level=DaoGrade.fitted_height(x,z,level)
	if x>155:level+=smoothstep(155,240,x)*25.0
	level=StartGrade.fitted_height(x,z,RearBank.fitted_height(x,z,ShawHill.fitted_height(x,z,LibraryRoad.fitted_height(x,z,Hill.fitted_height(x,z,level))),rear_route))
	level=Woodland.fitted_height(x,z,PavilionLake.fitted_height(x,z,GardenStreet.fitted_height(x,z,level,garden_rear_route)))
	level=RearCanopy.fitted_height(x,z,level)
	level=TeachingOuter.fitted_height(x,z,level)
	level+=SouthContext.rise(x,z)
	level=LibraryRoad.rear_court_height(x,z,level)
	level=preload("res://world/visual_campus/LotusRearSite.gd").fitted_height(x,z,level)
	return WhitePlinth.fitted_height(x,z,TrackSite.fitted_height(x,z,ResearchSite.fitted_height(x,z,level,research_site_transform)))

func build(parent: Node3D,records: Dictionary) -> void:
	root=parent;data=records
	research_site_transform=ResearchSite.placement(data)
	for route: Dictionary in data.routes:
		if route.id=="library_rear_shaw_avenue":rear_route=route.points
		if route.id=="east_crossroad":garden_rear_route=route.points
	terrain();circulation();gateway()
	for record: Dictionary in data.buildings:
		var b:=K.holder(root,record.id,point(record.position));b.rotation_degrees.y=record.yaw
		b.scale.x=float(record.get("length_scale",1.0))
		if record.has("component_scale"):b.scale=point(record.component_scale)
		b.set_meta("visual_record",record);buildings[record.id]=b
		match record.model:
			"gateway":gateway_wing(b,record)
			"teaching":Teaching.build(b,record)
			"gallery":conference(b,record)
			"entrance_halls":EntranceGroup.build(b,self)
			"conference_ii":EntranceGroup.build_conference(b,self)
			"administration":administration(b,record)
			"library":library(b,record)
			"student":student(b,record)
			_:Lower.build(b,record)
		Library.public_base(b,record)
		K.finish(b)
	landscape();lower_landscape();Courtyard.build(root);Landmarks.connections(root);Site.build(root,self);Hill.build(root,self);ShawHill.build(root,self)
	preload("res://world/visual_campus/LowerCorridor.gd").build(root,self)
	ResearchSite.build(root,self)
	preload("res://world/visual_campus/ResearchPerimeter.gd").build(root,self)
	TrackSite.build(root,self)
	preload("res://world/visual_campus/SportsStreetDetail.gd").build(root,self)
	preload("res://world/visual_campus/SportsCorner.gd").build(root,self)
	preload("res://world/visual_campus/AnniversaryGround.gd").build(root,self)
	preload("res://world/visual_campus/ShawCornerLandscape.gd").build(root,self)
	ShawEastGrade.build(root,self)
	StartGrade.build(root)
	DaoGrade.build(root)
	preload("res://world/visual_campus/TowerPlaza.gd").build(root,self)
	GardenStreet.build(root,self)
	preload("res://world/visual_campus/ZhixinSideStreets.gd").build(root,self)
	preload("res://world/visual_campus/StartZoneRegistration.gd").build(root,self)
	preload("res://world/visual_campus/StartZonePerimeter.gd").build(root,self)
	preload("res://world/visual_campus/OldGateSite.gd").build(root,self)
	preload("res://world/visual_campus/LowerBasketballCourts.gd").build(root,self)
	PavilionLake.build(root,self)
	Woodland.build(root,self)
	Services.build(root)
	preload("res://world/visual_campus/PhotoMallGround.gd").build(root)
	preload("res://world/visual_campus/AdminMallGround.gd").build(root)
	GateGround.build(root,self)
	GateTeaching.build(root,self)
	preload("res://world/visual_campus/GateLawnGround.gd").build(root)
	EntranceLake.build(root,self)
	preload("res://world/visual_campus/TeachingAInterfaces.gd").build(root)
	preload("res://world/visual_campus/TeachingBCLink.gd").build(root)
	ABRoad.build(root)
	# Close the short ICC side-apron return onto the already paved gate upper landing.
	var icc_return:=K.holder(root,"ICCToGateUpperLanding")
	ribbon(icc_return,[[27.8,0,-47],[27.8,2.24,-55],[27.8,2.24,-64]],3.7,"aba99f",26,.108)
	K.finish(icc_return)
	LibraryRoad.build(root,self)
	RearBank.build(root,self)
	preload("res://world/visual_campus/RearRoadFinish.gd").build(root,self,rear_route)
	RearCanopy.build(root,self)
	preload("res://world/visual_campus/RearBankFlowers.gd").build(root,self)
	signs()

func terrain() -> void:
	var ground:=K.holder(root,"Terrain")
	var vertices:=PackedVector3Array();var bounds: Array=data.terrain.bounds
	# Include the exact ramp breakpoints; coarse terrain chords must not cross its collider.
	var z_samples: Array=[]
	var x_samples: Array=[]
	for x in range(int(bounds[0]),int(bounds[2])+1,5):x_samples.append(float(x))
	for x:float in [-166,-140.62,-138.62,-128.2,-126.2,-121.8,-54]:
		if not x_samples.has(x):x_samples.append(x)
	for x:float in [RearCanopy.X-5.4,RearCanopy.X-3.6,RearCanopy.X+3.6,RearCanopy.X+5.4]:
		if not x_samples.has(x):x_samples.append(x)
	for x in range(99,191,2):
		if not x_samples.has(float(x)):x_samples.append(float(x))
	for x: float in [121.0,126.0,129.0,135.0,138.0,144.0,147.0,162.0,164.0,177.0,98.0,100.0,136.0,141.0,94.0,96.0,124.0,127.0,156.0,20.0,23.5,24.0,25.0,33.5,35.0,12.0,14.5,15.4,18.6,19.0,34.0,42.0,48.0,65.0,95.0,99.3,99.7,105.0,113.6,116.0,175.6,175.8,183.6,183.8,26.0,39.8,40.2,134.0,142.0]:
		if not x_samples.has(x):x_samples.append(x)
	for x: float in [RearBank.toe(RearBank.STAIR_Z,rear_route),RearBank.toe(RearBank.STAIR_Z,rear_route)+RearBank.RUN]:
		if not x_samples.has(x):x_samples.append(x)
	# Align the sloping bank's terrain knees; coarse chords otherwise protrude as grass wedges.
	for bank_z in range(RearBank.BANK_MIN,RearBank.BANK_MAX+1,2):
		for x: float in [RearBank.toe(bank_z,rear_route),RearBank.toe(bank_z,rear_route)+RearBank.RUN]:
			if not x_samples.has(x):x_samples.append(x)
	x_samples.sort()
	for x: float in [-177+102,-177+98,-177+36.4,-177+36.0,-177+36.5,-177+18,11.8,12.2,15.8,16.2,17,37]:
		if not x_samples.has(x):x_samples.append(x)
	x_samples.sort()
	for z in range(int(bounds[1]),int(bounds[3])+1,5):z_samples.append(float(z))
	for z:float in [-282,-261,-181.5,-180,-173,-163.8,-161,-154,-148,-78,-62]:
		if not z_samples.has(z):z_samples.append(z)
	for z:float in [RearCanopy.Z-7.4,RearCanopy.Z-5.4,RearCanopy.Z+5.4,RearCanopy.Z+7.4]:
		if not z_samples.has(z):z_samples.append(z)
	for x in range(42,139,2):
		if not x_samples.has(float(x)):x_samples.append(float(x))
	x_samples.sort()
	for z in range(-816,-737):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for z in range(-242,-117,2):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for z in range(-700,-579,2):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for z in range(-575,-474,2):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for z in range(RearBank.BANK_MIN,RearBank.BANK_MAX+1,2):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for z: float in [RearBank.STAIR_Z-.84,RearBank.STAIR_Z,RearBank.STAIR_Z+.84]:
		if not z_samples.has(z):z_samples.append(z)
	for z: float in [-70.0,-22.0,-18.0,-10.0,-64.0,-58.0,-44.0,-34.0,-29.0,18.0,21.5,23.0,45.0,50.0,-20.0,-55.0,-60.0,-43.0,-39.5,GateGround.FRONT,GateGround.BACK,data.terrain.stair_front_z,data.terrain.stair_back_z,-380.0,-338.0,-363.0,-337.0]:
		if not z_samples.has(z):z_samples.append(z)
	for z: float in [-780,-770,-638,-631,-671,-661,-702,-692,-739,-729]:
		if not z_samples.has(z):z_samples.append(z)
	for z: float in [-836,-832.2,-832,-831.8,-778,-775,-787,-779,-831,-823,-818,-792]:
		var registered_z:float=-1538-z
		if not z_samples.has(registered_z):z_samples.append(registered_z)
	for z: float in [-505,-502.5,-499,-495,-492,-760,-748,-660,-648]:
		if not z_samples.has(z):z_samples.append(z)
	z_samples.sort()
	# V84 small banks/short flights need their own grade breakpoints and pool clipping.
	for x in range(-28,29):
		if not x_samples.has(float(x)):x_samples.append(float(x))
	for z in range(-584,-509):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for i in 4:
		var z:float=-511-i*4-1.2
		if not z_samples.has(z):z_samples.append(z)
	# V86 woodland descent and retaining line need local slope breakpoints.
	for x in range(-86,3,2):
		if not x_samples.has(float(x)):x_samples.append(float(x))
	for x:float in [-32.51,-32.5,-32.26,-31.3,-26.7]:
		if not x_samples.has(x):x_samples.append(x)
	for z in range(-501,-440):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for x:float in [19.5,34.5,48.35]:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in [-332,-326,-312,-254]:
		if not z_samples.has(z):z_samples.append(z)
	for x:float in [-19.3,-18.9,-18.7,-15.9,-15.7,-15.3]:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in [-40,-45,-47,-54]:
		if not z_samples.has(z):z_samples.append(z)
	for x:float in [-96.5,-82.5,-81.0,-62.5]:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in [-118.75,-102.25]:
		if not z_samples.has(z):z_samples.append(z)
	var icc_breaks:Dictionary=ICCEntry.terrain_breaks()
	for x:float in icc_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in icc_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var service_breaks:Dictionary=Services.terrain_breaks()
	for x:float in service_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in service_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var ab_breaks:Dictionary=ABRoad.terrain_breaks()
	for x:float in ab_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in ab_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var b_breaks:Dictionary=BGrade.terrain_breaks()
	for x:float in b_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in b_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var c_breaks:Dictionary=CGrade.terrain_breaks()
	for x:float in c_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in c_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var zhang_breaks:Dictionary=ZhangGrade.terrain_breaks()
	for x:float in zhang_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in zhang_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var shaw_breaks:Dictionary=ShawEastGrade.terrain_breaks()
	for x:float in shaw_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in shaw_breaks.z:
		if not z_samples.has(z):z_samples.append(z)
	var west_breaks:Dictionary=ShawWestPlan.terrain_breaks()
	for x:float in west_breaks.x:
		if not x_samples.has(x):x_samples.append(x)
	for z:float in west_breaks.z:
		if not z_samples.has(z):z_samples.append(z)

	for x:float in [101.5,103.5,104.4,105.0,106.5,108.0,128.0,130.0]:
		if not x_samples.has(x):x_samples.append(x)
	for z in range(-355,-266,2):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	for x:float in [112,114,116,116.5,118,120,122,124,126]:
		if not x_samples.has(x):x_samples.append(x)
	for i in range(210,273):
		var x:float=i*.5
		if not x_samples.has(x):x_samples.append(x)
	for z in range(-369,-328):
		if not z_samples.has(float(z)):z_samples.append(float(z))
	x_samples.sort();z_samples.sort()
	for zi in range(z_samples.size()-1):
		var z: float=z_samples[zi];var next_z: float=z_samples[zi+1]
		for xi in range(x_samples.size()-1):
			var x: float=x_samples[xi];var next_x: float=x_samples[xi+1]
			if GateTeaching.cutout((x+next_x)/2,(z+next_z)/2):continue
			if ABRoad.cutout((x+next_x)/2,(z+next_z)/2):continue
			if BGrade.cutout((x+next_x)/2,(z+next_z)/2):continue
			if CGrade.cutout((x+next_x)/2,(z+next_z)/2):continue
			if ZhangGrade.cutout((x+next_x)/2,(z+next_z)/2):continue
			if ShawEastGrade.cutout((x+next_x)/2,(z+next_z)/2):continue
			if ShawWestPlan.cutout((x+next_x)/2,(z+next_z)/2):continue
			if TeachingACad.cutout((x+next_x)/2,(z+next_z)/2):continue
			if ICCEntry.cutout((x+next_x)/2,(z+next_z)/2):continue
			if Courtyard.cutout((x+next_x)/2,(z+next_z)/2):continue
			if Services.cutout((x+next_x)/2,(z+next_z)/2):continue
			if Site.pond_cutout((x+next_x)/2,(z+next_z)/2):continue
			if x<65 and next_x>19.5 and z< -254 and next_z> -332:
				vertices.append_array(LibraryPool.clipped_cell(self,x,next_x,z,next_z));continue
			if x<19 and next_x>-17 and z<-527 and next_z>-578:
				vertices.append_array(PavilionLake.clipped_cell(self,x,next_x,z,next_z));continue
			if x<146 and next_x>98 and z<36 and next_z> -10:
				vertices.append_array(EntranceLake.clipped_cell(self,x,next_x,z,next_z));continue
			if (z< -950 and x<150 and next_x> -190) or (z< -905 and next_z> -982 and x< -72 and next_x> -114):
				vertices.append_array(TrackSite.cell(self,x,next_x,z,next_z));continue
			vertices.append_array(K.quad(Vector3(x,height(x,z),z),Vector3(next_x,height(next_x,z),z),Vector3(next_x,height(next_x,next_z),next_z),Vector3(x,height(x,next_z),next_z)))
	# Reuse the exact terrain triangles; only the visible ground finish changes.
	# Forest floor is separated from the maintained campus lawns.
	var lawn:=PackedVector3Array();var soil:=PackedVector3Array();var context:=PackedVector3Array();var litter:=PackedVector3Array()
	for i in range(0,vertices.size(),3):
		var mid:Vector3=(vertices[i]+vertices[i+1]+vertices[i+2])/3
		var face:=PackedVector3Array([vertices[i],vertices[i+1],vertices[i+2]])
		if mid.x< -169 and mid.z< -955:context.append_array(face)
		elif UpperWoodland.contains(mid.x,mid.z) or SouthContext.wooded(mid.x,mid.z):litter.append_array(face)
		elif RearWoodland.contains(mid.x,mid.z,rear_route) or preload("res://world/visual_campus/CampusForest.gd").sports_woodland(mid.x,mid.z,research_site_transform):soil.append_array(face)
		else:lawn.append_array(face)
	K.surface(ground,lawn,"6b8258",3,true)
	K.surface(ground,soil,"52583f",8,true)
	K.surface(ground,litter,"635f48",59,true)
	K.surface(ground,context,"8c918c",57,true)
	# Only these terrain surfaces receive the research hill-floor blend; shared
	# facade/roof materials and every existing collision vertex remain unchanged.
	for surface in ground.get_children():
		if not surface is MeshInstance3D:continue
		var material:ShaderMaterial=surface.material_override.duplicate()
		material.set_shader_parameter("research_ground_blend",true)
		material.set_shader_parameter("shaw_ground_blend",true)
		material.set_shader_parameter("research_origin",research_site_transform.origin)
		var yaw:float=research_site_transform.basis.get_euler().y
		material.set_shader_parameter("research_axis",Vector2(cos(yaw),sin(yaw)))
		surface.material_override=material
	# Background grove follows this district's hillside, not invented full-campus geography.
	var grove_rng:=RandomNumberGenerator.new();grove_rng.seed=41403
	for i in 180:
		var x:=grove_rng.randf_range(162,241);var z:=grove_rng.randf_range(-975,-65)
		var tree_height:=grove_rng.randf_range(8,15)
		if ShawHill.excludes_grove(x,z):continue
		if RearWoodland.contains(x,z,rear_route):continue
		if UpperWoodland.contains(x,z):continue
		if preload("res://world/visual_campus/ShawRoadGarden.gd").contains(x,z):continue
		if ResearchSite.distance_to_bench(x,z,research_site_transform)<9:continue
		K.tree(ground,Vector3(x,height(x,z),z),tree_height,i+710)
	K.finish(ground)
	backdrop()
	preload("res://world/visual_campus/CampusForest.gd").build(root,self)
	RearWoodland.build(root,self)
	UpperWoodland.build(root,self)
	preload("res://world/visual_campus/ShawRoadGarden.gd").build(root,self)
	SouthContext.build(root,self)

func backdrop_height(x: float,z: float) -> float:
	var bounds: Array=data.terrain.bounds
	var h:=height(clampf(x,bounds[0],bounds[2]),clampf(z,bounds[1],bounds[3]))
	# Keep the woodland-side context behind campus; its invented ridge must not
	# continue across the street-facing city foreground visible from East Gate.
	if x>float(bounds[2]):h+=18*sin(clampf((x-float(bounds[2]))/375,0,1)*PI/2)*(1.0-smoothstep(0,100,z))
	if x<float(bounds[0]):h+=SouthContext.rise(x,z)-SouthContext.rise(float(bounds[0]),z)
	return h

func backdrop() -> void:
	# Visual apron only: no new roads, campus anchors or geographic claims outside the build area.
	var b:=K.holder(root,"DistantGroundBackdrop");var bounds: Array=data.terrain.bounds
	var xs: Array[float]=[];var zs: Array[float]=[]
	for x in range(-520,621,50):xs.append(float(x))
	for z in range(-1340,301,50):zs.append(float(z))
	# Resolve only the new photographed opposite hill; retain other apron samples.
	for x in range(-420,-203,8):
		if not xs.has(float(x)):xs.append(float(x))
	for z in range(-320,-34,10):
		if not zs.has(float(z)):zs.append(float(z))
	for x: float in [float(bounds[0]),float(bounds[2])]:
		if not xs.has(x):xs.append(x)
	for z: float in [float(bounds[1]),float(bounds[3])]:
		if not zs.has(z):zs.append(z)
	xs.sort();zs.sort();var mesh:=PackedVector3Array();var woodland_mesh:=PackedVector3Array()
	for i in range(xs.size()-1):
		for j in range(zs.size()-1):
			var x: float=(xs[i]+xs[i+1])/2;var z: float=(zs[j]+zs[j+1])/2
			if x>float(bounds[0]) and x<float(bounds[2]) and z>float(bounds[1]) and z<float(bounds[3]):continue
			var points: Array[Vector3]=[]
			for p: Vector2 in [Vector2(xs[i],zs[j]),Vector2(xs[i+1],zs[j]),Vector2(xs[i+1],zs[j+1]),Vector2(xs[i],zs[j+1])]:points.append(Vector3(p.x,backdrop_height(p.x,p.y)-.035,p.y))
			if SouthContext.wooded(x,z):woodland_mesh.append_array(K.quad(points[0],points[1],points[2],points[3]))
			else:mesh.append_array(K.quad(points[0],points[1],points[2],points[3]))
	# Unmodelled exterior is a quiet presentation apron, not invented campus lawn.
	# The wooded side retains forest-floor colour; the open side fades to neutral.
	K.surface(b,mesh,"8c918c",57)
	K.surface(b,woodland_mesh,"635f48",59,true)
	var rng:=RandomNumberGenerator.new();rng.seed=592134
	for i in 90:
		var x:=rng.randf_range(250,505);var z:=rng.randf_range(-1130,40)
		K.tree(b,Vector3(x,backdrop_height(x,z),z),rng.randf_range(13,22),i+900)
	K.finish(b)

func ribbon(parent: Node3D,points: Array,width: float,hex: String,kind: int=1,lift: float=.035) -> MeshInstance3D:
	var vertices:=PackedVector3Array()
	var offsets: Array[Vector3]=[]
	for i in points.size():
		var a:=point(points[maxi(0,i-1)]);var p:=point(points[i]);var b:=point(points[mini(i+1,points.size()-1)])
		var incoming: Vector3=(p-a).normalized() if i>0 else (b-p).normalized()
		var outgoing: Vector3=(b-p).normalized() if i<points.size()-1 else incoming
		var n1:=Vector3(incoming.z,0,-incoming.x);var n2:=Vector3(outgoing.z,0,-outgoing.x)
		var miter: Vector3=(n1+n2).normalized()
		offsets.append(miter*width/2/minf(1.0,maxf(.62,miter.dot(n2))))
	for i in range(points.size()-1):
		var a:=point(points[i]);var b:=point(points[i+1])
		var count:=maxi(1,ceili(a.distance_to(b)/2))
		for j in count:
			var p:=a.lerp(b,float(j)/count);var q:=a.lerp(b,float(j+1)/count)
			var pv:=offsets[i].lerp(offsets[i+1],float(j)/count);var qv:=offsets[i].lerp(offsets[i+1],float(j+1)/count)
			# Fit across the road as well as along it. A single wide chord cuts
			# through convex grades and exposes grass inside paved road surfaces.
			var across:=maxi(1,ceili(maxf(pv.length(),qv.length())*2.0))
			for strip in across:
				var left:float=-1.0+2.0*strip/across
				var right:float=-1.0+2.0*(strip+1)/across
				var quad: Array[Vector3]=[p+pv*left,p+pv*right,q+qv*right,q+qv*left]
				for k in 4:quad[k].y=height(quad[k].x,quad[k].z)+lift
				vertices.append_array(K.quad(quad[0],quad[1],quad[2],quad[3]))
	return K.surface(parent,vertices,hex,kind)

func circulation() -> void:
	var paving:=K.holder(root,"Circulation")
	for r: Dictionary in data.routes:
		if not r.get("render_surface",true):continue
		var surface_points:Array=r.get("surface_points",r.points)
		var color: String="414b4c" if r.kind=="vehicle" else ("667e57" if r.kind=="green" else "9aa69c")
		var kind: int=2 if r.kind=="vehicle" else (3 if r.kind=="green" else 1)
		# Lawn must sit below crossing paths; coplanar green/stone ribbons flickered into white patches.
		ribbon(paving,surface_points,r.width,color,kind,.012 if r.kind=="green" else .035)
		for side in [-1,1]:
			var edge: Array=[]
			for i in surface_points.size():
				var p:=point(surface_points[i]);var tangent:=point(surface_points[mini(i+1,surface_points.size()-1)])-point(surface_points[maxi(0,i-1)])
				p+=Vector3(tangent.z,0,-tangent.x).normalized()*side*(float(r.width)/2+.12);edge.append([p.x,p.y,p.z])
			ribbon(paving,edge,.30,"848e81",0,.06)
		if r.kind=="vehicle":
			for i in range(r.points.size()-1):
				var a:=point(r.points[i]);var b:=point(r.points[i+1]);var dist:=a.distance_to(b)
				for j in range(3,int(dist)-2,9):
					var p:=a.lerp(b,j/dist);p.y=height(p.x,p.z)+.055
					K.box(paving,p,Vector3(.12,.02,3),"d1b462",false,0,atan2(b.x-a.x,b.z-a.z))
	# Broad stone forecourts match the plaza views rather than isolated doorstep patches.
	for plaza: Array in [[0,-165,58,40],[-2.25,-278,41.5,40],[-2,-385,20,34]]:
		K.box(paving,Vector3(plaza[0],height(plaza[0],plaza[1])+.058,plaza[1]),Vector3(plaza[2],.045,plaza[3]),"9aa49b",false,6)
		for side in [-1,1]:K.box(paving,Vector3(plaza[0]+side*(plaza[2]/2-.8),height(plaza[0],plaza[1])+.084,plaza[1]),Vector3(.6,.025,plaza[3]),"69796c",false,7)
	# Dark meander paving bands, visible in Central Mall panorama.
	for z in range(-150,-410,-8):
		if z>=-202 and z<=-163:continue # V91 photographed clear plaza and inlay own this area.
		K.box(paving,Vector3(-8,2.31,z),Vector3(.25,.018,5.8),"5a645f")
		for side in [-1,1]:
			K.box(paving,Vector3(-8+side*.8,2.31,z-2.3),Vector3(1.6,.018,.25),"5a645f")
			K.box(paving,Vector3(-8+side*1.45,2.31,z-1.3),Vector3(.25,.018,2.2),"5a645f")
	# EastGateGround owns the source-led stair, apron and fitted side ramp.
	K.finish(paving)

func stairs(parent: Node3D,start: Vector3,end: Vector3,width: float,count: int,add_collision: bool=true) -> void:
	var run: float=start.z-end.z;var rise: float=end.y-start.y
	for i in count:
		var top: float=start.y+rise*(i+1)/count
		var thickness: float=maxf(.11,top-start.y)
		K.box(parent,Vector3(start.x,top-thickness/2,start.z-run*(i+.5)/count),Vector3(width,thickness,absf(run)/count+.015),"b6bab2",false,12)
	var verts:=K.quad(start+Vector3(-width/2,0,0),start+Vector3(width/2,0,0),end+Vector3(width/2,0,0),end+Vector3(-width/2,0,0))
	# Trimesh ramp follows the stair envelope; the same body walks the slope, no teleport.
	if add_collision:
		var floor:=K.surface(parent,verts,"b6bab2",1,true);floor.visible=false
	for side in [-1,1]:
		for i in 5:
			var p:=start.lerp(end,i/4.0)+Vector3(side*(width/2+.25),0,0)
			K.box(parent,p+Vector3.UP*.55,Vector3(.08,1.1,.08),"697970")

func gateway() -> void:
	var gate:=K.holder(root,"EastGateOrigin")
	gate.set_meta("coordinate_origin",data.coordinate_frame)
	preload("res://world/visual_campus/EastGateArrival.gd").build(gate,self)
	preload("res://world/visual_campus/EastGateExterior.gd").build(root,self)
	preload("res://world/visual_campus/EastGateOppositeHall.gd").build(root)
	GatePortal.ceremonial_ground(gate,self)
	GatePortal.bridge(gate)
	K.finish(gate)

func gateway_wing(b: Node3D,r: Dictionary) -> void:
	if r.id=="gate_north":GatePortal.right_tower(b,r)
	else:preload("res://world/visual_campus/EastGateLeftGroup.gd").build(b,r,self)

func conference(b: Node3D,r: Dictionary) -> void:
	Conference.build(b,r,self)

func administration(b: Node3D,r: Dictionary) -> void:
	Administration.build(b,r,self)

func library(b: Node3D,r: Dictionary) -> void:
	var w: float=r.width;var d: float=r.depth
	LibraryShell.build(b,r)
	# Landing begins at the stair endpoint; an early slab edge would block the ascent.
	preload("res://world/visual_campus/LibraryLowerLevel.gd").entry_stair(b)
	for x in [-12.0,12.0]:
		preload("res://world/visual_campus/LibraryLobbyDetail.gd").cylinder(b,Vector3(x,2.05,-4),.40,4.1,"d2d1c5",true)
		K.column(b,Vector3(x,4.1,-4),4.5,.75)
		for z in [-5.0,-12.0]:
			if not preload("res://world/visual_campus/LibrarySecondRooms.gd").in_room(Vector3(x,4.4,z)):K.bench(b,Vector3(x,4.55,z))
	# V44 outdoor entry and its clear stair opening replace the generic low portico.
	Library.detail(b,r,self)
	preload("res://world/visual_campus/LibraryUpperLevels.gd").build(b,r,self)
	preload("res://world/visual_campus/LibraryEntryLevels.gd").build(b)
	preload("res://world/visual_campus/LibraryServiceCores.gd").build(b)
	preload("res://world/visual_campus/LibraryRegisteredFloors.gd").build(b,r)
	preload("res://world/visual_campus/LibrarySecondRooms.gd").build(b)
	preload("res://world/visual_campus/LibrarySecondServices.gd").build(b)

func student(b: Node3D,r: Dictionary) -> void:
	Student.build(b,r,self)

func landscape() -> void:
	var garden:=K.holder(root,"Landscape")
	# Tree spacing keeps sight lines at entrances but adds the photographed tree canopy.
	for z in range(-76,-436,-20):
		if z>-163:continue # V98 source-registered tree beds own the gate/TA frontage.
		for side in [-1,1]:
			if z in [-96,-156,-276,-396]:continue
			if z>=-202 and z<=-163:continue # No default tree wells across the flag/administration forecourt.
			if side==-1 and z<-334:continue # V89 photo tree lawns own this verge.
			if side==1 and z>-333 and z<-253:continue # V90 continuous pool-shore walk, trees belong on grass.
			if side==1 and z>-391 and z<-327:continue
			if Services.cutout(side*12,z):continue
			K.tree(garden,Vector3(side*12,2.24,z),9.6+(abs(z)%3)*.65,abs(z)+(side+1),1.8)
			K.planter(garden,Vector3(side*14.2,2.24,z+8));K.lamp(garden,Vector3(side*18,2.24,z+4))
	for z in range(-125,-415,-60):
		if z>-163:continue
		for side in [-1,1]:
			if side==-1 and z<-334:continue
			if z>=-202 and z<=-163:continue
			if side==1 and z>-333 and z<-253:continue # No legacy bench protruding into the basin.
			if Courtyard.cutout(side*20,z):continue # V129 remove upper-height bench floating over the lower lawn.
			K.bench(garden,Vector3(side*20,2.24,z),side*PI/2)
	# V98 owns the uninterrupted gate lawn; no duplicate boxes beneath its stone margins.
	preload("res://world/visual_campus/LibraryPoolFrontage.gd").pool(root)
	K.finish(garden)

func lower_landscape() -> void:
	var n:=K.holder(root,"LowerLandscape")
	# SC/teaching corridor: photographed slatted overhead link and two public walks.
	var bridge_top:=6.89
	preload("res://world/visual_campus/ZhangPhotoFront.gd").transverse(root)
	stairs(n,Vector3(38,2.24,-426),Vector3(38,bridge_top,-441.8),3.4,28)
	for z in range(-480,-801,-25):
		for side in [-1,1]:
			if abs(z+735)<18 or abs(z+805)<18:continue
			if z<=-500 and z>-585:continue # V84 real pond, banks and paths replace generic verge trees.
			# These two former straight-verge trees occupy V50's curved hardscape.
			if side==1 and z in [-605,-630]:continue
			if side==1 and z<=-660:continue # V78 lawn and V64 axial garden own planting.
			if side==-1 and z<=-680 and z>=-785:continue
			K.tree(n,Vector3(side*14,2.24,z),7+(abs(z)%3),abs(z)+side+1)
			if z>-588:K.lamp(n,Vector3(side*16,2.24,z-5))
	for p: Vector3 in [Vector3(-152,2.24,-671)]:
		K.box(n,p+Vector3.UP*.3,Vector3(10,.6,5),"84937d")
		K.box(n,p+Vector3.UP*.68,Vector3(9.6,.16,4.6),"567448",false,3)
		K.tree(n,p+Vector3(0,.75,0),8,absi(int(p.z)))
	for z in [-432,-503,-697,-764]:
		for side in [-1,1]:
			if Services.cutout(side*20,z):continue
			if side==-1 and z<=-680:continue
			if side==1 and z==-697:continue # Keep the full width of the V54 stair approach clear.
			if side==1 and z==-764:continue
			K.bench(n,Vector3(side*20,2.24,z),side*PI/2)
	K.bench(n,Vector3(20,2.24,-684),PI/2)
	# V63: photographed dense eaves; anchor and dimensions remain a site fit.
	var tower:=K.holder(n,"BellTower",Vector3(23,2.24,-805))
	Tower.build(tower);K.finish(n)

func signs() -> void:
	var signroot:=K.holder(root,"Wayfinding")
	for record: Dictionary in data.landmarks:
		var p:=point(record.position)
		if record.id=="east_gate" or record.get("indoor",false) or record.get("hide_world_sign",false):continue
		p.x-=9
		K.box(signroot,p+Vector3.UP*1.5,Vector3(.10,3,.10),"566755")
		K.box(signroot,p+Vector3.UP*2.5,Vector3(3.8,.75,.15),"415b4a")
		K.label(signroot,record.name,p+Vector3(0,2.5,.12),.0055)
	K.finish(signroot)
