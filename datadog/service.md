```json showLineNumbers
{
  "identifier": "serviceDependency",
  "title": "Datadog Service",
  "icon": "Datadog",
  "schema": {
    "properties": {},
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "relations": {
    "serviceDependency": {
      "title": "Depends On",
      "target": "serviceDependency",
      "required": false,
      "many": true
    }
  }
}
```