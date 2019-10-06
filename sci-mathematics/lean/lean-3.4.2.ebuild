# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit git-r3 multilib cmake-utils

DESCRIPTION="Lean Theorem Prover"
HOMEPAGE="http://leanprover.github.io/"
EGIT_REPO_URI="https://github.com/leanprover/lean.git"
EGIT_COMMIT="v${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/gmp"
DEPEND="${RDEPEND}"

CMAKE_USE_DIR=${S}/src

src_configure() {
	local mycmakeargs=(
		-DLIBRARY_DIR="$(get_libdir)/${PN}"
	)

	sed -i -e 's@DESTINATION lib)@DESTINATION '"$(get_libdir)"')@g' "${S}"/src/CMakeLists.txt || die

	cmake-utils_src_configure
}
