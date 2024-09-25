class Micromamba < Formula
  desc "Fast Cross-Platform Package Manager"
  homepage "https://github.com/mamba-org/mamba"
  url "https://github.com/mamba-org/mamba/archive/refs/tags/micromamba-2.0.0.tar.gz"
  sha256 "ea6f29327a7877abb79a1e8a16af2f4a4db4ae84c196bc159205b411db8c7dac"
  license "BSD-3-Clause"
  head "https://github.com/mamba-org/mamba.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest do |json, regex|
      json["name"]&.scan(regex)&.map { |match| match[0] }
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "3bf5ba3e4fa863d6072c78c4229e533efaeda27137e78191c3c5d852470f46b2"
    sha256 cellar: :any,                 arm64_sonoma:  "01eed43203215173119a8280a7ed2f97417f09c236ac279d95ad94fe57af8fd1"
    sha256 cellar: :any,                 arm64_ventura: "273313c71f6212077cff10f6ee2ba00fe2d50056d356088935d38204bcf3ab71"
    sha256 cellar: :any,                 sonoma:        "e0d5863f983f062ea6e108d8258d755ad0fd28d9d5fd764d559b8ec46199aa57"
    sha256 cellar: :any,                 ventura:       "45a20d1caddf34134b10cd45b6af40a5db46787b44a5a358ba0cf306871a2076"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e3af94e30de7979583d176e00f31195eaebeb24fef85f3919923c7de5ead80fc"
  end

  depends_on "cli11" => :build
  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "spdlog" => :build
  depends_on "tl-expected" => :build

  depends_on "fmt"
  depends_on "libarchive"
  depends_on "libsolv"
  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "reproc"
  depends_on "simdjson"
  depends_on "xz"
  depends_on "yaml-cpp"
  depends_on "zstd"

  uses_from_macos "llvm" => :build, since: :sonoma
  uses_from_macos "python" => :build
  uses_from_macos "bzip2"
  uses_from_macos "curl", since: :ventura # uses curl_url_strerror, available since curl 7.80.0
  uses_from_macos "krb5"
  uses_from_macos "zlib"

  # /usr/include/c++/11/bits/stl_pair.h:218:11: error: ‘std::pair<_T1, _T2>::second’ has incomplete type
  #   218 |       _T2 second;                ///< The second member
  #       |           ^~~~~~
  # Might work with a newer GCC, but we don't want linkage with a newer `libstdc++`.
  fails_with :gcc

  def install
    ENV.llvm_clang if OS.mac? && MacOS.version < :sonoma
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    args = %W[
      -DBUILD_LIBMAMBA=ON
      -DBUILD_SHARED=ON
      -DBUILD_MAMBA=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    # Upstream only want to call the statically linked executable `micromaba`,
    # but let's not break existing users of this formula.
    bin.install_symlink "mamba" => "micromamba"
  end

  def caveats
    <<~EOS
      Please run the following to setup your shell:
        #{opt_bin}/mamba shell init -s <your-shell> -p ~/mamba
      and restart your terminal.
    EOS
  end

  test do
    ENV["MAMBA_ROOT_PREFIX"] = testpath.to_s
    assert_match version.to_s, shell_output("#{bin}/mamba --version").strip

    python_version = "3.9.13"
    system bin/"mamba", "create", "-n", "test", "python=#{python_version}", "-y", "-c", "conda-forge"
    assert_match "Python #{python_version}", shell_output("#{bin}/mamba run -n test python --version").strip
  end
end
