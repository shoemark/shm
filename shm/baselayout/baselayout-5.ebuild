EAPI=5

inherit shm-config shm-repo systemd

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="
	charsets_utf8
	locales_c
	locales_de_de
	locales_en_us
	openrc
	system_charset_utf8
	system_keymap_us
	system_keymap_de_latin1
	system_keymap_de_latin1_nodeadkeys
	system_locale_c
	system_locale_de_de
	system_locale_en_us
	system_rtc_local
	system_rtc_utc
	system_timezone_europe_berlin
	system_timezone_utc
	systemd
"

DEPEND="app-portage/eix
	app-portage/gentoolkit
	app-portage/portage-utils
	net-misc/openssh
	sys-apps/baselayout
	sys-apps/eprl
	sys-apps/portage
	sys-process/dcron"
RDEPEND="${DEPEND}
	openrc? (
		sys-apps/openrc
	)
	systemd? (
		sys-apps/systemd dev-python/python-systemd
	)"
PDEPEND="systemd? (
		sys-apps/gentoo-systemd-integration
	)"

S="${WORKDIR}"

SHM_CONFIG_POSTINST_FILES_HOOKS=(
	'/var/spool/cron/crontabs => chown root:cron'
	'/var/spool/cron/crontabs => chmod u=rwX,g=wX,o=t'
	'/var/spool/cron/crontabs/root => chown root:root'
	'/var/spool/cron/crontabs/root => chmod 0600'
)

pkg_setup() {
	# we must capture these variables here as they become the host's values
	# later.
	export hostname="${HOSTNAME}"
	export domainname="${DOMAINNAME}"
	export fqdn="${HOSTNAME}.${DOMAINNAME}"
}

_set_hostname() {
	einfo "changing ${ROOT}etc/hostname"
	if [ -n "${hostname}" ] ; then
		echo "${hostname}" >"${ROOT}"etc/hostname
	fi

	einfo "changing ${ROOT}etc/conf.d/hostname"
	if [ -e "${ROOT}"etc/conf.d/hostname -a -n "${hostname}" ] ; then
		shm-config_ensureassigns "${ROOT}"etc/conf.d/hostname "=" "#" \
			"hostname='${hostname}'"
	fi

	einfo "changing ${ROOT}etc/conf.d/net"
	if [ -e "${ROOT}"etc/conf.d/net -a -n "${domainname}" ] ; then
		shm-config_ensureassigns "${ROOT}"etc/conf.d/net "=" "#" \
			"dns_domain_lo='${domainname}'"
	fi

	einfo "changing ${ROOT}etc/hosts"
	if [ -e "${ROOT}"etc/hosts ] ; then
		local _hostname=${hostname:+ ${hostname}}
		local _fqdn=${fqdn:+ ${fqdn}}
		sed -i \
			-e 's@^\(127\.0\.0\.1\s\+\).*$@\1localhost localhost4'""'@' \
			-e 's@^\(::1\s\+\).*$@\1localhost localhost6'""'@' \
			"${ROOT}"etc/hosts
	fi
}

