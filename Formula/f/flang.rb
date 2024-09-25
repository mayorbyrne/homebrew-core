class Flang < Formula
  desc "LLVM Fortran Frontend"
  homepage "https://flang.llvm.org/"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.0/llvm-project-19.1.0.src.tar.xz"
  sha256 "5042522b49945bc560ff9206f25fb87980a9b89b914193ca00d961511ff0673c"
  # The LLVM Project is under the Apache License v2.0 with LLVM Exceptions
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/llvm/llvm-project.git", branch: "main"

  livecheck do
    url :stable
    regex(/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "zstd"
  uses_from_macos "zlib"

  def llvm
    Formula["llvm"]
  end

  def install
    # NOTE: Setting `BUILD_SHARED_LIBRARIES=ON` causes the just-built flang to throw ICE.
    args = %W[
      -DCLANG_DIR=#{llvm.opt_lib}/cmake/clang
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DFLANG_INCLUDE_TESTS=OFF
      -DFLANG_REPOSITORY_STRING=#{tap&.issues_url}
      -DFLANG_STANDALONE_BUILD=ON
      -DFLANG_VENDOR=#{tap&.user}
      -DLLVM_DIR=#{llvm.opt_lib}/cmake/llvm
      -DLLVM_ENABLE_EH=OFF
      -DMLIR_DIR=#{llvm.opt_lib}/cmake/mlir
    ]
    args << "-DFLANG_VENDOR_UTI=sh.brew.flang" if tap&.official?

    system "cmake", "-S", "flang", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.f90").write <<~FORTRAN
      PROGRAM test
        WRITE(*,'(A)') 'Hello World!'
      ENDPROGRAM
    FORTRAN

    cxx_stdlib = OS.mac? ? "-lc++" : "-lstdc++"
    system bin/"flang-new", "-v", "test.f90", cxx_stdlib, "-o", "test"
    assert_equal "Hello World!", shell_output("./test").chomp
  end
end
