# TK8 addon - Contour

### What are TK8 addons?

- TK8 add-ons provide freedom of choice for the user to deploy tools and applications without being tied to any customized formats of deployment.
- Simplified deployment process via CLI (will also be available via TK8 web in future).
- With the TK8 add-ons platform, you can also build your own addons.

## What is Contour?

Contour is an Ingress controller for Kubernetes that works by deploying the [Envoy Proxy](https://www.envoyproxy.io/) as a reverse proxy and load balancer. Unlike other Ingress controllers, Contour supports dynamic configuration updates out of the box while maintaining a lightweight profile.

Contour also introduces a new ingress API ([IngressRoute](https://github.com/heptio/contour/blob/master/docs/ingressroute.md)) which is implemented via a Custom Resource Definition (CRD). Its goal is to expand upon the functionality of the Ingress API to allow for richer user experience as well as solve shortcomings in the original design.

## Prerequisites

RBAC must be enabled on the Kubernetes Cluster.

## Get Started

You can install Contour on the Kubernetes cluster via TK8 addons functionality.

What do you need:
- tk8 binary
- A Kubernetes cluster that supports Service objects of type: LoadBalancer

## Deploy Contour on your Kubernetes Cluster

Run:

    $ tk8 addon install contour

This command will clone the https://github.com/kubernauts/tk8-addon-contour repository locally and will setup contour.

This command also creates:
- A heptio-contour namespace
- Deploys contour as a daemonset
- A Service of type: LoadBalancer that points to the Contour instances

## Find the hostname/IP address of the contour deployment

For finding the hostname/IP address which was assigned to the contour service, run:
```
$ kubectl get -n heptio-contour service contour -o wide
 
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE   SELECTOR
contour   LoadBalancer   10.43.243.202   84.200.100.228   80:30530/TCP,443:30711/TCP   16m   app=contour
```
Note down the value just below EXTERNAL-IP.

## Test your Contour deployment

There are two ways to test your Contour deployment:
- via Ingress
- via IngressRoute

### Test with Ingress

For testing your deployment with Ingress, we'll deploy a demo application kuard along with an ingress resource. Run:
    
    $ kubectl apply -f https://raw.githubusercontent.com/heptio/contour/master/deployment/example-workload/kuard.yaml

You can monitor the progress of the deployment by running:
```
$ kubectl get po,svc,ing -l app=kuard
 
NAME                         READY   STATUS    RESTARTS   AGE
pod/kuard-6b6995ff77-cdvfd   1/1     Running   0          3d4h
pod/kuard-6b6995ff77-cxds6   1/1     Running   0          3d4h
pod/kuard-6b6995ff77-d8vg4   1/1     Running   0          3d4h
 
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kuard   ClusterIP   10.43.80.123   <none>        80/TCP    3d4h
 
NAME                       HOSTS   ADDRESS                                                                      PORTS   AGE
ingress.extensions/kuard   *       84.200.100.197,84.200.100.199,84.200.100.201,84.200.100.203,84.200.100.205   80      9m14s
```

Now, navigate to the contour deployment's IP address in the browser and you should see a demo application up and running.

### Test with IngressRoute

To test your Contour deployment with IngressRoutes, run the following command:
```
$ kubectl apply -f https://raw.githubusercontent.com/heptio/contour/master/deployment/example-workload/kuard-ingressroute.yaml
deployment.apps/kuard created
service/kuard created
ingressroute.contour.heptio.com/kuard created
```

Then monitor the progress of the deployment with:
```
$ kubectl get po,svc,ingressroute -l app=kuard
 
NAME                         READY   STATUS    RESTARTS   AGE
pod/kuard-6b6995ff77-2vhf7   1/1     Running   0          69s
pod/kuard-6b6995ff77-pv95t   1/1     Running   0          69s
pod/kuard-6b6995ff77-wndph   1/1     Running   0          69s
 
NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kuard   ClusterIP   10.43.49.36   <none>        80/TCP    69s
 
NAME                                    FQDN          TLS SECRET   FIRST ROUTE   STATUS   STATUS DESCRIPTION
ingressroute.contour.heptio.com/kuard   kuard.local                /             valid    valid IngressRoute
```

Now, use curl with the IP or DNS address of the Contour Service to send a request to the demo application:

    curl -H 'Host: kuard.local' ${CONTOUR_IP}

## Running Contour alongside other Ingress Controllers on a Kubernetes Cluster

If you're running multiple ingress controllers or running on a cloud provider that natively handles ingress, you can specify the annotation kubernetes.io/ingress.class: "contour" on all ingresses that you would like Contour to claim. If the kubernetes.io/ingress.classannotation is present with a value other than "contour", Contour will ignore that ingress.

## Uninstall Contour

For removing Contour from your cluster, we can use TK8 addon's destroy functionality. Run:
```
$ tk8 addon destroy contour
Search local for contour
Addon contour already exist
Found contour local.
Destroying contour
execute main.sh
Creating main.yaml
add  ./contour-config/01-common.yaml
add  ./contour-config/02-contour.yaml
add  ./contour-config/02-rbac.yaml
add  ./contour-config/02-service.yaml
delete contour from cluster
namespace "heptio-contour" deleted
serviceaccount "contour" deleted
customresourcedefinition.apiextensions.k8s.io "ingressroutes.contour.heptio.com" deleted
customresourcedefinition.apiextensions.k8s.io "tlscertificatedelegations.contour.heptio.com" deleted
daemonset.extensions "contour" deleted
clusterrolebinding.rbac.authorization.k8s.io "contour" deleted
clusterrole.rbac.authorization.k8s.io "contour" deleted
service "contour" deleted
contour destroy complete
```
