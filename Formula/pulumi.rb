class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://pulumi.io/"
  url "https://github.com/pulumi/pulumi.git",
      :tag      => "v0.16.10",
      :revision => "5ec78df73df5056dcb67fd560e8114b5d1cbcb7d"

  bottle do
    cellar :any_skip_relocation
    sha256 "ce91cf8f5a9c91d350780e612e3055e584ac192e70ceeb47ce6f46e500a3dd7a" => :mojave
    sha256 "5dda845c014d06c62df2afed50b08c50b60dbacdfdbb5bbaf26a63e7d86f9bb4" => :high_sierra
    sha256 "1cb5e9da430a20d983eeb25a2e1478b0f536afa78243d658a27dd35a5532363e" => :sierra
    sha256 "1618d6a03cb771b190ca1d9fca9ed489f1e0361c497f969dcf87d3203e92f95f" => :x86_64_linux
  end

  depends_on "dep" => :build
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/pulumi/pulumi"
    dir.install buildpath.children

    cd dir do
      system "dep", "ensure", "-vendor-only"
      system "make", "dist"
      bin.install Dir["#{buildpath}/bin/*"]
      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion bash")
      (bash_completion/"pulumi").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion zsh")
      (zsh_completion/"_pulumi").write output
    end
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_TEMPLATE_PATH"] = testpath/"templates"
    system "#{bin}/pulumi", "new", "aws-typescript", "--generate-only",
                                                     "--force", "-y"
    assert_predicate testpath/"Pulumi.yaml", :exist?, "Project was not created"
  end
end
