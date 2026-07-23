# Homebrew formula for isopod.
#
#   brew tap jonathanmcsweet/isopod
#   brew install isopod            # stable (once a release is tagged + sha set)
#   brew install --HEAD isopod     # track the latest commit on master
#
# Cutting a stable release: merge, then tag v<x.y.z> on master, then update the
# url + sha256 below IN THE TAP. See RELEASING.md for the exact commands.
class Isopod < Formula
  desc "Disposable, isolated IDE containers that keep AI agents off your host"
  homepage "https://github.com/jonathanmcsweet/isopod"
  url "https://github.com/jonathanmcsweet/isopod/archive/refs/tags/v2.8.0.tar.gz"
  # Placeholder until v0.3.0 is tagged & pushed — replace with the real digest
  # (see RELEASING.md). Until then, install with `--HEAD`.
  sha256 "638a117596b23ef430640d739cbbdb116800bbcc3d9f88ab6716e3fdbacd2605"
  license "Apache-2.0"
  head "https://github.com/jonathanmcsweet/isopod.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "bash"     # isopod uses bash 4+ features; macOS ships bash 3.2
  depends_on "openssh"  # ssh, ssh-keygen, ssh-keyscan

  # A container engine (podman or docker) is required at runtime but left to the
  # user to install — `brew install podman` then `podman machine init/start` on
  # macOS — because engine choice and setup are environment-specific.

  def install
    # Mirror isopod's symlink install model: keep lib/ and security/ beside the
    # script so it resolves its helpers through the bin symlink.
    libexec.install "isopod", "lib", "security", "share"
    bin.install_symlink libexec/"isopod"

    bash_completion.install "completions/isopod.bash" => "isopod"
    zsh_completion.install "completions/_isopod"
  end

  def caveats
    <<~EOS
      isopod needs a container engine that it does NOT install for you:
        brew install podman   # recommended (rootless); then: podman machine init && podman machine start
      Verify your setup with:
        isopod doctor
    EOS
  end

  test do
    assert_match(/isopod \d+\.\d+\.\d+/, shell_output("#{bin}/isopod version"))
    assert_match "Usage:", shell_output("#{bin}/isopod help")
  end
end
