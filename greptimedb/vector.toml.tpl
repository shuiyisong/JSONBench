[sources.files]
type = "file"
include = [ "${DATA_DIRECTORY}/*.json.gz" ]
data_dir = "${DATA_DIRECTORY}"
ignore_checkpoints = true

[transforms.parse_logs]
type = "remap"
inputs = ["files"]
source = '''
. = parse_json!(.message)
'''

[sinks.greptime_logs]
type = "greptimedb_logs"
inputs = [ "parse_logs" ]
compression = "gzip"
dbname = "public"
endpoint = "http://localhost:4000"
pipeline_name = "jsonbench"
table = "jsontable"
batch.max_events = 1000