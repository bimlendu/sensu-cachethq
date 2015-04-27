# sensu-cachethq

[Sensu](http://sensuapp.org/) handler for [CachetHQ](https://cachethq.io)

In Sensu, define a check:

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

The handler needs `cachethq` key/values as mentioned above to correlate checks with CachetHQ component.

The handler will create incident based on the words present in the check output.

```
 status = {
      '1' => ['investigation', 'are investigating', 'investigate'], # Investigating
      '2' => ['identified', 'addressed the root cause'], # Identified
      '3' => ['monitor', 'progress'], # Watching
      '4' => ['resolved', 'operating normally', 'recover', 'restor', 'returned to normal'] # Fixed
    }
```

Something like this, based on the incident output.

![CachetHQ-Incidents](https://raw.githubusercontent.com/bimlendu/sensu-cachethq/master/CachetHQ%20-%20Incidents.png)

More on sensu checks: http://sensuapp.org/docs/0.17/getting-started-with-checks


More on handlers: http://sensuapp.org/docs/0.17/getting-started-with-handlers
