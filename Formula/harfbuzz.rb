class Harfbuzz < Formula
  desc "OpenType text shaping engine"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/harfbuzz/harfbuzz/archive/2.7.0.tar.gz"
  sha256 "4dba05de1fd44705f54c40d801e0e3d4833555d004cb611cc18675173feae75b"
  license "MIT"
  head "https://github.com/harfbuzz/harfbuzz.git"

  bottle do
    cellar :any
    sha256 "298feb4c557de8daca542b5cf41c12256c594c09d5de0d68624bd6b1f7f3c8f1" => :catalina
    sha256 "f8b9aed2377e3861e670c6da69c62f974f1f1550b0fb873a213f429aef10806b" => :mojave
    sha256 "ae608cdcfccd5be5d27f105daecdbce3fdb9c4d93f046a5783a96f2c74ba011c" => :high_sierra
    sha256 "0fceff4d6205900e499cde14c21836b0a4cc46e18a306b3f2a114dac2ab0b60d" => :x86_64_linux
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cairo"
  depends_on "freetype"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "graphite2"
  depends_on "icu4c"

  resource "ttf" do
    url "https://github.com/harfbuzz/harfbuzz/raw/fc0daafab0336b847ac14682e581a8838f36a0bf/test/shaping/fonts/sha1sum/270b89df543a7e48e206a2d830c0e10e5265c630.ttf"
    sha256 "9535d35dab9e002963eef56757c46881f6b3d3b27db24eefcc80929781856c77"
  end

  # Fix linking issues on High Sierra
  # https://github.com/harfbuzz/harfbuzz/pull/2605
  # Remove in next release
  patch do
    url "https://github.com/harfbuzz/harfbuzz/commit/7c61caa7384e9c3afa0d9237bf6cd303eb5ef3a1.patch?full_index=1"
    sha256 "4d60b681918c2b911da9a84e37386ed1fa48794d5c943ff9a7bd50eb3a255969"
  end

  # Silence a warning that prevents building on Linux
  # https://github.com/harfbuzz/harfbuzz/issues/2555
  patch :DATA

  def install
    args = %w[
      --default-library=both
      -Dcairo=enabled
      -Dcoretext=enabled
      -Dfreetype=enabled
      -Dglib=enabled
      -Dgobject=enabled
      -Dgraphite=enabled
      -Dicu=enabled
      -Dintrospection=enabled
    ]

    mkdir "build" do
      system "meson", *std_meson_args, *args, ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    resource("ttf").stage do
      shape = `echo 'സ്റ്റ്' | #{bin}/hb-shape 270b89df543a7e48e206a2d830c0e10e5265c630.ttf`.chomp
      assert_equal "[glyph201=0+1183|U0D4D=0+0]", shape
    end
  end
end

__END__
diff --git a/src/hb-gobject-enums.cc.tmpl b/src/hb-gobject-enums.cc.tmpl
index 2ffd1c9d..26954ed2 100644
--- a/src/hb-gobject-enums.cc.tmpl
+++ b/src/hb-gobject-enums.cc.tmpl
@@ -30,6 +30,7 @@
 #ifdef HAVE_GOBJECT

 /* g++ didn't like older gtype.h gcc-only code path. */
+#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
 #include <glib.h>
 #if !GLIB_CHECK_VERSION(2,29,16)
 #undef __GNUC__
diff --git a/src/hb-gobject-structs.cc b/src/hb-gobject-structs.cc
index 7c46e264..a64913a9 100644
--- a/src/hb-gobject-structs.cc
+++ b/src/hb-gobject-structs.cc
@@ -50,6 +50,7 @@


 /* g++ didn't like older gtype.h gcc-only code path. */
+#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
 #include <glib.h>
 #if !GLIB_CHECK_VERSION(2,29,16)
 #undef __GNUC__
