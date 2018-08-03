# Running rootless podman in an OpenShift pod

## Usage

Build an image with podman first:
```
$ make build
```

Run it as an openshift pod now:
```
$ make run
```

And now you can play with podman!
```
$ make shell
oc exec -ti podman -- bash
bash-4.4$ podman
```
