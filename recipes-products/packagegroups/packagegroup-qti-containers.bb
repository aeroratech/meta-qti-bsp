SUMMARY = "Grouping of programs for running docker containers on Embedded Linux System"
DESCRIPTION = "Package group to bring in packages for running containers"
LICENSE = "BSD-3-Clause"

inherit packagegroup distro_features_check

REQUIRED_DISTRO_FEATURES += "virtualization"

PROVIDES = "${PACKAGES}"

PACKAGES = ' \
    packagegroup-qti-containers \
    '

# Startup scripts needed during device bootup
RDEPENDS_packagegroup-containers= "\
    aufs-util \
    ca-certificates \
    chrony \
    cgroup-lite \
    docker \
    docker-registry \
    python3-docker-compose \
"
