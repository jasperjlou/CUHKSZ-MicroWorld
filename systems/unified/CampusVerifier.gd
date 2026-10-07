extends RefCounted
# Pure evaluation of physically recorded milestones, never policy prose.
static func verify(task: Dictionary,state: Dictionary) -> Dictionary:
	var cursor:=0;var details: Array=[]
	for goal: String in task.get("goals",[]):
		var found:=-1
		for i in range(cursor,state.visited.size()):
			if state.visited[i]==goal:found=i;break
		details.append({"target":goal,"passed":found>=0})
		if found>=0:cursor=found+1
	var success: bool=not details.is_empty() and details.all(func(r):return r.passed)
	var time_ok: bool=state.elapsed<=task.get("deadline_seconds",10000)
	var event_ok: bool=task.get("event","").is_empty() or state.flags.get(task.event,false)
	for key: String in task.get("required_flags",[]):event_ok=event_ok and state.flags.get(key,false)
	return {"task_id":task.get("id",""),"success":success and time_ok and event_ok,"details":details,"time_ok":time_ok,"event_ok":event_ok,"elapsed":state.elapsed,"distance":state.distance,"actions":state.steps,"physics_samples":state.get("physics_samples",0),"visited":state.visited.duplicate(),"failures":state.failures.duplicate()}
