class GoogleSparsehash < Formula
  desc "Extremely memory-efficient hash_map implementation"
  homepage "https://github.com/sparsehash/sparsehash"
  url "https://github.com/sparsehash/sparsehash/archive/sparsehash-2.0.3.tar.gz"
  sha256 "05e986a5c7327796dad742182b2d10805a8d4f511ad090da0490f146c1ff7a8c"
  license "BSD-3-Clause"
  revision 1 unless OS.mac?

  bottle do
    cellar :any_skip_relocation
    sha256 "baf009352f7372901cb23c3e0db607313809d038d5975fd43195515c448f544c" => :catalina
    sha256 "7042ae9f9b7df36cf6ebfe76704997aa21892c5119adb32c56874954953e9a84" => :mojave
    sha256 "89dbaeb37bfaa056e8c1fd822e585f9ff04001778f646b1ec3f13c85a2ccaedc" => :high_sierra
    sha256 "a0bedeb9128c863130ee3330f65a6c4fe2fb8ca8aeb0aca7abd0ffc2c76691a1" => :sierra
    sha256 "8655e0c3b4f4c69e46d8823eef0d8ae2b1397cd2aa01bda3340eb3a84d647b89" => :el_capitan
    sha256 "b8e55b96aa3016ed2ab5a8d53a4bb39b44773885355ec75e80c9d9ef57c3e8b1" => :yosemite
    sha256 "570c4d250a4fe18d99f11167653a501a1d8a82ff74d2413336a85bc7fa8cbb81" => :mavericks
    sha256 "7b59ab353073ab88845a20e4f326bc92a560fdc3c0b26c9de058c30ed33712a0" => :x86_64_linux
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check"
    system "make", "install"
  end
end
