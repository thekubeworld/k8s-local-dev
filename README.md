# k8s-local-dev

**k8s-local-dev** creates Kubernetes local cluster for testing or development. It is based on [kind](https://kind.sigs.k8s.io/) and Container Network Interface (**CNI**) implementations.  

```
$ ./k8s-local-dev 
Usage: ./k8s-local-dev CNI_NAME
```

Example 1 - Start cluster using kindnetd CNI:
```
./k8s-local-dev kindnetd
```

Example 2 - Changing kube-proxy mode:
```
$ ./k8s-local-dev kindnetd --kube-proxy-mode ipvs
$ kubectl get configmap -n kube-system kube-proxy -o yaml | grep -i mode
    detectLocalMode: ""
    mode: ipvs
```

Supported CNI: 
```
	antrea
	calico
	cilium
	flannel
	ovn-kubernetes
	weavenet
	kindnetd
```

For more info use:
```
./k8s-local-dev --help
```
All **CNI** and **script configurations** are in a [single file](https://github.com/K8sbykeshed/k8s-local-dev/blob/main/lib/config.sh)  
However, users can overwrite the default value in the file manually or using dynamic approach, example:
```
$ ANTREA_VERSION=v0.12.0 ./k8s-local-dev
```
The command above will **overwrite the default version** from [config.sh](https://github.com/K8sbykeshed/k8s-local-dev/blob/main/lib/config.sh) and set the local cluster with ANTREA 0.12.0
Current variables used for deployment that users can overwrite:
| ENV Variable            | Description                                 |
|-------------------------|---------------------------------------------|
| FLANNEL_VERSION         | Flannel version                             |
| ANTREA_VERSION          | Antrea version                              |
| CILIUM_VERSION          | Cilium version                              |
| CALICO_CLIENT_VERSION   | Calico client version                       |
| CONTAINER_CMD_INTERFACE | [WIP] docker or podman (ATM not suppported) |
| KUBECTL_VERSION         | kubectl version                             |
| KUBECTL_PLATFORM        | kubectl platform                            |
| KIND_VERSION            | kind version                                |
  
  
**See also**:  
- [Cyclonus - Tools for understanding, measuring, and applying network policies effectively in kubernetes](https://github.com/mattfenwick/cyclonus)
- [k8sprototypes from Jay - kind](https://github.com/jayunit100/k8sprototypes/tree/master/kind)
