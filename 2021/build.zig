const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // Set up an exe for each day
    comptime var day = 1;
    inline while (day <= 25) : (day += 1) {
        @setEvalBranchQuota(100000); // this comptimePrint is pretty expensive
        const dayString = comptime std.fmt.comptimePrint("day{:0>2}", .{ day });
        const zigFile = "src/" ++ dayString ++ ".zig";
        
        const exe = b.addExecutable(dayString, zigFile);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const install_cmd = b.addInstallArtifact(exe);

        const install_step = b.step("install_" ++ dayString, "Install " ++ dayString ++ ".exe");
        install_step.dependOn(&install_cmd.step);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(dayString, "Run " ++ dayString);
        run_step.dependOn(&run_cmd.step);
    }
}
