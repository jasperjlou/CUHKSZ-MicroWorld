"""Bounded scene driver; rejects Godot script errors even on exit code zero."""
from pathlib import Path
import argparse
import hashlib
import json
import itertools
import math
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8",errors="replace")

ROOT=Path(__file__).resolve().parents[1]


def engine(args,name,seconds=120):
    exe=ROOT/".tools/godot/Godot_v4.5.1-stable_win64.exe"
    log=ROOT/"tests/artifacts"/(name+".log")
    log.parent.mkdir(exist_ok=True)
    with log.open("wb") as stream:
        process=subprocess.Popen([str(exe),"--path",str(ROOT)]+args,cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
        try: code=process.wait(timeout=seconds)
        except subprocess.TimeoutExpired:
            process.kill();process.wait();code=124
    text=log.read_text(encoding="utf-8",errors="replace")
    print("GODOT IMPORT: completed" if name=="campus_import" and code==0 else text[-3500:])
    if "SCRIPT ERROR" in text or "ERROR:" in text: code=1
    if code: raise RuntimeError(f"Engine failed ({code}); see {log}")
    return text


def audit():
    m=json.loads((ROOT/"systems/data/campus_masterplan.json").read_text(encoding="utf-8"))
    p=json.loads((ROOT/"systems/data/campus_paths.json").read_text(encoding="utf-8"))
    checks=0
    def check(ok,msg):
        nonlocal checks
        checks+=1
        if not ok: raise AssertionError(msg)
    ids=set(); regions={r["id"] for r in m["regions"]}
    def inside(x,z,polygon):
        value=False
        for (ax,az),(bx,bz) in zip(polygon,polygon[1:]+polygon[:1]):
            if (az>z)!=(bz>z) and x<(bx-ax)*(z-az)/(bz-az)+ax:value=not value
        return value
    for o in m["objects"]:
        check(o["id"] not in ids,"duplicate ID");ids.add(o["id"])
        check(o["region"] in regions,"invalid region")
        check(len(o["center"])==3 and all(math.isfinite(v) for v in o["center"]),"invalid centre")
        check(o["confidence"] in ("verified","inferred","placeholder"),"confidence")
        check(o["metric_confidence"]=="ESTIMATED_METRIC" and o["replaceable"],"metric/replaceability")
        check(all(r in m["sources"] for r in o["source_refs"]),"missing source")
        check(o["model_stage"] in ("PLACEMENT","MASSING","LANDMARK","DETAILED"),"stage")
        check(o["yaw_deg"]==0 or math.isfinite(o["yaw_deg"]),"yaw")
        check(o["footprint_width"]>0 and o["footprint_depth"]>0,"footprint")
        x,y,z=o["center"];check(inside(x,z,m['bounds']),"centre outside campus bounds: "+o['id'])
        if o['category']=='building':
            check(all(inside(x+sx*o['footprint_width']/2,z+sz*o['footprint_depth']/2,m['bounds'])
                      for sx,sz in ((-1,-1),(-1,1),(1,-1),(1,1))),"footprint outside campus: "+o['id'])
    buildings=[o for o in m['objects'] if o['category']=='building']
    for a,b in itertools.combinations(buildings,2):
        overlap=(abs(a['center'][0]-b['center'][0])<(a['footprint_width']+b['footprint_width'])/2 and
                 abs(a['center'][2]-b['center'][2])<(a['footprint_depth']+b['footprint_depth'])/2)
        check(not overlap,'overlapping footprints: '+a['id']+' / '+b['id'])
    nodes={n["id"] for n in p["nodes"]};adj={n:set() for n in nodes}
    for r in m["roads"]+p["paths"]:
        check(len(r["nodes"])>=2 and all(n in nodes for n in r["nodes"]),"route nodes")
        check(r["confidence"]!="unknown" and r["width"]>0,"route confidence/width")
        check(len(r['geometry'])>=2 and len(r['segment_game_distances'])==len(r['nodes'])-1,'route geometry/distances')
        for a,b in zip(r['geometry'],r['geometry'][1:]):
            count=max(1,math.ceil(math.dist(a,b)/2))
            clear=True
            for i in range(count+1):
                t=i/count;x=a[0]+(b[0]-a[0])*t;z=a[2]+(b[2]-a[2])*t
                if inside(x,z,m['lake']['shoreline']) or any(
                    abs(x-o['center'][0])<o['footprint_width']/2+5.9 and
                    abs(z-o['center'][2])<o['footprint_depth']/2+5.9 for o in buildings):
                    clear=False;break
            check(clear,'route intersects water/building footprint: '+r['id'])
        for a,b in zip(r["nodes"],r["nodes"][1:]):adj[a].add(b);adj[b].add(a)
    seen={"upper_central"};todo=list(seen)
    while todo:
        n=todo.pop()
        for b in adj[n]-seen:seen.add(b);todo.append(b)
    check(seen==nodes,"planning topology disconnected")
    check(len(m["lake"]["shoreline"])>8,"lake polygon")
    check(m["high_table"]["status"]=="PROTOTYPE_UNREGISTERED","venue registration")
    # Frozen implementation must be byte-equivalent (ignoring CRLF) to tagged RC1.
    release=json.loads((ROOT/"systems/data/environment_release.json").read_text(encoding="utf-8"))
    for path,digest in release['frozen_files_sha256'].items():
        # Release source hashes use LF; Windows Git checkouts may use CRLF.
        content=(ROOT/path).read_bytes().replace(b'\r\n',b'\n')
        check(hashlib.sha256(content).hexdigest()==digest,'frozen RC1 content hash: '+path)
    old_changed=subprocess.check_output(["git","diff","v1.0.0-rc1","--","world/MainWorld.gd","world/FairyLakeWorld.gd","player/Player.gd","world/WorldRegion.gd","world/JunctionLayout.gd","world/JourneyBuilder.gd","project.godot","agents","benchmark"],cwd=ROOT)
    check(not old_changed,"RC1 implementation changed")
    print(f"SPATIAL_DATA_QA {checks} checks, 0 failures; {len(ids)} objects")
    (ROOT/"tests/artifacts/campus_data_qa.json").write_text(json.dumps(dict(checks=checks,failures=0,objects=len(ids)),indent=2),encoding="utf-8")


if __name__=="__main__":
    ap=argparse.ArgumentParser();ap.add_argument("--render",action="store_true");ap.add_argument("--pass1",action="store_true");ap.add_argument("--rc1",action="store_true")
    opts=ap.parse_args()
    audit()
    engine(["--headless","--editor","--import","--quit"],"campus_import")
    scene=["res://world/campus_master/CampusMaster.tscn","--","--masterplan-capture" if opts.render else "--masterplan-qa"]
    if opts.pass1:scene.append("--pass1")
    engine(([] if opts.render else ["--headless"])+["--fixed-fps","60"]+scene,"campus_render" if opts.render else "campus_physics",180)
    if opts.rc1:engine(["--headless","--fixed-fps","60","--","--qa"],"campus_rc1_core",180)
