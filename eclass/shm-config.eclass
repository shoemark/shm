# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Markus Schöngart
# Purpose: Update configuration files
#

inherit shm-repo

shm-config_ensurelines() {
	linenos=()
	local file="$1"
	shift 1
	local line lineno
	if [ ! -e "${file}" ]; then
		touch "${file}"
	fi
	if [ ! -f "${file}" ]; then
		die "shm-config_ensurelines: \`${file}' is not a file"
	fi
	for line in "$@"; do
		lineno=$(grep -F -n -x "${line}" "${file}" | cut -f1 -d:; exit ${PIPESTATUS[0]})
		if [ $? -ne 0 ]; then
			lineno=$(wc -l <"${file}")
			sed -i -e "$ a ${line}" "${file}"
			let lineno=${lineno}+1
		fi
		linenos=(${linenos[@]} ${lineno})
	done
}

shm-config_commentlines() {
	linenos=()
	local file="$1" comment_seq="$2"
	shift 2
	if [ ! -e "${file}" ]; then
		touch "${file}"
	fi
	if [ ! -f "${file}" ]; then
		die "shm-config_commentlines: \`${file}' is not a file"
	fi
	local line lineno
	for line in "$@"; do
		lineno=$(grep -F -n -x "${line}" "${file}" | cut -f1 -d:; exit ${PIPESTATUS[0]})
		if [ $? -eq 0 ]; then
			sed -i -e "${lineno} s/^.*$/${comment_seq}&/;" "${file}"
		fi
		linenos=(${linenos[@]} ${lineno})
	done
}

shm-config_ensureassigns() {
	linenos=()
	local file="$1" assign_seq="$2" comment_seq="$3"
	shift 3
	if [ ! -e "${file}" ]; then
		touch "${file}"
	fi
	if [ ! -f "${file}" ]; then
		die "shm-config_ensureassigns: \`${file}' is not a file"
	fi
	local assign var val lineno indent
	for assign in "$@"; do
		if ! gawk -F"${assign_seq}" '{ if ($2 != "") { exit 0; } exit 1; }' <<<"${assign}"; then
			die "shm-config_ensureassigns for non-assignment \`${assign}' requested"
		fi
	done
	for assign in "$@"; do
		var=$(gawk -F"${assign_seq}" '{ print $1 }' <<<"${assign}")
		val=$(gawk -F"${assign_seq}" '{ print $2 }' <<<"${assign}")
		# comment out all existing assignments to the same variable
		sed -i -e "s!^\(\s*\)\(${var}\s*${assign_seq}.*\)\$!\1${comment_seq}\2!" "${file}"
		# uncomment the first matching assignment, if any
		lineno=$(grep -E -n "^\s*${comment_seq}\s*${var}\s*${assign_seq}\s*${val}\s*$" "${file}" | cut -f1 -d: | head -n1; exit ${PIPESTATUS[0]})
		if [ $? -eq 0 ]; then
			sed -i -e "${lineno} s/^\(\s*\)${comment_seq}\s*/\1/" "${file}"
		else
			# insert new assignment after the first commented one, if any
			lineno=$(grep -E -n "^\s*${comment_seq}\s*${var}\s*${assign_seq}" "${file}" | cut -f1 -d: | head -n1; exit ${PIPESTATUS[0]})
			if [ $? -eq 0 ]; then
				indent=$(sed -ne "${lineno} s/^\(\s*\).*$/\1/p" "${file}")
				sed -i -e "${lineno} a ${indent}${assign}" "${file}"
				let lineno=${lineno}+1
			else
				# append assignment to the end of file
				lineno=$(wc -l <"${file}")
				sed -i -e "$ a ${assign}" "${file}"
				let lineno=${lineno}+1
			fi
		fi
		linenos=(${linenos[@]} ${lineno})
	done
}

