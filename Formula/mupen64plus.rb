class Mupen64plus < Formula
  desc "Cross-platform plugin-based N64 emulator"
  homepage "http://www.mupen64plus.org/"
  url "https://github.com/mupen64plus/mupen64plus-core/releases/download/2.5/mupen64plus-bundle-src-2.5.tar.gz"
  sha256 "9c75b9d826f2d24666175f723a97369b3a6ee159b307f7cc876bbb4facdbba66"

  bottle do
    cellar :any
    revision 1
    sha256 "4cd138b1288a6bed93507b5cabac1ece7da4e4f14bc16710258ad3d7a4add7c6" => :el_capitan
    sha256 "67d1d0c84f96191f88b3cf7bde4da1c0c801dec0534c962b2c550660e00c707d" => :yosemite
    sha256 "f99cc7177a1e5e9cffaa3bd03826237f0fdfc02acbeddf2f1c165251b181208a" => :mavericks
  end

  option "without-osd", "Disables the On Screen Display"
  option "with-new-dynarec", "Replace dynamic recompiler with Ari64's experimental dynarec"
  option "with-src", "Build with libsamplerate"
  option "with-speex", "Build with libspeexdsp"

  deprecated_option "disable-osd" => "without-osd"
  deprecated_option "enable-new-dynarec" => "with-new-dynarec"

  depends_on "pkg-config" => :build
  depends_on "libpng"
  depends_on "sdl"
  depends_on "boost"
  depends_on "freetype" if build.with? "osd"
  depends_on "libsamplerate" if build.with? "src"
  depends_on "speex" => :optional

  resource "rom" do
    url "https://github.com/mupen64plus/mupen64plus-rom/raw/76ef14c876ed036284154444c7bdc29d19381acc/m64p_test_rom.v64"
    sha256 "b5fe9d650a67091c97838386f5102ad94c79232240f9c5bcc72334097d76224c"
  end

  def install
    # Prevent different C++ standard library warning
    inreplace Dir["source/mupen64plus-**/projects/unix/Makefile"], /(-mmacosx-version-min)=\d+\.\d+/, "\\1=#{MacOS.version}"

    common_args = ["install", "PREFIX=#{prefix}", "INSTALL_STRIP_FLAG=-S"]

    cd "source/mupen64plus-core/projects/unix" do
      args = common_args.dup
      args << "OSD=0" if build.without? "osd"
      args << "NEW_DYNAREC=1" if build.with? "new-dynarec"
      system "make", *args
    end

    cd "source/mupen64plus-audio-sdl/projects/unix" do
      args = common_args.dup
      args << "NO_SRC=1" if build.without? "src"
      args << "NO_SPEEX=1" if build.without? "speex"
      system "make", *args
    end

    cd "source/mupen64plus-input-sdl/projects/unix" do
      system "make", *common_args
    end

    cd "source/mupen64plus-rsp-hle/projects/unix" do
      system "make", *common_args
    end

    cd "source/mupen64plus-video-glide64mk2/projects/unix" do
      system "make", *common_args
    end

    cd "source/mupen64plus-video-rice/projects/unix" do
      system "make", *common_args
    end

    cd "source/mupen64plus-ui-console/projects/unix" do
      system "make", *common_args
    end
  end

  test do
    resource("rom").stage do
      system bin/"mupen64plus", "--testshots", "1",
             "m64p_test_rom.v64"
    end
  end
end
