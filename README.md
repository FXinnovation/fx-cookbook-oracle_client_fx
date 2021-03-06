# oracle_client_fx

The oracle_client_fx cookbook provides a resource to install Oracle client.

### Supported oracle version
* 11.2.0.4 (careful, the public Oracle version 11.2.0.1 is not supported)

## Requirements

### Cookbooks
N/A

### Chef
* `>= 13.9`

### Platforms
* rhel6
* rhel7
* centos6
* centos7

## Resources
### oracle_client_fx

#### Properties

| Name                  | Type          | Required | Default | Operating System | Description |
| --------------------- | ------------- | -------- | ------- | ---------------- | ----------- |
| `java_version`        | `%w(8 10 11)` | `true`   | 8       | `All`            | Java version to install. |
| `user`                | `String`      | `true`   | oracle  | `All`            | Oracle client username. |
| `group`               | `String`      | `true`   | dba     | `All`            | Oracle client group. |
| `version`             | `['11.2']`    | `true`   | 11.2    | `All`            | Version to install. |
| `source`              | `String`      | `true`   | -       | `All`            | Source URL of the oracle client zip file. |
| `checksum`            | `String`      | `false`  | -       | `All`            | Checksum of the oracle client zip file to verify. |
| `sqlnet_options`      | `Hash`        | `false`  | {}      | `All`            | sqlnet.ora file options. |
| `tnsnames_options`    | `String`      | `false`  | ''      | `All`            | tnsnames.ora file content. |
| `tls_certificate_url` | `String`      | `false`  | ''      | `All`            | URL of the root certificate to add in the client wallet. |

### patchelf_fx

Run patchelf to a set of binaries.
It modifies linked libraries of ELF binaries in `binary_path` to use libraries in `library_path` in priority.

For more information, check [the NixOS PatchELF documentation](https://nixos.org/patchelf.html).

This resource is kept in this cookbook even if it should be an external dependency.
**This resource should eventually be moved in its own cookbook.**
That being said, the moving will not cause any breaking change on this cookbook.

#### Properties

| Name           | Type       | Required | Default | Operating System | Description |
| -------------- | ---------- | -------- | ------- | ---------------- | ----------- |
| `library_path` | `String`   | `true`   | -       | `All`            | Library paths to use, separated by `:` |
| `binary_path`  | `String`   | `true`   | -       | `All`            | Binaries to patch.                     |


## Versionning
This cookbook will follow semantic versionning 2.0.0 as described [here](https://semver.org/)

## Licence
MIT
