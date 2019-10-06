# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Markus Schöngart
# Purpose: Install repository configurations in /etc/portage/repos.conf and
#          create the destination directory.
#

shm-repo_new() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf
	local repo_location=$(sed -ne 's@^\s*location\*=\*\(\S\+\)\s*$@\1@p' <"${repo_conf}" | head -n1)

	if [ -n "${repo_location}" ]; then
		dodir "${repo_location}"
		fowners portage:portage "${repo_location}"
	fi
}

shm-repo_getsync_scheme() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_getsync_scheme: repository \`${repo_conf}' does not exist"
	fi

	sed -ne '
		s|^#\?\s*\(sync-uri\s*=\s*\)\(\w\+://\)\(\([^@]\+\)@\)\?\([[:alnum:]._-]\+\)\(.*\)$\s*|\2|p
	' "${repo_conf}" \
		| head -n1
}

shm-repo_getsync_user() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_getsync_user: repository \`${repo_conf}' does not exist"
	fi

	sed -ne '
		s|^#\?\s*\(sync-uri\s*=\s*\)\(\w\+://\)\(\([^@]\+\)@\)\?\([[:alnum:]._-]\+\)\(.*\)\s*$|\4|p
	' "${repo_conf}" \
		| head -n1
}

shm-repo_getsync_host() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_getsync_host: repository \`${repo_conf}' does not exist"
	fi

	sed -ne '
		s|^#\?\s*\(sync-uri\s*=\s*\)\(\w\+://\)\(\([^@]\+\)@\)\?\([[:alnum:]._-]\+\)\(.*\)\s*$|\5|p
	' "${repo_conf}" \
		| head -n1
}

shm-repo_getsync_path() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_getsync_path: repository \`${repo_conf}' does not exist"
	fi

	sed -ne '
		s|^#\?\s*\(sync-uri\s*=\s*\)\(\w\+://\)\(\([^@]\+\)@\)\?\([[:alnum:]._-]\+\)\(.*\)\s*$|\6|p
	' "${repo_conf}" \
		| head -n1
}

shm-repo_setsync_uri() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	local repo_uri=${2}

	#local repo_scheme=${2:-$(shm-repo_getsync_scheme "${repo_conf_name}")}
	#local repo_user=${3:-$(shm-repo_getsync_user "${repo_conf_name}")}
	#local repo_host=${4:-$(shm-repo_getsync_host "${repo_conf_name}")}
	#local repo_path=${5:-$(shm-repo_getsync_path "${repo_conf_name}")}
	#local repo_uri="${repo_scheme}${repo_user:+${repo_user}@}${repo_host}${repo_path}"

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_getsync_uri: repository \`${repo_conf}' does not exist"
	fi

	if [ -z "${repo_uri}" ]; then
		eerror "shm-repo_setsync_uri: new synchronization uri \`${repo_uri}' is invalid"
	fi

	sed -i -e '
		s|^#\?\s*\(sync-type\s*=\s*.*\)\s*$|\1|
		s|^#\?\s*\(sync-uri\s*=\s*\)\(\w\+://\)\(\([^@]\+\)@\)\?\([[:alnum:]._-]\+\)\(.*\)\s*$|\1'"${repo_uri}"'|
	' "${repo_conf}" || die
}

shm-repo_setnosync() {
	local repo_conf_name=${1}
	local repo_conf="${D}"etc/portage/repos.conf/"${repo_conf_name}".conf

	if [ -z "${repo_conf}" -o ! -f "${repo_conf}" ]; then
		eerror "shm-repo_setnosync: repository \`${repo_conf}' does not exist"
	fi

	sed -i -e '
		s,^sync-type = .*$,#&,
		s,^sync-uri = .*$,#&,
	' "${repo_conf}" || die
}
