class Mypy < Formula
  include Language::Python::Virtualenv

  desc "Experimental optional static type checker for Python"
  homepage "https://www.mypy-lang.org/"
  url "https://files.pythonhosted.org/packages/c7/b9/81e4c6dbb1ec1e72503de3ff2c5fe4b7f224e04613b670f8b9004cd8a4dd/mypy-1.10.1.tar.gz"
  sha256 "1f8f492d7db9e3593ef42d4f115f04e556130f2819ad33ab84551403e97dd4c0"
  license "MIT"
  head "https://github.com/python/mypy.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "dcbb33b8591fd579d3e0336ec22be82ad50aea66b3f66a524cc4b723ef4b16b9"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "3421f3f4d35d49b229fd88046336c5ce06187b8d2810bb2a6e5b055bd1ba906f"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "12dabf47a8b5ffc37ec101d133a2b6e14f611b5f8b8ff516172deec8f403d15b"
    sha256 cellar: :any_skip_relocation, sonoma:         "0c0d8c7c935d310f3f1c02673f537c86f1582330d4f44d2ec2d9db5715a55d4e"
    sha256 cellar: :any_skip_relocation, ventura:        "45ab4f8e893d5df6d32776aae49b984bc363bf60af0d65fb8178730d662b5b19"
    sha256 cellar: :any_skip_relocation, monterey:       "bd9cb33745275ba357724fbd328f5a249e905a9d0667ece81ac749ea5c22af4b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d39a13321c4cc7df27d46627603f044de87db9318c51599537f7d28166c97b1d"
  end

  depends_on "python@3.12"

  resource "mypy-extensions" do
    url "https://files.pythonhosted.org/packages/98/a4/1ab47638b92648243faf97a5aeb6ea83059cc3624972ab6b8d2316078d3f/mypy_extensions-1.0.0.tar.gz"
    sha256 "75dbf8955dc00442a438fc4d0666508a9a97b6bd41aa2f0ffe9d2f2725af0782"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/df/db/f35a00659bc03fec321ba8bce9420de607a1d37f8342eee1863174c69557/typing_extensions-4.12.2.tar.gz"
    sha256 "1a7ead55c7e559dd4dee8856e3a88b41225abfe1ce8df57b7c13915fe121ffb8"
  end

  def install
    ENV["MYPY_USE_MYPYC"] = "1"
    ENV["MYPYC_OPT_LEVEL"] = "3"
    virtualenv_install_with_resources
  end

  test do
    (testpath/"broken.py").write <<~EOS
      def p() -> None:
        print('hello')
      a = p()
    EOS
    output = pipe_output("#{bin}/mypy broken.py 2>&1")
    assert_match '"p" does not return a value', output

    output = pipe_output("#{bin}/mypy --version 2>&1")
    assert_match "(compiled: yes)", output
  end
end
