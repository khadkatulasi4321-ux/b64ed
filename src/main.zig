const std = @import("std");
const b64 = @import("base64ed");

pub fn main(init: std.process.Init) !void {
    var memBuff: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memBuff);
    const alloc = fba.allocator();
    errdefer std.debug.print("opps something went wrong", .{});
    const ed = b64.Base64.init();
    const ar = init.arena.allocator();
    const args = try init.minimal.args.toSlice(ar);

    std.debug.print("\n", .{});
    const cmd = args[1];
    var text: []const u8 = undefined;
    if (!std.ascii.eqlIgnoreCase(cmd, "help") or
        !std.ascii.eqlIgnoreCase(cmd, "-h") or
        !std.ascii.eqlIgnoreCase(cmd, "version") or
        !std.ascii.eqlIgnoreCase(cmd, "-v"))
    {
        text = args[2];
    }
    if (std.ascii.eqlIgnoreCase(cmd, "encode") or std.ascii.eqlIgnoreCase(cmd, "-e")) {
        const out = try ed.encode(alloc, text);
        std.debug.print("{s} = {s}", .{ text, out });
    } else if (std.ascii.eqlIgnoreCase(cmd, "decode") or std.ascii.eqlIgnoreCase(cmd, "-d")) {
        const out = try ed.decode(alloc, "text");
        std.debug.print("{s} = {s}", .{ text, out });
    } else if (std.ascii.eqlIgnoreCase(cmd, "help") or std.ascii.eqlIgnoreCase(cmd, "-h")) {
        std.debug.print(
            \\ b64ed - a cli b64 converter
            \\ usage:
            \\  b64ed [option] [text]
            \\ options:
            \\  -e , encode     encodes text into b64 
            \\  -d , decode     decodes b64ed-texted into normal text 
            \\  -h , help       shows this dialog 
            \\ example:
            \\  b64ed -e "i love zig"
            \\  b64ed -d "aSB3YW50IHRvIGNoYW5nZSB0aGUgd29ybGQgLSA5OTk="
        , .{});
    }
}
