"""Build dashboard.html from template + data.json."""
import json, sys, os

template_path = sys.argv[1] if len(sys.argv) > 1 else 'dashboard_template.html'
data_path     = sys.argv[2] if len(sys.argv) > 2 else 'data.json'
output_path   = sys.argv[3] if len(sys.argv) > 3 else 'dashboard.html'

with open(template_path) as f: html = f.read()
with open(data_path) as f: data = json.load(f)

html = html.replace('__DATA_JSON__', json.dumps(data))

with open(output_path, 'w') as f: f.write(html)
print(f"Built: {output_path}  ({os.path.getsize(output_path):,} bytes)")
