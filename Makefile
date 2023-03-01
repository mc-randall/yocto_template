SHELL=/bin/bash -c

include default.cfg
export

ARG=${IMAGE}

define HELPMSG

Makefile for creating a Yocto project with the user configured variables.

  make <target>

  target :
    
    make fetch              		- Fetch source files and setup build environment.
    make bitbake [ARG=<recipe_name>] 	- Bitbake Yocto recipe, default value for ARG is the specified IMAGE. 
    make clean              		- Remove all outputs of Yocto image.
    make sdk                		- Build the Software Development Kit (SDK) for project.
    make sdk_ext            		- Build the extensible Software Development Kit (eSDK) for project.
    make runqemu            		- Run QEMU with current configuration and generated Yocto image.
    make bash            		- Create bash shell with configured Yocto build environment. 

endef


help:
	$(info $(HELPMSG))


fetch: FORCE
	# Fetch the manifest and checkout the target release version
	repo init -u ${MANIFEST_REPO} -m ${MANIFEST} -b ${RELEASE_TAG}

	# Fetch all the source from the repositories in the manifest
	repo sync

	cp ./sources/scripts/setupsdk .

	# Initialize project
	source setupsdk 

bitbake: FORCE
	source setupsdk && bitbake --postread=../${YOCTO_CFG} ${ARG}

sdk: FORCE
	source setupsdk && bitbake --postread=../${YOCTO_CFG} ${IMAGE} -c populate_sdk

sdk_ext: FORCE
	source setupsdk && bitbake --postread=../${YOCTO_CFG} ${IMAGE} -c populate_sdk_ext

runqemu: FORCE
	source setupsdk && MACHINE=${MACHINE} runqemu ${QEMU_ARGS} ${IMAGE}

bash: FORCE
	@source setupsdk && MACHINE=${MACHINE}; function bitbake() { command bitbake --postread=../${YOCTO_CFG} $$@; }; export -f bitbake && bash 

clean: FORCE
	source setupsdk && bitbake ${IMAGE} -c cleanall

#menuconfig: FORCE
#	source setupsdk && MACHINE=${MACHINE} bitbake --postread=../${YOCTO_CFG} -c menuconfig virtual/kernel

FORCE:

