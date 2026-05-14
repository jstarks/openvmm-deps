# Linux Kernel Configuration

This directory (and `../linux-6.18/`) contain the kernel configs for the
OpenVMM test kernels. These kernels are used by the petri test framework
with Linux direct boot (`Firmware::LinuxDirect`).

Two kernel versions are built:

| Version | Package dir     | Source branch |
|---------|-----------------|---------------|
| 6.1.y   | `pkg/linux/`    | linux-6.1.y   |
| 6.18.y  | `pkg/linux-6.18/` | linux-6.18.y |

The shared build script lives in `pkg/Tools/linux-build.sh`; each
package's `build.sh` is a one-liner that delegates to it.

## Files

- `x86_64.config` — Kernel config for x86_64
- `aarch64.config` — Kernel config for aarch64
- `build.sh` — Wrapper that calls `pkg/Tools/linux-build.sh`

## Updating the kernel configs

The build runs `make olddefconfig` inside the container using the musl
cross-compiler toolchain. To ensure the committed config exactly matches
what the build uses, always extract the final config from the build output
rather than running `olddefconfig` locally (which uses your host compiler
and produces toolchain-dependent noise in the diff).

1. Edit the config file directly (e.g., change `# CONFIG_FOO is not set` to
   `CONFIG_FOO=y`).

2. Build the kernel for the target architecture:

   ```bash
   # For x86_64 (6.1):
   docker build --platform linux/amd64 --target result-linux \
     --output type=local,dest=out/linux -f Dockerfile .

   # For aarch64 (6.1):
   docker build --platform linux/arm64 --target result-linux \
     --output type=local,dest=out/linux -f Dockerfile .

   # For x86_64 (6.18):
   docker build --platform linux/amd64 --target result-linux-6.18 \
     --output type=local,dest=out/linux-6.18 -f Dockerfile .

   # For aarch64 (6.18):
   docker build --platform linux/arm64 --target result-linux-6.18 \
     --output type=local,dest=out/linux-6.18 -f Dockerfile .
   ```

3. Copy the final config (produced by `olddefconfig` inside the build) back
   into the source tree:

   ```bash
   # 6.1 — For x86_64:
   cp out/linux/linux-6.1/config pkg/linux/x86_64.config
   # 6.1 — For aarch64:
   cp out/linux/linux-6.1/config pkg/linux/aarch64.config

   # 6.18 — For x86_64:
   cp out/linux-6.18/linux-6.18/config pkg/linux-6.18/x86_64.config
   # 6.18 — For aarch64:
   cp out/linux-6.18/linux-6.18/config pkg/linux-6.18/aarch64.config
   ```

4. Review the diff, commit, and push.

## Build

Each package's `build.sh` delegates to the shared
`pkg/Tools/linux-build.sh`, which copies the config to `.config`, runs
`make olddefconfig` (to resolve dependencies and fill in defaults), builds
the kernel, and exports the final `.config` alongside the kernel images.
See the top-level `README.md` for build instructions.
