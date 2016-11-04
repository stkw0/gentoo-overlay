# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# last pre wxGTK3.1 release
# GH_REF="1bed09051b43e8e0cce5ffa3bceb52babb43a229" # 19.05.16
# GH_REF="eda8696a326765efeaec3752af08cdd134ad3a55" # 1.1.16
GH_URI="github/aardappel"
WX_GTK_VER="3.1" # not yet in gentoo repo

inherit git-hosting
# functions: setup-wxwidgets
inherit wxwidgets

DESCRIPTION="Example package"
HOMEPAGE="http://strlen.com/treesheets/ ${GH_HOMEPAGE}"
LICENSE="ZLIB"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( )

CDEPEND_A=(
	# required libs: aui adv core xml net
# 	"x11-libs/wxGTK:3.1"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	local sedargs=(
		-e 's|LDFLAGS *+= *$(WX_LIBS)|LIBS *+= *$(WX_LIBS)|'
		-e 's|$(CXX) $(OBJS) $(LDFLAGS) -o $@|$(CXX) $(LDFLAGS) $(OBJS) $(LIBS) -o $@|'
	)
	sed "${sedargs[@]}" -i -- src/Makefile || die
}

src_compile() {
	emake -C src all
}
