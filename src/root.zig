const std = @import("std");

pub const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";

        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }

    fn _calc_encode_length(input: []const u8) !usize {
        if (input.len < 3)
            return 4;

        const n_groups = try std.math.divCeil(usize, input.len, 3);
        return n_groups * 4;
    }

    fn _calc_decode_length(input: []const u8) !usize {
        if (input.len % 4 != 0)
            return error.InvalidLength;

        const n_groups = try std.math.divFloor(
            usize,
            input.len,
            4,
        );

        var output_len = n_groups * 3;

        var i = input.len;

        while (i > 0) {
            i -= 1;

            if (input[i] == '=') {
                output_len -= 1;
            } else {
                break;
            }
        }

        return output_len;
    }

    pub fn encode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 0)
            return "";

        const n_out = try _calc_encode_length(input);

        var out = try allocator.alloc(u8, n_out);

        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: usize = 0;

        for (input) |byte| {
            buf[count] = byte;
            count += 1;

            if (count == 3) {
                out[iout] = self._char_at(buf[0] >> 2);

                out[iout + 1] =
                    self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4));

                out[iout + 2] =
                    self._char_at(((buf[1] & 0x0f) << 2) | (buf[2] >> 6));

                out[iout + 3] =
                    self._char_at(buf[2] & 0x3f);

                iout += 4;
                count = 0;
            }
        }

        if (count == 1) {
            out[iout] = self._char_at(buf[0] >> 2);

            out[iout + 1] =
                self._char_at((buf[0] & 0x03) << 4);

            out[iout + 2] = '=';
            out[iout + 3] = '=';
        }

        if (count == 2) {
            out[iout] = self._char_at(buf[0] >> 2);

            out[iout + 1] =
                self._char_at(((buf[0] & 0x03) << 4) | (buf[1] >> 4));

            out[iout + 2] =
                self._char_at((buf[1] & 0x0f) << 2);

            out[iout + 3] = '=';
        }

        return out;
    }

    fn _char_index(self: Base64, char: u8) !u8 {
        if (char == '=')
            return 64;

        for (0..64) |i| {
            if (self._char_at(i) == char)
                return @intCast(i);
        }

        return error.InvalidCharacter;
    }

    pub fn decode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 0)
            return "";

        const n_output = try _calc_decode_length(input);

        var output = try allocator.alloc(u8, n_output);

        var count: u8 = 0;
        var iout: usize = 0;

        var buf = [4]u8{ 0, 0, 0, 0 };

        for (input) |char| {
            buf[count] = try self._char_index(char);
            count += 1;

            if (count == 4) {
                output[iout] =
                    (buf[0] << 2) | (buf[1] >> 4);

                if (buf[2] != 64) {
                    output[iout + 1] =
                        ((buf[1] & 0x0f) << 4) |
                        (buf[2] >> 2);
                }

                if (buf[3] != 64) {
                    output[iout + 2] =
                        ((buf[2] & 0x03) << 6) |
                        buf[3];
                }

                iout += 3;
                count = 0;
            }
        }

        return output;
    }
};

pub const cmds = enum {
    encode,
    decode,
    help,
};