shm-config_hostname() {
	#if grep '^src_' <<<"${EBUILD_PHASE_FUNC}" >/dev/null \
	#	&& grep '\<buildpkg\>' <<<"${PORTAGE_FEATURES}" >/dev/null; then
	#	die "Impossible to request the hostname in a binary build's src_* phase"
	#fi

	local etc_hostname=
	if [ -f "${ROOT}"/etc/hostname ]; then
		etc_hostname=$(cut -f1 -d'.' <"${ROOT}"/etc/hostname 2>/dev/null)
	fi

	if [ -n "${HOSTNAME}" ]; then
		echo "${HOSTNAME}"
	elif [ -n "${etc_hostname}" ]; then
		echo "${etc_hostname}"
	else
		ewarn "The hostname is unset, edit ${ROOT}etc/hostname"
		echo unknown
	fi
}

shm-config_domainname() {
	#if grep '^src_' <<<"${EBUILD_PHASE_FUNC}" >/dev/null \
	#	&& grep '\<buildpkg\>' <<<"${PORTAGE_FEATURES}" >/dev/null; then
	#	die "Impossible to request the domainname in a binary build's src_* phase"
	#fi

	local etc_hostname=
	if [ -f "${ROOT}"/etc/hostname ]; then
		etc_hostname=$(cut -f2- -d'.' <"${ROOT}"/etc/hostname 2>/dev/null)
	fi

	if [ -n "${DOMAINNAME}" ]; then
		echo "${DOMAINNAME}"
	elif [ -n "${etc_hostname}" ]; then
		echo "${etc_hostname}"
	else
		ewarn "The domainname is unset, edit ${ROOT}etc/hostname"
		echo local
	fi
}

shm-config_fqdn() {
	#if grep '^src_' <<<"${EBUILD_PHASE_FUNC}" >/dev/null \
	#	&& grep '\<buildpkg\>' <<<"${PORTAGE_FEATURES}" >/dev/null; then
	#	die "Impossible to request the FQDN in a binary build's src_* phase"
	#fi

	echo $(shm-config_hostname).$(shm-config_domainname)
}

shm-config_install_files() {
	cp -a "${FILESDIR}"/*/ "${D}" || die

	#
	# rename installed dotfiles
	#
	find "${D}" \( -name '_*' -or -name '*/_*' \) \
		| xargs -IFILE bash -c 'mv FILE $(sed -e "s@/_@/.@g" <<<"FILE") 2>/dev/null' || die

	#
	# configure Portage repositories and keys
	#
	for repo_conf in "${D}"etc/portage/repos.conf/*.conf ; do
		if [ -f "${repo_conf}" ] ; then
			local repo_conf_name=$(basename "${repo_conf}" | sed -e 's@\.conf$@@')
			shm-repo_new "${repo_conf_name}"

			local repo_sync_host=$(shm-repo_getsync_host "${repo_conf_name}")
			if [ -n "${repo_sync_host}" ] && [ "${fqdn}" == "${repo_sync_host}" ] ; then
				shm-repo_setnosync "${repo_conf_name}"
			fi
		fi
	done
}

shm-config_postinst_files() {
	local prefix=${1:="${D}"}

	#
	# run hooks on installed files
	#
	local filesdir=$(dirname "${EBUILD}")/files
	find "${filesdir}" | sed -e "s@^${filesdir}/*@/@ ; s@/_@/.@g" | while read path ; do
		for hook_spec in "${SHM_CONFIG_POSTINST_FILES_HOOKS[@]}" ; do
			path_regex=$(sed -e 's@^\(\S.*\S\)\s*=>.*$@\1@' <<<"${hook_spec}")
			action=$(sed -e 's@^.*=>\s*\(\S.*\S\)\s*$@\1@' <<<"${hook_spec}")

			if grep -E '^'"${path_regex}"'$' <<<"${path}" >/dev/null ; then
				einfo "${action} ${path}"
				bash -c "${action} ${prefix}${path}" || die "failed to execute '${action} ${prefix}${path}'"
			fi
		done
	done
}
