# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit git-r3

DESCRIPTION="Bounded Model Checking for Software"
HOMEPAGE="http://www.cprover.org/cbmc/"

SRC_URI="http://ftp.debian.org/debian/pool/main/m/minisat2/minisat2_2.2.1.orig.tar.gz"
EGIT_REPO_URI="https://github.com/diffblue/cbmc.git"
EGIT_COMMIT="${P}"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64"
IUSE="java"

DEPEND="sys-devel/bison
	sys-devel/flex
	java? ( dev-java/maven-bin )"
RDEPEND=""

src_unpack() {
	git-r3_src_unpack
	default_src_unpack

	mv "${WORKDIR}"/minisat2-2.2.1 "${S}"/minisat-2.2.1 || die
}

src_prepare() {
	pushd "${S}"/minisat-2.2.1 >/dev/null || die
	eapply -p1 ../scripts/minisat-2.2.1-patch || die
	popd || die

	default
}

src_compile() {
	emake -C "${S}"/src
}

src_install() {
	dobin "${S}"/src/"${PN}"/"${PN}"
}
