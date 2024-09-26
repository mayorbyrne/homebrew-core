class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-38.96.0.tgz"
  sha256 "a932ed36a484cf242bcdc588a81fd296019ed01d851ee777c7e281d9574a0737"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3d06727f5c939b6cdc5e3d94c69d196de7fdc3c6938c7d4b721fa32de78294ca"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "7b3d8b32a07d20faaa43bfe9ee193a257f956f392a6c134e29200e18c62a27dc"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "0f08ba191722e95be70c7cf8eca510a7707122eccb5cefee4bc930469744e536"
    sha256 cellar: :any_skip_relocation, sonoma:        "b7d256690356237f6eeaef73a8649738bb411b35d0f887c772abc6d5667c3a5c"
    sha256 cellar: :any_skip_relocation, ventura:       "23743d810df2c44fcf007f691c2451159854ff3700a9dff818e6a1c0db2c1f96"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6eefbccd755fa79f87fc27981a960072273baddc2534068833494f5ef3acf194"
  end

  depends_on "node@20"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
