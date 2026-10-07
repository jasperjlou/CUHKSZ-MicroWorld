"""Lightweight V5 provenance/frozen-source audit and bounded Godot driver."""
from pathlib import Path
import argparse,hashlib,json,sys
from check_campus_masterplan import engine
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8"))
def audit():
 checks=0
 def check(ok,msg):
  nonlocal checks
  checks+=1
  if not ok:raise AssertionError(msg)
 frozen=read("systems/data/campus_exterior_v4_frozen.json")
 for p,sha in frozen["hashes"].items():check(hashlib.sha256((ROOT/p).read_bytes().replace(b"\r\n",b"\n")).hexdigest()==sha,"Frozen V4/RC1 changed: "+p)
 interiors=read("systems/data/campus_interiors.json");check(len(interiors)==10,"ten interiors")
 ids=set()
 for d in interiors:
  check(d["building_id"] not in ids,"unique building");ids.add(d["building_id"])
  for key in ["floor","zone_type","entrances","connections","accessible_to_player","reference_confidence","model_status","streaming_group"]:check(key in d,"missing "+key)
  check(d["reference_confidence"]=="INFERRED" and d["replaceable"],"inferred interiors")
  check(d["width"]>=26 and d["depth"]>=28,"representative public scope")
 corrections=read("systems/data/campus_exterior_corrections_v5.json")
 check({c["object"] for c in corrections}==ids,"bounded entrance correction records")
 check(len(read("systems/data/campus_showcase_v5.json"))==12,"continuous showcase scope")
 manifest=read("world/campus_seamless/generated/manifest.json")
 for p,sha in manifest["interiors"].items():check(hashlib.sha256((ROOT/p.removeprefix("res://")).read_bytes()).hexdigest()==sha,"interior bake hash")
 check(hashlib.sha256((ROOT/"world/campus_seamless/generated/CampusSeamlessBaked.scn").read_bytes()).hexdigest()==manifest["scene_sha256"],"V5 scene hash")
 large=[]
 for base in ["world/campus_seamless","references/interiors_v5"]:
  for p in (ROOT/base).rglob("*"):
   if p.is_file():
    check(p.stat().st_size<10_000_000,"oversized "+str(p));large.append(p.stat().st_size)
 print("V5 audit",checks,"checks, largest file",max(large),"bytes")
 return checks
if __name__=="__main__":
 parser=argparse.ArgumentParser();parser.add_argument("--bake",action="store_true");parser.add_argument("--walk",action="store_true");parser.add_argument("--events",action="store_true");args=parser.parse_args()
 if args.bake:engine(["res://world/campus_seamless/CampusSeamless.tscn","--","--v5-bake"],"v5_bake",180)
 audit()
 if args.walk:engine(["res://world/campus_seamless/CampusSeamless.tscn","--fixed-fps","60","--","--v5-qa","--v5-full"],"v5_acceptance",700)
 if args.events:engine(["--headless","res://world/campus_seamless/CampusSeamless.tscn","--fixed-fps","60","--","--v5-qa","--v5-events"],"v5_event_acceptance",180)
