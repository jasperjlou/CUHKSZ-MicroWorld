extends Node
## Offline single-episode baseline, using the same observation/action API as QA.
var world: Node3D

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	world.start()
	var policy := preload("res://agents/CrossCampusPolicy.gd").new()
	var failures: Array = []
	for _step in range(8):
		if world.finished:
			break
		var observation: Dictionary = world.environment_api.observe()
		var action := policy.decide(observation)
		var response: Dictionary = await world.environment_api.step(action)
		if not response.ok:
			failures.append(response.get("reason","navigation_incomplete"))
			break
	print("CROSS CAMPUS BENCHMARK ",JSON.stringify({"policy":"observation_only_rule","completed":world.finished,"failures":failures,"result":world.result,"summary_path":EventLogger.summary_path}))
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if world.finished and failures.is_empty() else 1)
