# loosetie Ceph chart
This chart uses the original [ceph-helm](https://github.com/ceph/ceph-helm) chart
and made it work an k8s 1.14.6 on a bare-metal environment 
    
1.  Create a values.yaml and override at least the following values
    ```yaml
    # If you're using rancher you can set the project id here to automatically add the namespace to your rancher project
    # the id can be found in the url i.e. https://rancher.intern/p/c-7xmb9:p-tlg5p/workloads
    rancher:
      project: "c-7xmb9:p-2fqzk"
    
    ceph-helm:
      # this is the node network, in which all the cluster nodes
      network:
        public: 10.10.40.0/24
        cluster: 10.10.40.0/24
    
      # this is a workaround because mgr has to run in the host network,
      # where the kube-dns is not available
      conf:
        ceph:
          config:
            global:
              mon_host: 10.10.40.11
    
      # per path to the ceph block device (an empty partition)
      osd_devices:
        - name: dev-vda
          device: /dev/vda
          zap: "1"
    ```

1.  Install ceph client on the storage nodes and enable the required kernel module

    ```bash
    apt update &&\
    apt install ceph-common python-rbd &&\
    modprobe rbd &&\
    echo "rbd" > /etc/modules
    ```

1.  Label the nodes (the following line are an example for a cluster with 3 nodes called test01..03)
    ```bash
    # Monitor (min 3)
    #kubectl label node <nodename> ceph-mon=enabled
    kubectl label node test01 ceph-mon=enabled
    kubectl label node test02 ceph-mon=enabled
    kubectl label node test03 ceph-mon=enabled
    
    # Metadata (min 0, 1 for linux mounts)
    #kubectl label node <nodename> ceph-mds=enabled
    kubectl label node test03 ceph-mds=enabled
    
    # Storage (min 3)
    #kubectl label node <nodename> ceph-osd=enabled ceph-osd-device-dev-vda=enabled
    kubectl label node test01 ceph-osd=enabled ceph-osd-device-dev-vda=enabled
    kubectl label node test02 ceph-osd=enabled ceph-osd-device-dev-vda=enabled
    kubectl label node test03 ceph-osd=enabled ceph-osd-device-dev-vda=enabled
    
    # S3/Swift Gateway (min 0)
    #kubectl label node <nodename> ceph-rgw=enabled #
    
    # Manager (Metrics; min 2, or better on each "mon" node)
    #kubectl label node <nodename> ceph-mgr=enabled
    kubectl label node test01 ceph-mgr=enabled
    kubectl label node test02 ceph-mgr=enabled
    ```

1.  Install the chart in two steps
    ```bash
    NAMESPACE=ceph
    # Just the Secrets/Services (TODO don't create secrets with k8s Jobs)
    helm install --name=ceph --namespace=${NAMESPACE} . --set ceph.deployment.ceph=false
    
    # Add the Applications
    helm upgrade ceph . --cleanup-on-fail --set ceph_helm.deployment.ceph=true
    ```
    
1.  Create a pool
    ```bash
    NAMESPACE=ceph
    kubectl -n ${NAMESPACE} exec -ti ceph-mon-cppdk -c ceph-mon --\
      ceph osd pool create rbd 100
    ```
    The last number is the amount of [placement groups](https://docs.ceph.com/docs/mimic/rados/operations/placement-groups/#set-the-number-of-placement-groups)
    which you may increase if needed
    
1.  Create the user secret
    On any "mon" instance execute
    ```bash
    NAMESPACE=ceph
    kubectl -n ${NAMESPACE} exec -ti ceph-mon-cppdk -c ceph-mon --\
      ceph auth get-or-create-key client.k8s mon 'allow r' osd 'allow rwx pool=rbd' | base64
    ```
    And add the result as the value in
    ```bash
    NAMESPACE=ceph
    kubectl -n ${NAMESPACE} edit secrets/pvc-ceph-client-key
    ```
    
1.  Use the `ceph-client` chart to enable namespaces to use the ceph cluster.
    The StorageClasses are named `ceph-rbd` and `ceph-fs` by default
