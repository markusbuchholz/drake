# -*- python -*-

load("@drake//tools/workspace:execute.bzl", "path", "which")

def _impl(repository_ctx):
    command = repository_ctx.attr.command
    found_command = which(
        repository_ctx,
        command,
        repository_ctx.attr.additional_search_paths,
    )
    if not found_command:
        fail("Could not find {} on PATH={}".format(
            command,
            path(repository_ctx),
        ))
    repository_ctx.symlink(found_command, command)
    build_file_content = """# -*- python -*-

# DO NOT EDIT: generated by which_repository()

# A symlink to {}.
exports_files(["{}"])
""".format(found_command, command)
    repository_ctx.file(
        "BUILD.bazel",
        content = build_file_content,
        executable = False,
    )

which_repository = repository_rule(
    attrs = {
        "command": attr.string(mandatory = True),
        "additional_search_paths": attr.string_list(),
    },
    local = True,
    configure = True,
    implementation = _impl,
)

"""Alias the result of $(which $command) into a label @$name//:$command (or
@$command if name and command match). The PATH is set according to the path()
function in execute.bzl. The value of the user's PATH environment variable is
ignored.

Changes to any WORKSPACE or BUILD.bazel file will cause this rule to be
re-evaluated because it sets its local attribute. However, note that if neither
WORKSPACE nor **/BUILD.bazel change, then this rule will not be re-evaluated.
This means that adding or removing the presence of `command` on some entry in
the PATH (as defined above) will not be accounted for until something else
changes.

Args:
    command (:obj:`str`): Short name of command, e.g., "cat".
    additional_search_paths (:obj:`list` of :obj:`str`): List of additional
        search paths.
"""
