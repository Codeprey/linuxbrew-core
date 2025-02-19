require "language/node"

class Gitmoji < Formula
  desc "Emoji guide for your commit messages"
  homepage "https://gitmoji.carloscuesta.me"
  url "https://registry.npmjs.org/gitmoji-cli/-/gitmoji-cli-3.2.7.tgz"
  sha256 "7b22831cbad5c8842015f267d9b001525aab325180b6775ac844609a42f87340"
  license "MIT"

  bottle do
    cellar :any_skip_relocation
    sha256 "ec16f010f6639a64c7e116d7edc896a53b3a83c9fb767107d13826346ea7046d" => :catalina
    sha256 "b1419dd32fe24575174a1f2995d9a64355c0f99d30923e96507b428e2285c432" => :mojave
    sha256 "950fdc21af1b817b6126ec0a2aec7ba7b05d8a8051971602747caf13a5e35702" => :high_sierra
    sha256 "600d8bc9e9d4a0fbac255e8b96fe9aefb805ecbb842cb3bf828605b6ce1253c4" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match ":bug:", shell_output("#{bin}/gitmoji --search bug")
  end
end
