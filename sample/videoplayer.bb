SUMMARY     = "Demo app for video player"
DESCRIPTION = "AGL demo app for video player"
HOMEPAGE    = "http://oss-project.tmc-tokai.jp/gitlab/als2018/videoplayer"
SECTION     = "apps"

LICENSE     = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ae6497158920d9524cf208c09cc4c984"

USERNAME = ""
PASSWORD = ""

SRC_URI = "git://oss-project.tmc-tokai.jp/gitlab/als2018/videoplayer.git;protocol=http;branch=master;user=${USERNAME}:${PASSWORD}"
SRCREV  = "3663a5fb2eb9a7d9ff10a827c605bfe0e929ac90"

PV = "1.0+git${SRCPV}"
S  = "${WORKDIR}/git"

# build-time dependencies
DEPENDS += "qtquickcontrols2 qtmultimedia virtual/libhomescreen qlibwindowmanager"

# runtime dependencies
# RDEPENDS_${PN} += ""

inherit qmake5 aglwgt