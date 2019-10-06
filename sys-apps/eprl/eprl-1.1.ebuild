# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )

inherit git-r3 distutils-r1

DESCRIPTION="Portage resume list editor."
HOMEPAGE="https://github.com/borysn/eprl"
EGIT_REPO_URI="https://github.com/borysn/eprl.git"
EGIT_COMMIT="${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
