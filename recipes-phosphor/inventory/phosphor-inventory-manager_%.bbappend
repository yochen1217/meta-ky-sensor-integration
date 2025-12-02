FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
PACKAGECONFIG:append = " associations"
SRC_URI += " file://associations.json"

do_install:append() {
    install -d ${D}${datadir}/phosphor-inventory-manager
    install -m 0644 ${WORKDIR}/sources-unpack/associations.json \
        ${D}${datadir}/phosphor-inventory-manager/associations.json
}
