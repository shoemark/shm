# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

EGIT_REPO_URI="https://github.com/powerline/fonts"

inherit git-r3 font

DESCRIPTION="Patched fonts for Powerline users"
HOMEPAGE="https://github.com/powerline/fonts"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=""
RDEPEND="${RDEPEND}"

FONT_SUFFIX="ttf otf"

src_install() {
	find "${S}" -type f \( -name '*.ttf' -or -name '*.otf' \) -exec mv '{}' "${S}" ';' || die
	font_src_install
}
