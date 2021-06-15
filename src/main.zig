const std = @import("std");
const c = @import("raylib.zig");

const ZIGDARK = .{
    .r = 17, .g = 17, .b = 17, .a = 255
};

const Texture = struct {
    data: *const []u8,
    width: i32,
    height: i32,
};

const spritesheet = .{
    .data = @embedFile(""),
    .width = 400,
    .height = 400,
};

pub fn main() anyerror!void {
    c.InitWindow(800, 600, "raylib");

    

    while(!c.WindowShouldClose()) {
        c.BeginDrawing();
        {
            c.ClearBackground(ZIGDARK);
        }
        c.EndDrawing();
    }
    c.CloseWindow();
}