src_install() {
	shm-config_install_files

	#
	# configure /etc/locale.gen
	#
	local locale charset
	for locale in ${LOCALES} ; do
		case "${locale}" in
			c)		locale="C" ;;
			??_??)	locale=$(awk -F_ '{ OFS="_"; print $1, toupper($2) } ' <<<"${locale}") ;;
		esac
		for charset in ${CHARSETS} ; do
			case "${charset}" in
				utf8)	charset="UTF-8" ;;
				*)		;;
			esac
			echo "${locale}.${charset} ${charset}" >>"${D}"etc/locale.gen
		done
	done

	#
	# configure /etc/localtime
	#
	if use system_timezone_utc ; then
		dosym ../usr/share/zoneinfo/UTC /etc/localtime
	elif use system_timezone_europe_berlin ; then
		dosym ../usr/share/zoneinfo/Europe/Berlin /etc/localtime
	else
		dosym ../usr/share/zoneinfo/UTC /etc/localtime
	fi

	#if use systemd ; then
		#
		# configure /etc/locale.conf
		#
		if use system_locale_c ; then
			echo -n "LANG=C" >>"${D}"etc/locale.conf
		elif use system_locale_de_de ; then
			echo -n "LANG=de_DE" >>"${D}"etc/locale.conf
		elif use system_locale_en_us ; then
			echo -n "LANG=en_US" >>"${D}"etc/locale.conf
		else
			echo -n "LANG=C" >>"${D}"etc/locale.conf
		fi
		if use system_charset_utf8 ; then
			echo ".UTF-8" >>"${D}"etc/locale.conf
		else
			echo ".UTF-8" >>"${D}"etc/locale.conf
		fi

		#
		# configure /etc/vconsole.conf
		#
		if use system_keymap_us ; then
			echo "KEYMAP=us" >>"${D}"etc/vconsole.conf
		elif use system_keymap_de_latin1 ; then
			echo "KEYMAP=de-latin1" >>"${D}"etc/vconsole.conf
		elif use system_keymap_de_latin1_nodeadkeys ; then
			echo "KEYMAP=de-latin1-nodeadkeys" >>"${D}"etc/vconsole.conf
		else
			echo "KEYMAP=us" >>"${D}"etc/vconsole.conf
		fi
		if use system_charset_utf8 ; then
			echo "UNICODE=1" >>"${D}"etc/vconsole.conf
		else
			echo "UNICODE=0" >>"${D}"etc/vconsole.conf
		fi
		#echo "FONT=lat9w-16" >>vconsole.conf
		#echo "FONT_MAP=8859-1_to_uni" >>vconsole.conf
		echo "FONT=LatArCyrHeb-16" >>"${D}"etc/vconsole.conf
	#fi

	#if use openrc ; then
		#
		# configure /etc/conf.d/keymaps
		#
		if use system_keymap_us ; then
			shm-config_ensureassigns "${D}"etc/conf.d/keymaps '=' '#' \
				'keymap="us"'
		elif use system_keymap_de_latin1 ; then
			shm-config_ensureassigns "${D}"etc/conf.d/keymaps '=' '#' \
				'keymap="de-latin1"'
		elif use system_keymap_de_latin1_nodeadkeys ; then
			shm-config_ensureassigns "${D}"etc/conf.d/keymaps '=' '#' \
				'keymap="de-latin1-nodeadkeys"'
		else
			shm-config_ensureassigns "${D}"etc/conf.d/keymaps '=' '#' \
				'keymap="us"'
		fi

		#
		# configure /etc/conf.d/hwclock
		#
		if use system_rtc_utc ; then
			shm-config_ensureassigns "${D}"etc/conf.d/hwclock '=' '#' \
				'clock="UTC"'
		elif use system_rtc_local ; then
			shm-config_ensureassigns "${D}"etc/conf.d/hwclock '=' '#' \
				'clock="local"'
		else
			shm-config_ensureassigns "${D}"etc/conf.d/hwclock '=' '#' \
				'clock="UTC"'
		fi

		#
		# configure /etc/env.d/02locale
		#
		if use system_locale_c ; then
			shm-config_ensureassigns "${D}"etc/env.d/02locale '=' '#' \
				'LANG="C"'
		elif use system_locale_en_us && use system_charset_utf8 ; then
			shm-config_ensureassigns "${D}"etc/env.d/02locale '=' '#' \
				'LANG="en_US.UTF-8"'
		elif use system_locale_de_de && use system_charset_utf8 ; then
			shm-config_ensureassigns "${D}"etc/env.d/02locale '=' '#' \
				'LANG="de_DE.UTF-8"'
		else
			shm-config_ensureassigns "${D}"etc/env.d/02locale '=' '#' \
				'LANG="C"'
		fi
	#fi

	#
	# configure /etc/X11/xorg.conf.d/00-keyboard.conf
	#
	if use system_keymap_us ; then
		sed -i -e '/^\s*Option "XkbLayout"/ s@"[^"]*"\s*$@"us"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
		sed -i -e '/^\s*Option "XkbVariant"/ s@"[^"]*"\s*$@""@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
	elif use system_keymap_de_latin1 ; then
		sed -i -e '/^\s*Option "XkbLayout"/ s@"[^"]*"\s*$@"de,de,us"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
		sed -i -e '/^\s*Option "XkbVariant"/ s@"[^"]*"\s*$@",nodeadkeys,"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
	elif use system_keymap_de_latin1_nodeadkeys ; then
		sed -i -e '/^\s*Option "XkbLayout"/ s@"[^"]*"\s*$@"de,de,us"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
		sed -i -e '/^\s*Option "XkbVariant"/ s@"[^"]*"\s*$@"nodeadkeys,,"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
	else
		sed -i -e '/^\s*Option "XkbLayout"/ s@"[^"]*"\s*$@"us"@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
		sed -i -e '/^\s*Option "XkbVariant"/ s@"[^"]*"\s*$@""@' "${D}"etc/X11/xorg.conf.d/00-keyboard.conf
	fi

	#
	# configure runlevels and services
	#
	if use openrc ; then
		dosym /etc/init.d/local			/etc/runlevels/maintenance/local
		dosym /etc/init.d/dcron			/etc/runlevels/maintenance/dcron
		dosym /etc/init.d/ntp-client	/etc/runlevels/maintenance/ntp-client
		dosym /etc/init.d/sshd			/etc/runlevels/maintenance/sshd

		dosym /etc/init.d/local			/etc/runlevels/default/local
		dosym /etc/init.d/dcron			/etc/runlevels/default/dcron
		dosym /etc/init.d/ntpd			/etc/runlevels/default/ntpd
		dosym /etc/init.d/sshd			/etc/runlevels/default/sshd
	fi
	if use systemd ; then
		local systemd_unitdir=$(systemd_get_unitdir)

		dosym ../../../lib/systemd/system/maintenance.target /etc/systemd/system/runlevel2.target

		systemd_enable_service maintenance.target dcron.service
		systemd_enable_service maintenance.target systemd-timesyncd.service
		systemd_enable_service maintenance.target sshd.service

		systemd_enable_service multi-user.target dcron.service
		systemd_enable_service multi-user.target systemd-timesyncd.service
		systemd_enable_service multi-user.target sshd.service
	fi

	#
	# install the system crontab as root's crontab for dcron
	#
	insinto /var/spool/cron/crontabs
	addread "${ROOT}"etc/crontab
	newins "${ROOT}"etc/crontab root

	#
	# add root to update_crons
	#
	insinto /var/spool/cron/crontabs
	local update_crons=var/spool/cron/crontabs/update_crons
	addread "${ROOT}${update_crons}"
	doins "${ROOT}${update_crons}"
	grep -F -q 'root' "${D}${update_crons}" 2>/dev/null || echo 'root' >>"${ROOT}${update_crons}"

	# fix permissions
	shm-config_postinst_files "${D}"
}

