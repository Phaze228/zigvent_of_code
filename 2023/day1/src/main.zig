const std = @import("std");

const PUZ_FILE = "./src/puz1.txt";

pub fn main() !void {
    var puz = try std.fs.cwd().openFile(PUZ_FILE, .{});
    defer puz.close();
    std.debug.print("\n", .{});

    var buf_rdr = std.io.bufferedReader(puz.reader());
    var buf_stream = buf_rdr.reader();
    var buf: [2048]u8 = undefined;
    var sum: u32 = 0;
    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var number: [2]u8 = undefined;
        const stripped = std.mem.trim(u8, line, "\r");
        std.debug.print("{s}\n", .{stripped});
        // const first = findSubStrFirst(stripped);
        // const second = findSubStrLast(stripped);
        // std.debug.print("SUBSTRING: {s} -> FIRST: {s} | {d} ---- SECOND: {s} | {d}\n", .{ stripped, first.digit, first.index, second.digit, second.index });
        number[0] = findFirstDigit(stripped);
        number[1] = findLastDigit(stripped);
        const num = try std.fmt.parseInt(u32, &number, 10);
        std.debug.print("Number on this line: {any}\n", .{num});
        std.debug.print("----\n", .{});
        sum += num;
    }
    std.debug.print("Result: {d} \n", .{sum});
}

const TextDigit = enum(u8) {
    one = '1',
    two = '2',
    three = '3',
    four = '4',
    five = '5',
    six = '6',
    seven = '7',
    eight = '8',
    nine = '9',
    zero = '0',
};

pub fn findFirstDigit(text: []const u8) u8 {
    var index: usize = 1000;
    var digit: u8 = undefined;
    const text_digit = findSubStrFirst(text);
    for (text, 0..) |v, i| {
        if (v - '0' <= 9) {
            index = @min(index, i);
            digit = v;
            break;
        }
    }
    if (text_digit.index < index) {
        const start = text_digit.index;
        const end = start + text_digit.digit.len;
        const digit_enum = std.meta.stringToEnum(TextDigit, text[start..end]);
        digit = @intFromEnum(digit_enum.?);
    }
    // std.debug.print("substr digit: {any}\n", .{digit});
    return digit;
}
pub fn findLastDigit(text: []const u8) u8 {
    var index: usize = 0;
    var digit: u8 = undefined;
    const text_digit = findSubStrLast(text);
    var i: usize = text.len - 1;
    while (i >= 0) : (i -= 1) {
        const v = text[i];
        if (v - '0' <= 9) {
            index = @max(index, i);
            digit = v;
            break;
        }
    }
    if (text_digit.index > index) {
        const start = text_digit.index;
        const end = start + text_digit.digit.len;
        const digit_enum = std.meta.stringToEnum(TextDigit, text[start..end]);
        digit = @intFromEnum(digit_enum.?);
    }
    // std.debug.print("substr digit: {any}\n", .{digit});
    return digit;
}
const DigitIndex = struct {
    digit: []const u8 = "none",
    index: usize,
};

pub fn findSubStrFirst(haystack: []const u8) DigitIndex {
    const digits = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero" };
    var i: usize = 1000;
    var ref: DigitIndex = DigitIndex{ .digit = "", .index = i };
    for (digits) |d| {
        const index = std.mem.indexOf(u8, haystack, d);
        while (index) |k| {
            if (k < ref.index) {
                ref = DigitIndex{ .digit = d, .index = k };
                i = k;
            }
            break;
        }
    }
    return ref;
}
pub fn findSubStrLast(haystack: []const u8) DigitIndex {
    const digits = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero" };
    var i: usize = 0;
    var ref: DigitIndex = DigitIndex{ .digit = "", .index = i };
    for (digits) |d| {
        const index = std.mem.lastIndexOf(u8, haystack, d);
        while (index) |k| {
            // const theDigit = std.meta.stringToEnum(TextDigit, haystack[k .. k + d.len]);
            // std.debug.print("The_Digit {any}\n", .{@intFromEnum(theDigit.?)});
            if (k > i and k > ref.index) {
                ref = DigitIndex{ .digit = d, .index = k };
            }
            break;
        }
    }
    return ref;
}
