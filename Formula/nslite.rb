class Nslite < Formula
  desc "Small, extensible text editor based on rxi/lite"
  homepage "https://github.com/tacf/nslite"
  url "https://github.com/tacf/nslite/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "aed080431c0618db8d2452d3e4d4dd3ae6998167656ebdb064229f8b299575d9"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "lua"
  depends_on "pcre2"
  depends_on "sdl3"
  depends_on "sdl3_image"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DNSLITE_USE_SYSTEM_LIBS=ON",
                    "-DCMAKE_BUILD_TYPE=Release",
                    *std_cmake_args
    system "cmake", "--build", "build", "--parallel"

    libexec.install "build/nsl", "data"
    bin.write_exec_script libexec/"nsl"
  end

  def post_install
    return unless OS.mac?

    system "/usr/bin/codesign", "--force", "--sign", "-", libexec/"nsl"
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"nsl"
  end

  test do
    assert_predicate libexec/"nsl", :executable?
    assert_path_exists libexec/"data/core/init.lua"
    system "/usr/bin/codesign", "--verify", "--strict", libexec/"nsl" if OS.mac?
  end
end
