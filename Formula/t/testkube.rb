class Testkube < Formula
  desc "Kubernetes-native framework for test definition and execution"
  homepage "https://testkube.io"
  url "https://github.com/kubeshop/testkube/archive/refs/tags/v2.1.25.tar.gz"
  sha256 "8248561991b9ee05fef9032b97ec60aab4658ae2ca3d7438598590175cdb5ccd"
  license "MIT"
  head "https://github.com/kubeshop/testkube.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cdba87907e54df949f005c5d241fbd2bcbca770cd0e80458dd20481a04290a0a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cdba87907e54df949f005c5d241fbd2bcbca770cd0e80458dd20481a04290a0a"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "cdba87907e54df949f005c5d241fbd2bcbca770cd0e80458dd20481a04290a0a"
    sha256 cellar: :any_skip_relocation, sonoma:        "a1eca501047124670b967946b7ff6f192d6c31d98612ca3ac485402d115dee65"
    sha256 cellar: :any_skip_relocation, ventura:       "a1eca501047124670b967946b7ff6f192d6c31d98612ca3ac485402d115dee65"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f6237bc03fc9825842ab7ba5e27ab30521ccae89fcdbc457edf2e21fa55abefe"
  end

  depends_on "go" => :build
  depends_on "helm"
  depends_on "kubernetes-cli"

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.builtBy=#{tap.user}
    ]

    system "go", "build", *std_go_args(output: bin/"kubectl-testkube", ldflags:),
      "cmd/kubectl-testkube/main.go"

    bin.install_symlink "kubectl-testkube" => "testkube"

    generate_completions_from_executable(bin/"kubectl-testkube", "completion")
  end

  test do
    output = shell_output("#{bin}/kubectl-testkube get tests 2>&1", 1)
    assert_match("no configuration has been provided", output)

    output = shell_output("#{bin}/kubectl-testkube help")
    assert_match("Testkube entrypoint for kubectl plugin", output)
  end
end
