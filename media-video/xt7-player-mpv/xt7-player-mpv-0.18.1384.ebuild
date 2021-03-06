# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI='github/kokoko3k'
GH_REF="${PV}"

inherit git-hosting eutils xdg

DESCRIPTION="Graphical interface to mpv, focused on usability"
HOMEPAGE="http://xt7-player.sourceforge.net/xt7forum/ ${HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE="taglib global-hotkeys dvb youtube" # FIXME

DEPEND="
	dev-lang/gambas:3[libxml,qt4,dbus,x11,net,curl]
	media-video/mpv
"
RDEPEND="${DEPEND}
	x11-misc/xbindkeys"

src_compile() {
	local gbc_args=(
		# --verbose # this is extremely verbose
		--translate-errors
		--all
		--translate # l10n
		--public-control
		--public-module
	)
	gbc3 "${gbc_args[@]}" . || die
	gba3 || die
}

src_install() {
	newbin ${PN}*.gambas "${PN}"

	# fix bin name
	sed -e "s|${PN}.*\.gambas|${PN}|" \
        -i -- "${PN}.desktop" || die
	domenu "${PN}.desktop"

	doicon -s 48 "${PN}.png"
}
