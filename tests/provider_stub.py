"""Loopback-only HTTP contract fixture; never a model experiment."""
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
import json, time
ROOT=Path(__file__).resolve().parent/'artifacts'
class Handler(BaseHTTPRequestHandler):
    def log_message(self,*args): pass
    def do_POST(self):
        body=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        context=json.loads(body['messages'][1]['content'])
        receipt={k:body.get(k) for k in ['model','temperature','max_tokens','max_completion_tokens','seed','response_format']}
        receipt['authorization_present']='Authorization' in self.headers
        with (ROOT/'provider-wire-receipts.jsonl').open('a',encoding='utf-8') as f:f.write(json.dumps(receipt)+'\n')
        status=200
        content=json.dumps({'plan':['前往晚宴门口，交谈后进入。']},ensure_ascii=False) if context['kind']=='plan' else json.dumps(context['available_actions'][0])
        message={'content':content,'reasoning_content':'REASONING_MUST_NOT_BE_STORED'}
        if self.path.startswith('/timeout'):time.sleep(2)
        if self.path.startswith('/failure'):status=503
        if self.path.startswith('/empty'):message['content']=''
        if self.path.startswith('/refusal'):message['refusal']='Not logged'
        payload={'choices':[{'message':message,'finish_reason':'stop'}],'usage':{'prompt_tokens':77,'completion_tokens':9}}
        if self.path.startswith('/bad-envelope'):payload={'choices':'broken'}
        data=json.dumps(payload,ensure_ascii=False).encode()
        try:
            self.send_response(status);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
        except (BrokenPipeError,ConnectionResetError,ConnectionAbortedError):pass
server=ThreadingHTTPServer(('127.0.0.1',0),Handler)
ROOT.mkdir(exist_ok=True)
(ROOT/'provider-port.txt').write_text(str(server.server_port))
server.serve_forever()
