if [ "${EBUILD_PHASE}" == "prepare" ]; then
	if [ "$(type -t epatch_user)" == "function" ]; then
		if [ -d "${S}" ]; then
			cd "${S}" && epatch_user
		fi
	fi
fi

if [ -f "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${PF}" ] ; then
	. "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${PF}"
elif [ -f "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${P}" ] ; then
	. "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${P}"
elif [ -f "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${PN}" ] ; then
	. "${ROOT}"/etc/portage/package.bashrc/"${CATEGORY}"/"${PN}"
fi
