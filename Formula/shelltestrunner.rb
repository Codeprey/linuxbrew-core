class Shelltestrunner < Formula
  desc "Portable command-line tool for testing command-line programs"
  homepage "https://github.com/simonmichael/shelltestrunner"
  url "https://hackage.haskell.org/package/shelltestrunner-1.9/shelltestrunner-1.9.tar.gz"
  sha256 "cbc4358d447e32babe4572cda0d530c648cc4c67805f9f88002999c717feb3a8"
  license "GPL-3.0"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "f4b8567777ed9313c913b29a45874c02cc517d5cf379a67e22797993e6b264c2" => :catalina
    sha256 "4e47bf2909e2092bfcb53f03314ee83fd4011c703fddbca74451546aed6a09f0" => :mojave
    sha256 "8f5b11e3b03a9e1b10623aad6aa7783f3b51975bc516fbe93df44867e34b3371" => :high_sierra
    sha256 "d784b933882086925f422ccc0969b6f35ef217e7ba09a671d2a39395ef9278e3" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@8.8" => :build

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    (testpath/"test").write "$$$ {exe} {in}\n>>> /{out}/\n>>>= 0"
    args = "-D{exe}=echo -D{in}=message -D{out}=message -D{doNotExist}=null"
    assert_match "Passed", shell_output("#{bin}/shelltest #{args} test")
  end
end
