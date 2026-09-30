"""Loopback completion contract, not a real model. No request dumps or credential logging."""
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
import json

class Handler(BaseHTTPRequestHandler):
    def log_message(self,*args):pass
    def do_POST(self):
        request=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        context=json.loads(request['messages'][1]['content'])
        o=context['observation']
        if context['kind']=='plan':value={'plan':['前往任务地点并查看签到处。']}
        elif o['destination'] in o['nearby']:value={'type':'inspect','target':o['destination']}
        else:value={'type':'navigate','target':o['destination']}
        if self.path.startswith('/invalid'):value={'type':'teleport','success':True}
        payload={'choices':[{'message':{'content':json.dumps(value,ensure_ascii=False),'reasoning_content':'NEVER_SAVE_INTERNAL_REASONING'},'finish_reason':'stop'}],'usage':{'prompt_tokens':77,'completion_tokens':9,'total_tokens':86}}
        data=json.dumps(payload,ensure_ascii=False).encode()
        self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)

if __name__=='__main__':
    server=ThreadingHTTPServer(('127.0.0.1',0),Handler)
    folder=Path(__file__).parent/'artifacts';folder.mkdir(exist_ok=True)
    (folder/'rc1-http-port.txt').write_text(str(server.server_port),encoding='utf8')
    server.serve_forever()
