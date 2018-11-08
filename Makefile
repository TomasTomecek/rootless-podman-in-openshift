CONT_NAME := working-container
IMAGE_NAME := rootless-podman
BASE_IMAGE_NAME := fedora:29
AP := ansible-playbook -i inventory-localhost -c local

run:
	$(AP) ./voodoo.yaml

run-cached:
	$(AP) -e recreate=false -v ./voodoo.yaml

build:
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

build-incr:
	docker container inspect $(CONT_NAME) >/dev/null && docker rm -f $(CONT_NAME) || :
	docker run --name $(CONT_NAME) -u root -ti -d $(IMAGE_NAME) bash
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

shell:
	oc exec -ti podman -- bash
