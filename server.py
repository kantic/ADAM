#!/usr/bin/python

import BaseHTTPServer
import CGIHTTPServer

class MyHandler(CGIHTTPServer.CGIHTTPRequestHandler):

    # code from oryginal CGIHTTPServer.py
    def is_cgi(self):
        #                v added `CGIHTTPServer.`
        collapsed_path = CGIHTTPServer._url_collapse_path(self.path) 
        dir_sep = collapsed_path.find('/', 1)
        head, tail = collapsed_path[:dir_sep], collapsed_path[dir_sep+1:]
        print(head, tail)
        if head in self.cgi_directories:
            #if not tail.endswith('.html'): # <-- new line
            if tail.endswith('.pl'): # <-- new line
                self.cgi_info = '', tail
                return True
        return False

# --- test ---

MyHandler.cgi_directories = ['/']

server = BaseHTTPServer.HTTPServer(('', 8000), MyHandler)
server.serve_forever()
