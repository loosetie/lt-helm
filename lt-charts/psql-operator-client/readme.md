# loosetie Ceph Client chart

When using the `psql-operator` every namespace needs a special ServiceAccount to be enabled.
Install this chart with/to every namespace which uses the `psql-operator`,
or simply use this chart as a dependency, if you chart uses a namespace exclusively.
