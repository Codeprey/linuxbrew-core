class Scrcpy < Formula
  desc "Display and control your Android device"
  homepage "https://github.com/Genymobile/scrcpy"
  url "https://github.com/Genymobile/scrcpy/archive/v1.15.1.tar.gz"
  sha256 "1d66dccf14f77e085853453d91a06fad40d1ab5cf2997f00079502edeac9d575"
  license "Apache-2.0"

  bottle do
    sha256 "d090ecbaca721c11336af0b94426cc9a4cbc8a2e1ea90f4e05a22e640475e84e" => :catalina
    sha256 "f8f4997d5b4727bcd8af5b8deb9a4c2c1234f89b68239144ecf7f97493f10006" => :mojave
    sha256 "3602289570f6017c1fb32a4dfcb7bc5d4f014a94862821e2e5f7c4ba884b8c82" => :high_sierra
    sha256 "c0b7ef83d9fdbdfe3bd414c7ea4a0f983c4cd0d76bca9b785ad34bb288fb2bde" => :x86_64_linux
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "ffmpeg"
  depends_on "sdl2"

  resource "prebuilt-server" do
    url "https://github.com/Genymobile/scrcpy/releases/download/v1.15.1/scrcpy-server-v1.15.1"
    sha256 "fe06bd6a30da8c89860bf5e16eecce2b5054d4644c84289670ce00ca5d1637c3"
  end

  def install
    r = resource("prebuilt-server")
    r.fetch
    cp r.cached_download, buildpath/"prebuilt-server.jar"

    mkdir "build" do
      system "meson", *std_meson_args,
                      "-Dprebuilt_server=#{buildpath}/prebuilt-server.jar",
                      ".."

      system "ninja", "install"
    end
  end

  def caveats
    <<~EOS
      At runtime, adb must be accessible from your PATH.

      You can install adb from Homebrew Cask:
        brew cask install android-platform-tools
    EOS
  end

  test do
    fakeadb = (testpath/"fakeadb.sh")

    # When running, scrcpy calls adb three times:
    #  - adb push ... (to push scrcpy-server.jar)
    #  - adb reverse ... tcp:PORT ...
    #  - adb shell ...
    # However, exiting on $1 = shell didn't work properly, so instead
    # fakeadb exits on $1 = reverse

    fakeadb.write <<~EOS
      #!/bin/sh
      echo $@ >> #{testpath/"fakeadb.log"}

      if [ "$1" = "reverse" ]; then
        exit 42
      fi
    EOS

    fakeadb.chmod 0755
    ENV["ADB"] = fakeadb

    # It's expected to fail after adb reverse step because fakeadb exits
    # with code 42
    out = shell_output("#{bin}/scrcpy -p 1337 2>&1", 1)
    assert_match(/ 42/, out)

    log_content = File.read(testpath/"fakeadb.log")

    # Check that it used port we've specified
    assert_match(/tcp:1337/, log_content)

    # Check that it tried to push something from its prefix
    assert_match(/push #{prefix}/, log_content)
  end
end
