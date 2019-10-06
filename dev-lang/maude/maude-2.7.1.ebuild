# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools epatch

DESCRIPTION="High-level specification language for equational and logic programming"
HOMEPAGE="http://maude.cs.uiuc.edu/"
SRC_URI="
	http://maude.cs.illinois.edu/w/images/d/d8/Maude-2.7.1.tar.gz
	http://maude.cs.illinois.edu/w/images/c/ca/Full-Maude-2.7.1.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cvc4"

RDEPEND="
	dev-libs/gmp:0=[cxx]
	dev-libs/libsigsegv
	dev-libs/libtecla
	sci-libs/buddy
	cvc4? ( sci-mathematics/cvc4 )"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex"

#S="${WORKDIR}/${P}"

PATCHES=(
	"${FILESDIR}/${PN}-2.5.0-prll.patch"
	"${FILESDIR}/${PN}-2.6-search-datadir.patch"
)

src_prepare() {
	sed -i -e "s:/usr:${EPREFIX}/usr:g" src/Mixfix/global.hh || die
	sed -i -e 's@((smtType == SMT_Info::BOOLEAN) ? kind::IFF : kind::EQUAL)@kind::EQUAL@' src/Mixfix/variableGenerator.cc || die

	epatch "${FILESDIR}"/"${P}"-underlinking.patch
	default_src_prepare

	eautoreconf
}

src_configure() {
	CPPFLAGS="-I/usr/include/cvc4" \
	econf \
		$(use_with cvc4) \
		--with-tecla \
		--with-libsigsegv
}

src_install() {
	default

	# install data and full maude
	insinto /usr/share/${PN}
	doins -r src/Main/*.maude
	doins -r "${WORKDIR}"/*.maude
}
