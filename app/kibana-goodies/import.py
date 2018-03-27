import json
import httplib

kibana_host = 'kibana'
kibana_port = 5601

kibana_headers = {'kbn-xsrf': 'yup', 'Content-Type': 'application/json'}

for saved_object in json.load(open('kibana-goodies/export.json')):
    saved_object_id = saved_object['_id']
    saved_object_type = saved_object['_type']

    print 'Importing {} with ID {}'.format(saved_object_type, saved_object_id)

    # Figure out which URL to hit for the given object.
    kibana_url_fragment = '/api/saved_objects/{}/{}?overwrite=true'.format(saved_object_type, saved_object_id)

    # Try and restore our saved object.
    http_connection = httplib.HTTPConnection(kibana_host, kibana_port)
    http_connection.request('POST', kibana_url_fragment, json.dumps({'attributes': saved_object['_source']}), kibana_headers)
    response = http_connection.getresponse()

    # If we've failed, bail early.
    if response.status != 200:
        print 'Failed to import saved object:'
        print response.read()
        exit(1)

    http_connection.close()
