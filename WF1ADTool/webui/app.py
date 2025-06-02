from flask import Flask, render_template, request, jsonify
import os
import json
import markdown

app = Flask(__name__)

# Define paths to review directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REVIEWS_JSON_DIR = os.path.join(BASE_DIR, '../reviews/json')
REVIEWS_MD_DIR = os.path.join(BASE_DIR, '../reviews/md')

def get_report_list():
    # List available JSON reports by filename without extension
    reports = []
    if os.path.isdir(REVIEWS_JSON_DIR):
        for fname in os.listdir(REVIEWS_JSON_DIR):
            if fname.endswith('.json'):
                reports.append(fname[:-5])  # strip .json
    return sorted(reports)

@app.route('/', methods=['GET', 'POST'])
def index():
    reports = get_report_list()
    selected = None
    data_json = None
    data_md = None

    if request.method == 'POST':
        selected = request.form.get('report_select')
        if selected:
            # Load JSON data
            json_path = os.path.join(REVIEWS_JSON_DIR, f"{selected}.json")
            if os.path.exists(json_path):
                with open(json_path, 'r', encoding='utf-8') as jf:
                    data_json = json.load(jf)

            # Load Markdown content and convert to HTML
            md_path = os.path.join(REVIEWS_MD_DIR, f"{selected}.md")
            if os.path.exists(md_path):
                with open(md_path, 'r', encoding='utf-8') as mf:
                    md_text = mf.read()
                    data_md = markdown.markdown(md_text, extensions=['tables'])

    return render_template('index.html', reports=reports, selected=selected,
                           data_json=data_json, data_md=data_md)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')