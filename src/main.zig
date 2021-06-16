const std = @import("std");
const c = @import("raylib.zig");
const Vector2 = c.Vector2;

fn add(a: i32, b: i32) i32 {
    return a + b;
}

const debug = false;
const friction = 0.1;
const max_velocity = 1.0;

const Texture = struct {
    data: []const u8,
    width: i32,
    height: i32,
};

const spritesheet = Texture {
    .data = @embedFile("../res/arcade_platformerV2.png"),
    .width = 352,
    .height = 320,
};

const TextureRegion = struct {
    texture: *const Texture,
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    fn toRect(self: *const TextureRegion) c.Rectangle {
        return .{
            .x = self.x,
            .y = self.y,
            .width = self.w,
            .height = self.h,
        };
    }
};

const Animation = struct {
    frames: [] const TextureRegion,
    play_speed: i32
};

var player_walk = Animation {
    .frames = &[_]TextureRegion {
        TextureRegion {
            .texture = &spritesheet,
            .x = 7,
            .y = 14,
            .w = 18,
            .h = 19,
        },
        TextureRegion {
            .texture = &spritesheet,
            .x = 40,
            .y = 13,
            .w = 17, // 18
            .h = 18,
        },
        TextureRegion {
            .texture = &spritesheet,
            .x = 71,
            .y = 14,
            .w = 18,
            .h = 19,
        },
        TextureRegion {
            .texture = &spritesheet,
            .x = 6,
            .y = 45,
            .w = 20,
            .h = 18,
        },
        //TextureRegion {
        //    .texture = &spritesheet,
        //    .x = 38,
        //    .y = 45,
        //    .w = 20, // 18
        //    .h = 18,
        //},
        //TextureRegion {
        //    .texture = &spritesheet,
        //    .x = 71,
        //    .y = 45,
        //    .w = 18,
        //    .h = 18,
        //},
    },
    .play_speed = 12,
};

var player_idle = Animation {
    .frames = &[_]TextureRegion {
        TextureRegion {
            .texture = &spritesheet,
            .x = 7,
            .y = 14,
            .w = 18,
            .h = 19,
        },
    },
    .play_speed = 12,
};

const Player = struct {
    pos: c.Vector2,
    vel: c.Vector2,
};

pub fn main() anyerror!void {
    c.InitWindow(800, 600, "raylib");
    defer c.CloseWindow();
    var image = c.LoadImageFromMemory(".png", spritesheet.data.ptr, spritesheet.width * spritesheet.height);
    var texture = c.LoadTextureFromImage(image);

    var camera = c.Camera2D {
        .target = .{.x = 0, .y = 0},
        .offset = .{.x = 0, .y = 0},
        .rotation = 0,
        .zoom = 4.0,
    };

    var player = Player {
        .pos = .{
            .x = 0,
            .y = 40,
        },
        .vel = .{
            .x = 0,
            .y = 0,
        },
    };

    const accel_step = 0.01;
    var acceleration: f32 = 0.2;
    var x: f32 = 20;
    var y: f32 = 20;
    var frame_index: usize = 0;
    var frame: i32 = 0;
    var msg = [_]u8{0} ** 100;
    var pos_msg = [_]u8{0} ** 100;
    var animation = player_idle;
    var was_moving = false;

    c.SetTargetFPS(144);
    while(!c.WindowShouldClose()) {
        frame += 1;

        c.BeginDrawing();
        c.BeginMode2D(camera);
        {
            if (c.IsKeyPressed(c.KEY_DOWN)) acceleration -= accel_step;
            if (c.IsKeyPressed(c.KEY_UP)) acceleration += accel_step;

            if (c.IsKeyDown(c.KEY_D) and player.vel.x < max_velocity) player.vel.x += acceleration;
            if (c.IsKeyDown(c.KEY_A) and player.vel.x > -max_velocity) player.vel.x -= acceleration;
            player.pos.x += player.vel.x;

            if (player.vel.x > 0) {
                player.vel.x -= friction;
                if (player.vel.x < 0) {
                    player.vel.x = 0;
                    was_moving = false;
                    animation = player_idle;
                    frame_index = 0;
                }else {
                    was_moving = true;
                }
            }
            if (player.vel.x < 0) {
                player.vel.x += friction;
                if (player.vel.x > 0) {
                    player.vel.x = 0;
                    was_moving = false;
                    animation = player_idle;
                    frame_index = 0;
                }else {
                    was_moving = true;
                }
            }
            if (was_moving) {
                animation = player_walk;
                was_moving = false;
                frame_index = 0;
            }

            c.ClearBackground(c.BLACK);
            var source_rect = animation.frames[frame_index].toRect();
            var dest_rect = c.Rectangle {
                .x = player.pos.x,
                .y = player.pos.y,
                .width = source_rect.width,
                .height = source_rect.height,
            };
            var offset = c.Vector2 {
                .x = source_rect.width / 2,
                .y = source_rect.height / 2
            };

            c.DrawTexturePro(texture, source_rect, dest_rect, offset, 0.0,  c.WHITE);
            if (@rem(frame, animation.play_speed) == 0) {
                frame_index = (frame_index + 1) % animation.frames.len;
            }

            if (debug) {
                dest_rect.x -= offset.x;
                dest_rect.y -= offset.y;
                c.DrawRectangleLinesEx(dest_rect, 1, c.GREEN);
            }

            _ = try std.fmt.bufPrint(&msg, "Acceleration: {d:1.2}", .{acceleration});
            _ = try std.fmt.bufPrint(&pos_msg, "Pos.X: {d:2.2}\nPos.Y: {d:2.2}", .{player.pos.x, player.pos.y});
        }
        c.EndMode2D();
        c.DrawText(&msg, 0, 0, 20, c.RAYWHITE);
        c.DrawText(&pos_msg, 0, 20, 20, c.RAYWHITE);
        c.EndDrawing();
    }
}
