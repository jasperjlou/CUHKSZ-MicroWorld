extends RefCounted
## Local static scene reflection. The capture is approximate cubemap parallax, not planar optics.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const WATER=preload("res://world/visual_campus/ReflectingPoolWater.gdshader")
const WATER_LAYER:int=1<<19

static func build(parent:Node3D,vertices:PackedVector3Array)->void:
	var water:=K.surface(parent,vertices,"405c63",10)
	water.name="ReflectingWaterV201"
	var material:=ShaderMaterial.new();material.shader=WATER;water.material_override=material
	water.layers=WATER_LAYER;water.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var probe:=ReflectionProbe.new();probe.name="LibraryWaterReflectionV201"
	probe.position=Vector3(48,26,-290);probe.size=Vector3(110,68,140)
	probe.origin_offset=Vector3(-10,-22,0);probe.box_projection=true
	probe.cull_mask=1;probe.reflection_mask=WATER_LAYER
	probe.ambient_mode=ReflectionProbe.AMBIENT_DISABLED
	probe.intensity=.85;probe.max_distance=180;probe.enable_shadows=true
	probe.update_mode=ReflectionProbe.UPDATE_ONCE
	parent.add_child(probe)
