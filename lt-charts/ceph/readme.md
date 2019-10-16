# Ceph Setup
    
1.  Create a own values.yaml and override at least the following values
    ```yaml
    ceph-helm:
      network:
        public: 10.10.40.0/24
        cluster: 10.10.40.0/24
    
      osd_devices:
        - name: dev-vda
          device: /dev/vda
          zap: "1"
    ```
    -   network ist the node network where all ceph cluster nodes are in the same network
    -   osd_devices is per path to the ceph block device (an empty partition)
    
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
    
1.  Use the `ceph-client` chart to enable namespaces to use the ceph cluster
