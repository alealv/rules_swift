"""Downloads and registers a Swift toolchain for Linux
"""

load(":swift_autoconfiguration.bzl", "create_linux_toolchain")

def _swift_register_linux_toolchain_impl(repository_ctx):
    os_name = repository_ctx.os.name

    if not os_name.startswith("linux"):
        return

    repository_ctx.download_and_extract(
        url = "https://download.swift.org/swift-{version}-release/{platform}/swift-{version}-RELEASE/swift-{version}-RELEASE-{platform_orig}.tar.gz".format(
            version = repository_ctx.attr.swift_version,
            platform = repository_ctx.attr.swift_linux_platform.replace(".", ""),
            platform_orig = repository_ctx.attr.swift_linux_platform,
        ),
        type = "tar.gz",
        stripPrefix = "swift-{version}-RELEASE-{platform}".format(version = repository_ctx.attr.swift_version, platform = repository_ctx.attr.swift_linux_platform),
    )

    create_linux_toolchain(repository_ctx, repository_ctx.path("usr/bin/swiftc"))

swift_register_linux_toolchain = repository_rule(
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
    implementation = _swift_register_linux_toolchain_impl,
)
