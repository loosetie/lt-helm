# lt-helm
loosetie Helm Charts

## The Idea
All the helm charts we've been using for 3rd party software will be managed and updated here.
See [helm.sh](https://helm.sh/) and/or [github](https://github.com/helm/charts) for details on what a Helm Chart is ;)

## Structure

-   `3rdparty`: Git submodules to dependent charts, if not available in a chart repository

-   `images`: Dockerfiles for used images

-   `lt-charts`: Custom helm charts (mostly combinations of official helm charts)

-   `lt-charts/${CHART_NAME}/generated`: Used for generating i.e. credential secrets before installing a chart


## Conventions

-   Use an alias in `requirements.yaml` if the required chart contains a `-`

-   If a chart requires secrets to be generated, there is a shell script called `prepare.sh` which creates a folder named `generated`
    This folder is only created/changes if it's not present, otherwise nothing will be changed

-   Some charts need to be installed in multiple stages, if that's the case


## Misc

-   You can host this repo via installing the `chart_repo` chart contained in this project
    ```bash
    helm install lt-helm/lt-charts/chart_repo/
    ```
    Or by launching helm in the repo folder (see [helm serve](https://helm.sh/docs/helm/#helm-serve))
    ```bash
    helm serve --repo-path lt-helm/
    ```


----
## Charts
Those charts listed here are meant for installing into a cluster kind of "as system services"

### ceph
Ceph cluster file system and client to enables namespaces


### psql-operator
Postgresql cluster and client to enable namespaces

### util
Contains a label namespace job (for the use with `helm install --namespace=...`) and some handy utilities to comply with helm best practises.