pkg_postinst() {
	_set_hostname

	einfo "changing ${ROOT}etc/inittab"
	if use openrc ; then
		sed -i -e '/^l2:/{s/nonetwork/maintenance/g}' "${ROOT}"etc/inittab
	fi

	if use systemd ; then
		einfo "changing ${ROOT}lib/systemd/system-generators"
		patch -s --forward -r- -d "${ROOT}"lib/systemd/system-generators <"${ROOT}"etc/portage/patches/sys-apps/gentoo-systemd-integration/maintenance-target.patch
		grep -q 'maintenance' "${ROOT}"lib/systemd/system-generators/gentoo-local-generator || die
	fi

	#
	# set up SSH config
	#
	einfo "changing ${ROOT}etc/ssh/sshd_config"
	shm-config_ensureassigns "${ROOT}"etc/ssh/sshd_config " " "#" \
		"PasswordAuthentication no" \
		"PermitRootLogin without-password" \
		"StrictModes no" \
		"PermitUserEnvironment yes"

	#
	# configure root's bash
	#
	einfo "changing ${ROOT}root/.bashrc"
	shm-config_ensurelines "${ROOT}"root/.bashrc \
		'set -b' \
		'set -o vi'

	#
	# add -c to man.conf; fixes colors for, e.g., vim's Man viewer
	#
	for roff in ^TROFF= ^NROFF= ^JNROFF= ; do
		if ! grep -e "${roff}" "${ROOT}"etc/man.conf | grep -e ' -c\>' >/dev/null ; then
			sed -i -e "s/${roff}.*$/& -c/" "${ROOT}"etc/man.conf || ewarn "failed to configure ${ROOT}etc/man.conf"
		fi
	done

	# fix permissions
	shm-config_postinst_files "/"
}
