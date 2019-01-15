CONT_NAME := working-container
IMAGE_NAME := rootless-podman
BASE_IMAGE_NAME := registry.fedoraproject.org/fedora:29
AP := ansible-playbook -i inventory-localhost -c local

ifeq (, $(shell which ansible-bender))
	$(error "Please install ansible-bender (pip3 install --user ansible-bender), podman and buildah (dnf install -y podman buildah).")
endif

run:
	$(AP) ./voodoo.yaml

run-cached:
	$(AP) -e recreate=false -v ./voodoo.yaml

build:
	sudo ansible-bender build \
		-e "LD_PRELOAD=libnss_wrapper.so" \
		   "NSS_WRAPPER_PASSWD=/home/podm/passwd" \
		   "NSS_WRAPPER_GROUP=/etc/group" \
		   "USER=podm" \
		   "HOME=/home/podm" -- \
		./build.yaml $(BASE_IMAGE_NAME) $(IMAGE_NAME)
	sudo ansible-bender push docker-daemon:$(IMAGE_NAME):latest

old-build:
	docker image inspect $(BASE_IMAGE_NAME) >/dev/null || docker pull $(BASE_IMAGE_NAME) >/dev/null
	docker container inspect $(CONT_NAME) >/dev/null && docker rm -f $(CONT_NAME) || :
	docker run --name $(CONT_NAME) -u root -ti -d $(BASE_IMAGE_NAME) bash
	ansible-playbook -i inventory-container -c docker ./build.yaml
	docker stop $(CONT_NAME)
	docker commit \
		-c "ENV LD_PRELOAD=libnss_wrapper.so" \
		-c "ENV NSS_WRAPPER_PASSWD=/home/podm/passwd" \
		-c "ENV NSS_WRAPPER_GROUP=/etc/group" \
		-c "ENV USER=podm" \
		-c "ENV HOME=/home/podm" \
		$(CONT_NAME) $(IMAGE_NAME)
	docker rm $(CONT_NAME)
