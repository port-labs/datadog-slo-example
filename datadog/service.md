```json showLineNumbers
{
  "identifier": "microservice",
  "title": "Microservice",
  "icon": "Service",
  "schema": {
    "properties": {
      "description": {
        "title": "Description",
        "type": "string"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {
    "service": {
      "title": "Service URL",
      "calculation": "'https://datadoghq.com/apm/services/' + .identifier",
      "type": "string",
      "format": "url"
    }
  },
  "relations": {}
}
```