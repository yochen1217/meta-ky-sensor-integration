FILESEXTRAPATHS:prepend:romulus := "${THISDIR}/${PN}:"

CHIPS:append:romulus = " bus@1e78a000/i2c@c0/tmp105@48"
