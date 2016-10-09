# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )

inherit rindeal eutils toolchain-funcs libtool flag-o-matic bash-completion-r1 python-single-r1 systemd

DESCRIPTION="Various useful system utilities for Linux"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/${PN}/"
LICENSE="GPL-2 LGPL-2.1 BSD-4 MIT public-domain"

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"
SLOT="0"
SRC_URI="mirror://kernel/linux/utils/${PN}/v${PV:0:4}/${MY_P}.tar.xz"

KEYWORDS="~amd64 ~arm"
IUSE="build caps +cramfs fdformat kill ncurses nls pam python +readline selinux slang static-libs +suid systemd test tty-helpers udev unicode"

CDEPEND_A=(
	"caps?		( sys-libs/libcap-ng )"
	"cramfs?	( sys-libs/zlib )"
	"ncurses?	( >=sys-libs/ncurses-5.2-r2:0=[unicode?] )"
	"pam?		( sys-libs/pam )"
	"python?	( ${PYTHON_DEPS} )"
	"readline?	( sys-libs/readline:0= )"
	"selinux?	( >=sys-libs/libselinux-2.2.2-r4[${MULTILIB_USEDEP}] )"
	"slang?		( sys-libs/slang )"
	"!build?	( systemd? ( sys-apps/systemd ) )"
	"udev?	( virtual/libudev:= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"nls?	( sys-devel/gettext )"
	"test?	( sys-devel/bc )"
	"virtual/os-headers"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kill? ("
		"!sys-apps/coreutils[kill]"
		"!sys-process/procps[kill]"
	")"
	"!sys-process/schedutils"
	"!sys-apps/setarch"
	"!<sys-apps/sysvinit-2.88-r7"
	"!sys-block/eject"
	"!<sys-libs/e2fsprogs-libs-1.41.8"
	"!<sys-fs/e2fsprogs-1.41.8"
	"!<app-shells/bash-completion-2.3-r2"
)

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	eapply_user

	./po/update-potfiles || die
	eautoreconf
	elibtoolize
}

my_lfs_fallocate_test() {
	# Make sure we can use fallocate with LFS gentoo#300307
	cat <<-EOF > "${T}"/fallocate.c || die
		#define _GNU_SOURCE
		#include <fcntl.h>
		main() { return fallocate(0, 0, 0, 0); }
	EOF
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} "${T}"/fallocate.c -o /dev/null &>/dev/null \
		|| export ac_cv_func_fallocate=no
	erm "${T}"/fallocate.c
}

