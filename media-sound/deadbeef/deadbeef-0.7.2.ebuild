# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_URI="github/Alexey-Yakovenko"

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
# EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg
inherit autotools

DESCRIPTION="Music player for *nix-like systems"
HOMEPAGE="http://deadbeef.sourceforge.net/ ${HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="doc"

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	# relations specified in Makefile.am
	"shellexecui? ( shellexec || ( gtk2 gtk3 ) )"
)
RESTRICT+=""

src_prepare() {
	eapply_user

	# automake: `error: required file `./config.rpath' not found`
	touch config.rpath || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable threads threads posix)

		$(use_enable nls)
		$(use_enable threads)	# build without multithread safety
		$(use_enable static staticlink)	# link everything statically (default: disabled)

		## Output plugins (DB_PLUGIN_OUTPUT)
		$(use_enable alsa)		# disable ALSA output plugin (default: enabled)
		$(use_enable coreaudio)	# disable CoreAudio output plugin (default: enabled)
		$(use_enable nullout)	# disable NULL output plugin (default: enabled)
		$(use_enable oss)		# disable Open Sound System output plugin (default: enabled)
		$(use_enable pulse)		# disable PulseAudio output plugin (default: enabled)

		## Decoder plugins (DB_PLUGIN_DECODER)
		aac
		adplug
		alac
		ao
		cdda
		dca
		dumb
		ffap
		ffmpeg
		flac
		gme
		mp3
		musepack
		sc68
		shn
		sid
		sndfile
		tta
		vorbis
		vtx
		wavpack
		wildmidi
		wma


		## GUI
		$(use_enable gtk3)		# disable GTK3 version of gtkui plugin (default: enabled)
		$(use_enable gtk2)		# disable GTK2 version of gtkui plugin (default: enabled)

		$(use_enable shellexec)	# disable shell commands plugin (default: enabled)
		$(use_enable shellexecui)	# build shellexec GTK UI plugin (default: auto)

		$(use_enable aac)		# disable AAC decoder based on FAAD2 (default: enabled)
		$(use_enable adplug)	# disable adplug plugin (default: enabled)
		$(use_enable alac)		# build ALAC plugin (default: auto)
		$(use_enable dca)		# disable dca (DTS audio) plugin (default: enabled)
		$(use_enable flac)		# disable FLAC player plugin (default: enabled)
		$(use_enable mp3)		# disable mp3 plugin (default: enabled)
		$(use_enable musepack)	# disable musepack plugin (default: enabled)
		$(use_enable vorbis)	# disable Ogg Vorbis player plugin (default: enabled)
		$(use_enable wavpack)	# disable wavpack plugin (default: enabled)
		$(use_enable wma)		# build WMA plugin (default: auto)


		$(use_enable abstract-socket)	# use abstract UNIX socket for IPC (default: disabled)


		$(use_enable artwork)	# disable album art loader plugin (default: enabled)
		$(use_enable artwork-imlib2)	# use imlib2 in artwork plugin (default: auto)
		$(use_enable artwork-network)	# disable album art network loading support (default: enabled)

		$(use_enable cdda)		# disable CD-Audio plugin (default: enabled)
		$(use_enable cdda-paranoia)	# disable CD-Audio error correction during ripping (default: enabled)

		$(use_enable converter)	# build converter plugin (default: auto)

		$(use_enable dumb)		# build DUMB plugin (default: auto)
		$(use_enable ffap)		# disable Monkey's Audio plugin (default: enabled)
		$(use_enable ffmpeg)	# disable FFMPEG plugin for WMA, AMR, etc (default: enabled)

		$(use_enable gme)		# disable Game Music Emu plugin for NSF, AY, etc (default: enabled)
		$(use_enable hotkeys)	# disable global hotkeys plugin (default: enabled)
		$(use_enable lfm)		# disable last.fm/libre.fm scrobbler plugin (default: enabled)
		$(use_enable libmad)	# disable libmad support in mp3 plugin (default: auto)
		$(use_enable libmpg123)	# disable libmpg123 support in mp3 plugin (default: auto)
		$(use_enable m3u)		# build m3u plugin (default: auto)
		$(use_enable mms)		# disable MMS streaming vfs plugin (default: enabled)
		$(use_enable mono2stereo)	# build mono2stereo DSP plugin (default: auto)
		$(use_enable shn)		# build SHN plugin (default: auto)

		$(use_enable notify)	# disable notification-daemon support plugin (default: enabled)
		$(use_enable pltbrowser)	# build playlist browser gui plugin (default: auto)
		$(use_enable portable)		# make portable build (default: disabled, opts: yes,no,full)
		$(use_enable psf)		# build AOSDK-based PSF(,QSF,SSF,DSF) plugin (default: auto)
		$(use_enable sc68)		# build sc68 Atari ST and Amiga music player (default: auto)

		$(use_enable sid)		# disable commodore64 SID music player plugin (default: enabled)
		$(use_enable sndfile)	# disable libsndfile plugin for PCM wave files (default: enabled)
		$(use_enable src)		# build libsamplerate (SRC) plugin (default: auto)
		$(use_enable supereq)	# disable SuperEQ DSP plugin (default: enabled)
		$(use_enable tta)		# disable tta plugin (default: enabled)
		$(use_enable vfs-curl)	# disable HTTP streaming vfs plugin (default: enabled)
		$(use_enable vfs-zip)	# build vfs_zip plugin (default: auto)
		$(use_enable vtx)		# disable libayemy VTX ZX-Spectrum music player plugin (default: enabled)
		$(use_enable wildmidi)	# disable wildmidi plugin (default: enabled)
	)
	econf "${myeconfargs[@]}"
}
