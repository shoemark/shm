# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit autotools git-r3

DESCRIPTION="The SMT solver."
HOMEPAGE="http://cvc4.cs.stanford.edu/web/"

EGIT_REPO_URI="https://github.com/CVC4/CVC4"
EGIT_COMMIT="${PV}"

LICENSE="BSD-4"
SLOT="0"
KEYWORDS="~amd64"
IUSE="abc +cln java +readline"

DEPEND="
	dev-libs/antlr-c
	dev-libs/boost
	dev-libs/gmp
	abc? ( sci-libs/abc )
	cln? ( sci-libs/cln )
	java? ( dev-lang/swig )
	readline? ( sys-libs/readline )
"
	#glpk? ( sci-mathematics/glpk-cut-log )
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user
	eautoreconf
}

src_configure() {
	econf --enable-gpl \
		$(use_with abc) \
		$(use_with cln) \
		--without-glpk \
		$(use_with java swig) \
		$(use_with readline)
}
