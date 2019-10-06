# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Markus Schöngart
# Purpose: Support the maintenance of /etc/<config>.d directories that are
#          assembled to /etc/<config> files.
#

# Set this to a list of <config> file names (under the `/etc/' prefix) for
# which a corresponding /etc/<config>.d directory shall be created and
# maintained.
# The <config> names may contain slashes as directory separator.
SHM_CONFIG_D_CREATE="${SHM_CONFIG_D_CREATE:-}"

# Set this to a list of <config> file names (under the `/etc/' prefix) that
# need to be updated
# The <config> names may contain slashes as directory separator.
SHM_CONFIG_D_UPDATE="${SHM_CONFIG_D_UPDATE:-${SHM_CONFIG_D_CREATE}}"

EXPORT_FUNCTIONS src_install pkg_postinst pkg_prerm pkg_postrm

DEPEND="${DEPEND}
	sys-apps/coreutils
	sys-apps/update-conf
"
RDEPEND="${RDEPEND}
	sys-apps/coreutils
	sys-apps/update-conf
"

shm-config_d_src_install() {
	local config

	for config in ${SHM_CONFIG_D_CREATE}; do
		dodir /etc/"${config}".d

		if [ -e "${ROOT}/etc/${config}.d/00original" ]; then
			# assume ownership of the 00original file so that it won't get
			# deleted when this package is uninstalled (or upgraded)
			cp "${ROOT}/etc/${config}.d/00original" "${D}/etc/${config}.d/00original" || die
		elif [ -e "${ROOT}/etc/${config}" ]; then
			cp "${ROOT}/etc/${config}" "${D}/etc/${config}.d/00original" || die
		fi
	done
}

shm-config_d_pkg_postinst() {
	local config

	for config in ${SHM_CONFIG_D_CREATE}; do
		if ! grep -F "${config}" ${ROOT}/etc/update-conf.d.conf >/dev/null 2>&1; then
			echo "${config}" >>${ROOT}/etc/update-conf.d.conf || die
		fi
	done

	for config in ${SHM_CONFIG_D_UPDATE}; do
		if [ -z "${ROOT}" -o "${ROOT}" = "/" ]; then
			update-conf.d "${config}"
		else
			: chroot ${ROOT} update-conf.d "${config}"
		fi
	done
}

shm-config_d_pkg_prerm() {
	local config escaped_config

	for config in ${SHM_CONFIG_D_CREATE}; do
		if [ -e "${ROOT}/etc/${config}.d/00original" ]; then
			cp "${ROOT}/etc/${config}.d/00original" "${ROOT}/etc/${config}" || die
		else
			rm -f "${ROOT}/etc/${config}"
		fi
		escaped_config=$(sed -e 's@/@\\/@g' <<<"${config}")
		sed -i -e "/^${config}$/d" ${ROOT}/etc/update-conf.d.conf || die
	done
}

shm-config_d_pkg_postrm() {
	local config

	for config in ${SHM_CONFIG_D_UPDATE}; do
		if grep -F "${config}" ${ROOT}/etc/update-conf.d.conf >/dev/null 2>&1; then
			if [ -z "${ROOT}" -o "${ROOT}" = "/" ]; then
				update-conf.d "${config}"
			else
				: chroot ${ROOT} update-conf.d "${config}"
			fi
		fi
	done
}
