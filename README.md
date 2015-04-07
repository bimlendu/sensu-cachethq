# sensu-cachethq

Sensu handler for [CachetHQ](https://cachethq.io)

In Sensu, define a check like below:

```
{
  "checks": {
    "check-vpc": {
      "handlers": [ "cachethq" ],
      "command": "/etc/sensu/plugins/cachethq/aws.py --service vpc --region us-east-1",
      "interval": 60,
      "cachethq" : {
        "component": {
          "name": "VPC (N. Virginia)",
          "id": "14"
        }
      },
      "subscribers": [ "cachethq-ops" ]
    }
  }
}
```

The handler needs `cachethq` key/values as mentioned above to correlate check with CachetHQ component.

The handler will create incident based on the words present in the check output.

```
status = {
      '1' => ['investigation', 'are investigating', 'investigate', 'experiencing', 'experienced'], # Investigating
      '2' => ['identified', 'addressed the root cause'], # Identified
      '3' => ['monitoring', 'to monitor', 'are working', 'working to', 'working on', 'work to', 'continue to work on', 'continuing to work on'], # Watching
      '4' => ['resolved', 'operating normally', 'recover', 'recovery', 'restore', 'restored', 'restoring', 'returned to normal'] # Fixed
    }
```
