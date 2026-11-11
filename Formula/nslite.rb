class Nslite < Formula
  desc "Small, extensible text editor based on rxi/lite"
  homepage "https://github.com/tacf/nslite"
  url "https://github.com/tacf/nslite/archive/refs/tags/v2.1.1.tar.gz"
  sha256 "841ec57225778eed41e05fc1cf4487061b098da71eefdd977b001d4ea341ad45"
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

    system "/usr/bin/codesign", "--force", "--sign", "-", "build/nsl" if OS.mac?

    libexec.install "build/nsl", "data"
    bin.write_exec_script libexec/"nsl"
  end

  test do
    assert_predicate libexec/"nsl", :executable?
    assert_path_exists libexec/"data/core/init.lua"
  end
end
