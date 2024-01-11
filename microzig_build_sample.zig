//  zig build -Doptimize=ReleaseSmall

const std = @import("std");
const ch32v = @import("ch32v");

pub fn build(b: *std.Build) void {
    const microzig = @import("microzig").init(b, "microzig");
    const optimize = b.standardOptimizeOption(.{});

    const firmware = microzig.addFirmware(b, .{
        .name = "fatfs",
        .target = ch32v.boards.suzuduino_uno.v1,
        .optimize = optimize,
        .source_file = .{ .path = "src/fatfs.zig" },
    });

    const zfat_pkg = b.addModule("zfat", .{
        .source_file = .{ .path = "zfat/src/fatfs.zig" },
    });
    firmware.addAppDependency("zfat", zfat_pkg, .{
        .depend_on_microzig = false,
    });
    firmware.addCSourceFile(.{ .file = .{ .path = "zfat/src/fatfs/fflib.c" }, .flags = &.{} });
    firmware.addCSourceFile(.{ .file = .{ .path = "zfat/src/fatfs/ff.c" }, .flags = &.{} });
    firmware.addCSourceFile(.{ .file = .{ .path = "zfat/src/fatfs/ffunicode.c" }, .flags = &.{} });
    firmware.addCSourceFile(.{ .file = .{ .path = "zfat/src/fatfs/ffsystem.c" }, .flags = &.{} });
    firmware.addIncludePath(.{ .path = "zfat/src/fatfs" });
    firmware.addIncludePath(.{ .path = "." });
    // firmware.addSystemIncludePath(.{ .path = "/snap/zig/8241/lib/libc/musl/include" });
    // firmware.addSystemIncludePath(.{ .path = "/snap/zig/8241/lib/libc/include/riscv64-linux-musl" });
    firmware.addSystemIncludePath(.{ .path = "/snap/zig/8241/lib/libc/include/generic-glibc" });

    // install bin in zig-out/firware
    microzig.installFirmware(b, firmware, .{});

    // For debugging, also always install the firmware as an ELF file
    microzig.installFirmware(b, firmware, .{ .format = .elf });
}