src_configure() {
	my_lfs_fallocate_test

	export ac_cv_header_security_pam_misc_h="$(usex pam)" # gentoo#485486
	export ac_cv_header_security_pam_appl_h="$(usex pam)" # gentoo#545042

	local myeconfargs=(
		--enable-fs-paths-extra="${EPREFIX}/usr/sbin:${EPREFIX}/bin:${EPREFIX}/usr/bin"
		--docdir='${datarootdir}'/doc/${PF}

		## BASH completion
		--with-bashcompletiondir="$(get_bashcompdir)"
		--enable-bash-completion

		$(tc-has-tls || echo --disable-tls)	# disable use of thread local support

		$(use_enable doc gtk-doc)	# use gtk-doc to build documentation
		$(use_enable assert)	# turn off assertions
		$(use_enable nls)

		$(use_enable libuuid)	# do not build libuuid and uuid utilities
		$(use_enable libuuid-force-uuidd) # support uuidd even though the daemon is not built
		$(use_enable libblkid)	# do not build libblkid and many related utilities
		$(use_enable libsmartcols)	# do not build libsmartcols
		$(use_enable libfdisk)	# do not build libfdisk
		$(use_enable mount)		# do not build mount(8) and umount(8)
		$(use_enable losetup)	# do not build losetup
		$(use_enable zramctl)	# do not build zramctl
		$(use_enable fsck)		# do not build fsck
		$(use_enable partx)		# do not build addpart, delpart, partx
		$(use_enable uuidd)		# do not build the uuid daemon
		$(use_enable mountpoint)	# do not build mountpoint
		$(use_enable fallocate)	# do not build fallocate
		$(use_enable unshare)	# do not build unshare
		$(use_enable nsenter)	# do not build nsenter
		$(use_enable setpriv)	# do not build setpriv
		$(use_enable eject)		# do not build eject
		$(use_enable agetty)	# do not build agetty
		$(use_enable cramfs)	# do not build fsck.cramfs, mkfs.cramfs
		$(use_enable bfs)		# do not build mkfs.bfs
		$(use_enable minix)		# do not build fsck.minix, mkfs.minix
		$(use_enable fdformat)	# do not build fdformat
		$(use_enable hwclock)	# do not build hwclock
		$(use_enable lslogins)	# do not build lslogins
		$(use_enable wdctl)		# do not build wdctl
		$(use_enable cal)		# do not build cal
		$(use_enable logger)	# do not build logger
		$(use_enable switch_root)	# do not build switch_root
		$(use_enable pivot_root)	# do not build pivot_root
		$(use_enable ipcrm)		# do not build ipcrm
		$(use_enable ipcs)		# do not build ipcs
		$(use_enable tunelp)	# build tunelp
		$(use_enable kill)		# do not build kill
		$(use_enable last)		# do not build last
		$(use_enable utmpdump)	# do not build utmpdump
		$(use_enable line)		# build line
		$(use_enable mesg)		# do not build mesg
		$(use_enable raw)		# do not build raw
		$(use_enable rename)	# do not build rename
		$(use_enable reset)		# build reset
		$(use_enable vipw)		# build vipw
		$(use_enable newgrp)	# build newgrp

		$(use_enable chfn-chsh-password)	# do not require the user to enter the password in chfn and chsh
		$(use_enable chfn-chsh)	# build chfn and chsh
		$(use_enable chsh-only-listed)	# chsh: allow shells not in /etc/shells
		$(use_enable login)		# do not build login
		$(use_enable login-chown-vcs)	# let login chown /dev/vcsN
		$(use_enable login-stat-mail)	# let login stat() the mailbox
		$(use_enable nologin)	# do not build nologin
		$(use_enable sulogin)	# do not build sulogin
		$(use_enable su)		# do not build su
		$(use_enable runuser)	# do not build runuser
		$(use_enable ul)		# do not build ul
		$(use_enable more)		# do not build more
		$(use_enable pg)		# do not build pg
		$(use_enable setterm)	# do not build setterm
		$(use_enable schedutils)	# do not build chrt, ionice, taskset
		$(use_enable wall)		# do not build wall
		$(use_enable write)		# build write
		$(use_enable pylibmount)	# pylibmount
		$(use_enable pg-bell)	# let pg not ring the bell on invalid keys

# 		$(use_enable fs-paths-default)	# default search path for fs helpers [/sbin:/sbin/fs.d:/sbin/fs]
# 		$(use_enable fs-paths-extra)	# additional search paths for fs helpers

		$(use_enable use-tty-group)	# do not install wall and write setgid tty
		$(use_enable sulogin-emergency-mount)	# use emergency mount of /dev and /proc for sulogin
		$(use_enable usrdir-path)	# use only /usr paths in PATH env. variable (recommended on systems with /bin -> /usr/bin symlinks)
		$(use_enable suid makeinstall-chown)	# do not do chown-like operations during "make install"
		$(use_enable suid makeinstall-setuid)	# do not do setuid chmod operations during "make install"
		$(use_enable colors-default)	# do not colorize output from utils by default

		$(use_with util)	# compile without libutil
		$(use_with selinux)	# compile with SELinux support
		$(use_with audit)	# compile with audit support
		$(use_with udev)	# compile without udev support

		# build with non-wide ncurses, default is wide version (--without-ncurses disables all ncurses(w) support)
		--with-ncurses="$(usex ncurses $(usex unicode auto yes) no)"

		$(use_with slang)	# compile cfdisk with slang
# 		$(use_with tinfo)	# compile without libtinfo
		$(use_with readline)	# compile with GNU Readline support
		$(use_with utempter)	# compile script(1) with libutempter
		$(use_with cap-ng)	# compile without libcap-ng
		$(use_with libz)	# compile without libz
		$(use_with user)	# compile without libuser (remote chsh)
		$(use_with btrfs)	# build with support for btrfs
		$(use_with systemd)	# build with support for systemd
# 		--with-systemdsystemunitdir
		$(use_with smack)	# build with SMACK support
		$(use_with python)	# do not build python bindings, use --with-python={2,3} to force version

		$(use_enable caps setpriv)
		$(use_enable cramfs)
		$(use_enable fdformat)
		$(use_enable kill)

		$(use_with readline)

		$(use_enable tty-helpers mesg)
		$(use_enable tty-helpers wall)
		$(use_enable tty-helpers write)

		$(use_with selinux)
		$(use_with slang)
		$(use_enable static-libs static)

		$(use_with systemd)
		--with-systemdsystemunitdir="$(usex systemd "$(systemd_get_unitdir)" "no")"

		$(use_with udev)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	dodoc AUTHORS NEWS README* Documentation/{TODO,*.txt,releases/*}

	# e2fsprogs-libs didnt install .la files, and .pc work fine
	prune_libtool_files

	# need the libs in /
	gen_usr_ldscript -a blkid mount smartcols uuid

	use python && python_optimize
}

pkg_postinst() {
	if ! use tty-helpers ; then
		elog "The mesg/wall/write tools have been disabled due to USE=-tty-helpers."
	fi

	if [[ -z ${REPLACING_VERSIONS} ]] ; then
		elog "The agetty util now clears the terminal by default. You"
		elog "might want to add --noclear to your /etc/inittab lines."
	fi
}
