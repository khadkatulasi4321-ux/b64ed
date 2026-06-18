const std = @import("std");
const b64 = @import("base64ed");

pub fn main() !void {
    var memBuff: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memBuff);
    const alloc = fba.allocator();

    const text = "samsit";
    const base64 = b64.Base64.init();
    const encoded_text = base64.encode(alloc, text);
    std.debug.print("samsit in base 64   {s}", .{encoded_text});
}
