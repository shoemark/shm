# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit cmake-utils

DESCRIPTION="DIVINE is a modern explicit-state model checker."
HOMEPAGE="https://divine.fi.muni.cz/"
SRC_URI="https://divine.fi.muni.cz/download/${P}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=">=sys-devel/clang-3.2[gold]"
RDEPEND="${DEPEND}"

BUILD_DIR="${WORKDIR}"/"${P}"_build

src_unpack() {
	default_src_unpack

	mkdir -p "${BUILD_DIR}" || die
	touch "${BUILD_DIR}"/config.vars || die
}
