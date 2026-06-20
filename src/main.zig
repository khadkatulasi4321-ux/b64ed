const std = @import("std");
const b64 = @import("base64ed");

pub fn main(init: std.process.Init) !void {
    errdefer std.debug.print("opps something went wrong", .{});
    const ed = b64.Base64.init();
    const ar = init.arena.allocator();
    const args = try init.minimal.args.toSlice(ar);
    for (0.., args) |n, arg| {
        std.debug.print("{d} : {s}\n", .{ n, arg });
    }
    std.debug.print("\n", .{});
    const cmd = args[1];
    const text = args[2];
    if (std.ascii.eqlIgnoreCase(cmd, "encode")) {
        const out = ed.encode(init.gpa, text);
        std.debug.print("{s} = {s}", .{ text, out });
    } else if (std.ascii.eqlIgnoreCase(cmd, "decode")) {
        const out = ed.decode(init.gpa, "text");
        std.debug.print("{s} = {s}", .{ text, out });
    }
}
