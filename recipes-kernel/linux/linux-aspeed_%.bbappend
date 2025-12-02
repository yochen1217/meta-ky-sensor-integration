FILESEXTRAPATHS:prepend:romulus := "${THISDIR}/${PN}:"

SRC_URI:append:romulus = " \
    file://0001-add-tmp105-sensor-on-i2c2.patch \
    file://romulus-tmp105.cfg \
"

KERNEL_CONFIG_FRAGMENTS:append:romulus = " ${WORKDIR}/romulus-tmp105.cfg"
