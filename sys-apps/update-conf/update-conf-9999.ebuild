# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit git-2

DESCRIPTION="script for flexible /etc/<conf>.d configuration"
HOMEPAGE="http://forums.gentoo.org/viewtopic.php?p=6364143"
EGIT_REPO_URI="git://github.com/Atha/${PN}.d"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="simple"

RDEPEND=""
DEPEND="${RDEPEND}"

DOCS="README USAGE"

src_prepare() {
	echo "patching the makefile with s:^PREFIX=:PREFIX=${D}: (required to prevent make to write outside the sandbox)"
	sed -i "s:^PREFIX=:PREFIX=${D}:" Makefile
	echo "patching the configuration to ensure it looks in /etc instead of in the sandbox"
	sed -i 's%@CONFIGDIR@%/etc%' update-conf.d.simple.in
	sed -i 's%@CONFIGDIR@%/etc%' update-conf.d.complex.in
	echo "patching the makefile so the installation path is /usr instead of /usr/local"
	sed -i 's:^INSTALLDIR=\$(PREFIX)/usr/local:INSTALLDIR=\$(PREFIX)/usr:' Makefile
}

src_configure() {
	emake clean
	if use simple ; then
	    emake simple
	else # default to complex version
	    emake complex
	fi
}

src_compile() {
	emake install

	dodoc ${DOCS}
#	use complex && doman update-conf.d.8
}
