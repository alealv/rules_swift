load(":swift_autoconfiguration.bzl", "create_linux_toolchain")
load("@com_grail_bazel_toolchain//toolchain:rules.bzl", "llvm", "toolchain", "llvm_toolchain")

def _swift_register_toolchain_impl(repository_ctx):
    os_name = repository_ctx.os.name.lower()

    if os_name.startswith("mac os"):
        # _create_xcode_toolchain(repository_ctx)
        return
    elif os_name.startswith("windows"):
        platform = "windows10"
    else:
        # TODO: detect me
        platform = repository_ctx.attr.swift_linux_platform

    repository_ctx.download_and_extract(
        url = "https://download.swift.org/swift-{version}-release/{platform}/swift-{version}-RELEASE/swift-{version}-RELEASE-{platform_orig}.tar.gz".format(
            version = repository_ctx.attr.swift_version,
            platform = repository_ctx.attr.swift_linux_platform.replace(".", ""),
            platform_orig = platform,
        ),
        type = "tar.gz",
        stripPrefix = "swift-{version}-RELEASE-{platform}".format(version = repository_ctx.attr.swift_version, platform = platform),
    )
    repository_ctx.file("usr/BUILD", "")
    repository_ctx.file("usr/bin/BUILD", "exports_files(glob([\"*\"], exclude=[\"BUILD\"], allow_empty=False))")
 
    create_linux_toolchain(repository_ctx, repository_ctx.path("usr/bin/swiftc"))

swift_register_toolchain = repository_rule(
    environ = ["CC", "PATH"],
    attrs = {
        "swift_version": attr.string(),
        "swift_linux_platform": attr.string(doc = "Platform as seen on https://www.swift.org/download/", values = [
            "ubuntu18.04",
            "ubuntu20.04",
            "ubuntu22.04",
            "centos7",
            "amazonlinux2",
        ]),
    },
    implementation = _swift_register_toolchain_impl,
)

def swift_register_downloaded_toolchain(swift_version):
    # TODO: stop using the hardcoded name for the toolchain
    swift_register_toolchain(
        name = "build_bazel_rules_swift_local_config",
        swift_version = swift_version,
        swift_linux_platform = "ubuntu20.04",
    )


