#!/usr/bin/env python3
"""Run: python3 serve.py  — then open http://localhost:8000"""
import http.server, webbrowser, threading, os

PORT = 8000
os.chdir(os.path.dirname(os.path.abspath(__file__)))

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # silence request logs

def open_browser():
    webbrowser.open(f"http://localhost:{PORT}")

threading.Timer(0.5, open_browser).start()
print(f"Jessie's Tours running at http://localhost:{PORT}")
print("Press Ctrl+C to stop.\n")
http.server.HTTPServer(("", PORT), Handler).serve_forever()
