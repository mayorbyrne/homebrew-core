class Teleport < Formula
  desc "Modern SSH server for teams managing distributed infrastructure"
  homepage "https://goteleport.com/"
  url "https://github.com/gravitational/teleport/archive/refs/tags/v16.4.1.tar.gz"
  sha256 "6bb9a2c62b42e159b1ade7238babc0f431143aeb5e45f8280ac441c5b320c6dd"
  license all_of: ["AGPL-3.0-or-later", "Apache-2.0"]
  head "https://github.com/gravitational/teleport.git", branch: "master"

  # As of writing, two major versions of `teleport` are being maintained
  # side by side and the "latest" release can point to an older major version,
  # so we can't use the `GithubLatest` strategy. We use the `GithubReleases`
  # strategy instead of `Git` because there is often a notable gap (days)
  # between when a version is tagged and released.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "9ec17161f4fdc9f11ce3f86608f692a64031e278dfabc95d25359f1486e56161"
    sha256 cellar: :any,                 arm64_sonoma:  "7b583cc49fd01d11e01b12c9228acf6f750af1f720c5e785c07b56549af9948a"
    sha256 cellar: :any,                 arm64_ventura: "eddb15f21bc11c5db031ac20eb3346b709f493d5a6a06d7a7974af01ffbc2b58"
    sha256 cellar: :any,                 sonoma:        "4898343bf3001c9cc3724136cb1b82ae53b51d7e12e529059fd2c4b3e9d8b815"
    sha256 cellar: :any,                 ventura:       "16867c7fb92dcff4aaad446b86bc9c9f4f32a95c65e74c20646c28298cf2e123"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7e1e73fa4867cf955b2e81fcc37971619a6374511cc1cde616a7419fd8d29b0f"
  end

  depends_on "corepack" => :build
  # Use "go" again after https://github.com/gravitational/teleport/commit/e4010172501f0ed18bb260655c83606dfa872fbd
  # is released, likely in a version 17.x.x (or later?):
  depends_on "go@1.22" => :build
  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  # TODO: try to remove rustup dependancy, see https://github.com/Homebrew/homebrew-core/pull/191633#discussion_r1774378671
  depends_on "rustup" => :build
  depends_on "wasm-pack" => :build
  depends_on "libfido2"
  depends_on "node"
  depends_on "openssl@3"

  uses_from_macos "curl" => :test
  uses_from_macos "netcat" => :test
  uses_from_macos "zip"

  conflicts_with "etsh", because: "both install `tsh` binaries"
  conflicts_with "tctl", because: "both install `tctl` binaries"

  def install
    ENV.prepend_path "PATH", Formula["rustup"].bin
    system "rustup", "default", "stable"
    system "rustup", "set", "profile", "minimal"

    ENV.deparallelize { system "make", "full", "FIDO2=dynamic" }
    bin.install Dir["build/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/teleport version")
    assert_match version.to_s, shell_output("#{bin}/tsh version")
    assert_match version.to_s, shell_output("#{bin}/tctl version")

    mkdir testpath/"data"
    (testpath/"config.yml").write <<~EOS
      version: v2
      teleport:
        nodename: testhost
        data_dir: #{testpath}/data
        log:
          output: stderr
          severity: WARN
    EOS

    fork do
      exec "#{bin}/teleport start --roles=proxy,node,auth --config=#{testpath}/config.yml"
    end

    sleep 10
    system "curl", "--insecure", "https://localhost:3080"

    status = shell_output("#{bin}/tctl --config=#{testpath}/config.yml status")
    assert_match(/Cluster\s*testhost/, status)
    assert_match(/Version\s*#{version}/, status)
  end
end
