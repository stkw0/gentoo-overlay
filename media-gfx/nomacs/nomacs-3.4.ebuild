# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github"

inherit cmake-utils xdg git-hosting

DESCRIPTION="Qt-based image viewer"
HOMEPAGE="https://www.nomacs.org/ ${HOMEPAGE}"
LICENSE="GPL-3+"

plugins_commit="fd199cf231257bd91fc9fd9aabc36d91d4a28ccd" # 2016-07-22
SLOT="0"
SRC_URI+="
	plugins? ( https://github.com/${PN}/${PN}-plugins/archive/${plugins_commit}.tar.gz
		-> ${PN}-plugins-${PV}.tar.gz )"

KEYWORDS="~amd64"
IUSE="debug opencv +plugins raw tiff zip"

CDEPEND_A=(
	# qt deps specified in '${S}/cmake/Utils.cmake'
	"dev-qt/qtconcurrent:5"
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtprintsupport:5"
	"dev-qt/qtsvg:5"
	"dev-qt/qtwidgets:5"

	">=media-gfx/exiv2-0.25:="

	"opencv? ( >=media-libs/opencv-2.1.0:=[qt5] )"
	"raw? ( >=media-libs/libraw-0.12.0:= )"
	"tiff? ( media-libs/tiff:0 )"
	"zip? ( dev-libs/quazip[qt5] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-qt/linguist-tools:5"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE="
	raw? ( opencv )
	tiff? ( opencv )
"

inherit arrays

L10N_LOCALES=( ar ru uk nl de az hr es en ko fr bg sk pt sl zh cs bs sr pl als ja it )
inherit l10n-r1

S_OLD="${S}"
S="${S}/ImageLounge"

src_unpack() {
	git-hosting_src_unpack
	default

	[[ -d "${S}"/plugins ]] && die
	mv "${WORKDIR}"/*plugins* "${S}/plugins" || die
}

src_prepare-locales() {
	local l locales dir='translations' pre="${PN}_" post='.ts'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rm -v -f "${dir}/${pre}${l}${post}" || die
	done
}

src_prepare() {
	# prevent these from interfering with the build
	rm -rf "${S_OLD}"/{LibRaw-*,exiv2-*,expat,herqq,installer,zlib-*} || die
	rm -rf "${S}"/3rdparty/quazip-* || die

	sed -e "s|@EPREFIX@|${EPREFIX}|g" \
		-e "s|@libdir@|$(get_libdir)|g" \
		-- "${FILESDIR}"/3.4-fix_plugins_dir.patch.in \
		> "${T}"/3.4-fix_plugins_dir.patch || die

	if use plugins ; then
		sed -e "s|DESTINATION lib/nomacs-plugins|DESTINATION $(get_libdir)/nomacs-plugins|" \
			-i plugins/cmake/Utils.cmake || die
	fi

	eapply "${T}"/3.4-fix_plugins_dir.patch

	xdg_src_prepare
	cmake-utils_src_prepare

	src_prepare-locales
}

src_configure() {
	local mycmakeargs=(
		-D USE_SYSTEM_QUAZIP=ON
		# this app uses patched libqpsd + libqpsd is not in the tree
		# -D USE_SYSTEM_LIBQPSD=ON

		-D DISABLE_QT_DEBUG=$(usex debug)
		-D ENABLE_OPENCV=$(usex opencv)
		-D ENABLE_PLUGINS=$(usex plugins)
		-D ENABLE_RAW=$(usex raw)
		-D ENABLE_TIFF=$(usex tiff)
		# upnp support requires:
		# 	- fork herqq to a github/gitlab repo / use hupnp-ng
		# 		- because HUpnpAV is currently only in original SVN repo
		# 	- create a new herqq package which would use that fork/*-ng
		# 	- patch build system to use upnp on linux (-DWITH_UPNP)
		# 	- test everything works as probably no one used nomacs with upnp before
		#-D ENABLE_UPNP=$(usex upnp)
		-D ENABLE_QUAZIP=$(usex zip)
	)
	cmake-utils_src_configure
}
