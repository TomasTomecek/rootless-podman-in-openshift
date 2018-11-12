# Running rootless podman in an OpenShift pod

## Usage

Build an image with podman first:
```
$ make build
```

Install and start openshift:
```
$ sudo dnf install -y origin
$ oc cluster up
```

Run it as an openshift pod now:
```
$ make run
```

And now you can play with podman!
```
$ oc get all
 NAME                                      READY     STATUS    RESTARTS   AGE
 pod/podman-in-okd-20181112t130610199320   1/1       Running   0          14s

$ oc exec -ti podman-in-okd-20181112t130610199320 -- bash
bash-4.4$ podman --storage-driver=vfs pull fedora:29
```
