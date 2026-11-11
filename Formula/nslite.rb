class Nslite < Formula
  desc "Small, extensible text editor based on rxi/lite"
  homepage "https://github.com/tacf/nslite"
  url "https://github.com/tacf/nslite/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "de1fe3f502154ac7e9577cf9ffc647dc456e080a46f95f3f0ada384f3af37d03"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "libgit2"
  depends_on "lua"
  depends_on "pcre2"
  depends_on "sdl3"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DNSLITE_USE_SYSTEM_LIBS=ON",
                    "-DCMAKE_BUILD_TYPE=Release",
                    *std_cmake_args
    system "cmake", "--build", "build", "--parallel"

    libexec.install "build/nsl", "data"
    bin.write_exec_script libexec/"nsl"
  end

  test do
    assert_predicate bin/"nsl", :executable?
    assert_path_exists libexec/"data/core/init.lua"
  end
end
