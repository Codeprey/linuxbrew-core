class Libhttpseverywhere < Formula
  desc "Bring HTTPSEverywhere to desktop apps"
  homepage "https://github.com/gnome/libhttpseverywhere"
  url "https://download.gnome.org/sources/libhttpseverywhere/0.8/libhttpseverywhere-0.8.3.tar.xz"
  sha256 "1c006f5633842a2b131c1cf644ab929556fc27968a60da55c00955bd4934b6ca"
  license "LGPL-3.0"
  revision OS.mac? ? 3 : 5

  bottle do
    sha256 "0f7bd135303104c5c99fce5d6a215b7e8ec14430fe083b7f31cf187d31318a76" => :catalina
    sha256 "8f2bffc0b7677ca274a7db722d0c206094283492453dff52276a35d3c0539887" => :mojave
    sha256 "423d5b3f578db02af3da3498d0970eee3a6d26add491949f59927723503385d3" => :high_sierra
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson-internal" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "glib"
  depends_on "json-glib"
  depends_on "libarchive"
  depends_on "libgee"
  depends_on "libsoup"

  # see https://gitlab.gnome.org/GNOME/libhttpseverywhere/issues/1
  # remove when next version is released
  patch do
    url "https://gitlab.gnome.org/GNOME/libhttpseverywhere/commit/6da08ef1ade9ea267cecf14dd5cb2c3e6e5e50cb.diff"
    sha256 "e5499c290c5b48b243f67763a2c710acc5bd52b90541eb8da3f8b24b516f7430"
  end

  def install
    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja"
      system "ninja", "install"
    end

    if OS.mac?
      dir = [Pathname.new("#{lib}64"), lib/"x86_64-linux-gnu"].find(&:directory?)
      unless dir.nil?
        mkdir_p lib
        system "/bin/mv", *Dir[dir/"*"], lib
        rmdir dir
        inreplace Dir[lib/"pkgconfig/*.pc"], %r{lib64|lib/x86_64-linux-gnu}, "lib"
      end
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <httpseverywhere.h>

      int main(int argc, char *argv[]) {
        GType type = https_everywhere_context_get_type();
        return 0;
      }
    EOS
    ENV.libxml2
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    json_glib = Formula["json-glib"]
    libarchive = Formula["libarchive"]
    libgee = Formula["libgee"]
    libsoup = Formula["libsoup"]
    pcre = Formula["pcre"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/httpseverywhere-0.8
      -I#{json_glib.opt_include}/json-glib-1.0
      -I#{libarchive.opt_include}
      -I#{libgee.opt_include}/gee-0.8
      -I#{libsoup.opt_include}/libsoup-2.4
      -I#{pcre.opt_include}
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{json_glib.opt_lib}
      -L#{libarchive.opt_lib}
      -L#{libgee.opt_lib}
      -L#{libsoup.opt_lib}
      -L#{lib}
      -larchive
      -lgee-0.8
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lhttpseverywhere-0.8
      -ljson-glib-1.0
      -lsoup-2.4
      -lxml2
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
