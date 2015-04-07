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
      '1' => ['investigation', 'are investigating', 'investigate'], # Investigating
      '2' => ['identified', 'addressed the root cause'], # Identified
      '3' => ['monitor', 'progress'], # Watching
      '4' => ['resolved', 'operating normally', 'recover', 'restor', 'returned to normal'] # Fixed
    }
```

Something like this:

![CachetHQ-Incidents](https://raw.githubusercontent.com/bimlendu/sensu-cachethq/master/CachetHQ%20-%20Incidents.png)
