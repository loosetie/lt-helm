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
    # Just the Secrets/Services (TODO don't create secrets with k8s Jobs)
    helm install --name=ceph --namespace=ceph . --set ceph.deployment.ceph=false
    
    # Add the Applications
    helm upgrade ceph . --set ceph.deployment.ceph=true
    ```
    
1.  Use the `ceph-client` chart to enable namespaces to use the ceph cluster