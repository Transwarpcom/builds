# w1700k builder

This project automates the process of building OpenWrt firmware images for the Gemtek W1700k

fastbuild adapted from https://github.com/tete1030/openwrt-fastbuild-actions

## Release verification

Each successful firmware release includes the sysupgrade image, `build_info.txt`,
and `SHA256SUMS`. Download them into one directory and run
`sha256sum -c SHA256SUMS` before using the image. The build manifest records
the source and feed commits, profile file hashes, and builder image ID.

Releases are created before old releases are pruned. The three newest published
releases for each build profile are retained. GitHub Actions release tags include
the run ID and attempt number so reruns do not reuse a tag.
