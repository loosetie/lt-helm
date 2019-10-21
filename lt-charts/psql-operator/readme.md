# loosetie psql-operator chart
This chart uses the official [postgres-operator](https://github.com/zalando/postgres-operator) by zalando
and adds some convenience. (Tested on k8s 1.14.6 bare-metal)

This chart is missing a infrastructure role manifest template, so you have to add your own as described below.

1.  Create a yalues.yaml and overwrite at least the following values:
    ```yaml
    # If you're using rancher you can set the project id here to automatically add the namespace to your rancher project
    # the id can be found in the url i.e. https://rancher.intern/p/c-7xmb9:p-tlg5p/workloads
    rancher:
      project: "c-7xmb9:p-2fqzk"
    
    ```

1.  create an infrastructure-role.yaml like this
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: postgresql-infrastructure-roles
    data:
      maintain: |
        inrole: [admin]
        user_flags:
          - superuser
          - createdb
        db_parameters:
          log_statement: all
    
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: postgresql-infrastructure-roles
    type: Opaque
    data:
      maintain: "12345"
    ```

1.  Use the `psql-operator-client` chart to enable namespaces to use the psql-operator.