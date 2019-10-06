# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit git-r3 eutils multilib versionator


DESCRIPTION="Ott is a tool for writing definitions of programming languages and calculi"
HOMEPAGE="https://www.cl.cam.ac.uk/~pes20/ott/"
EGIT_REPO_URI="https://github.com/ott-lang/ott.git"
EGIT_COMMIT="${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+ocamlopt"

RDEPEND="dev-lang/ocaml[ocamlopt?]"
DEPEND="${RDEPEND}
	sci-mathematics/coq"

src_prepare() {
	find "${S}" -name '*.v' -exec sed -i '
		s@^\(\s*\)Implicit Arguments\>@\1Arguments@
		s@^\(\s*Arguments \w\+\) \[\]@\1 : clear implicits@
	' '{}' ';' || die
}

src_configure() {
	:
}

src_compile() {
	if use ocamlopt ; then
		emake world
	else
		emake world.byt
	fi

	emake -C coq
}

src_install() {
	dobin bin/ott

	emake -C coq install DESTDIR="${D}"
}
