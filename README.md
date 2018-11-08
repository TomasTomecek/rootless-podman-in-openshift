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
$ make shell
oc exec -ti podman -- bash
bash-4.4$ podman --storage-driver=vfs pull fedora:29
```
