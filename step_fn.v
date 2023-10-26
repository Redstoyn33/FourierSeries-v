module main

import raylibv as rl
import math

fn main() {
	rl.init_window(100, 100, 'hi'.str)
	rl.set_window_size(rl.get_monitor_width(rl.get_current_monitor()) * 3 / 4, rl.get_monitor_height(rl.get_current_monitor()) * 3 / 4)
	rl.set_window_position(rl.get_monitor_width(rl.get_current_monitor()) / 12, rl.get_monitor_height(rl.get_current_monitor()) / 12)

	rl.set_target_fps(60)
	w := rl.get_monitor_width(rl.get_current_monitor()) * 3 / 4
	h := rl.get_monitor_height(rl.get_current_monitor()) * 3 / 4
	mut time := f32(0.0)

	count := 4
	mut circles := []Circle{cap: 4}
	for i in 0 .. count {
		circles << Circle{
			radius: h / 3 / (i * 2 + 1)
			fr: (i * 2 + 1)
			color: colors[i % colors.len]
		}
	}

	mut buff := new_buff[f32]([]f32{len: 500})

	for !rl.window_should_close() {
		time -= 0.01
		//
		rl.begin_drawing()
		{
			rl.clear_background(rl.black)

			mut pos := rl.Vector2{w / 3, h / 2}
			for c in circles {
				c.draw(pos, time)
				n_pos := c.calc_end_pos(pos, time)
				rl.draw_line(int(pos.x), int(pos.y), int(n_pos.x), int(n_pos.y), c.color)
				pos = n_pos
			}
			rl.draw_circle(int(pos.x), int(pos.y), 10, rl.white)

			buff.push(pos.y)
			offs := w * 2 / 3
			rl.draw_line(int(pos.x), int(pos.y), offs, int(pos.y), rl.white)
			for i in 1 .. buff.size() {
				n_pos := buff.get(i)
				rl.draw_line(offs + i * (w - offs) / buff.size(), int(pos.y), offs + (i +
					1) * (w - offs) / buff.size(), int(n_pos), rl.white)
				pos.y = n_pos
			}
		}
		rl.end_drawing()
	}
}

const colors = [rl.get_color(0x845ec2ff), rl.get_color(0xd65db1ff),
	rl.get_color(0xff6f91ff), rl.get_color(0xff9671ff), rl.get_color(0xffc75fff),
	rl.get_color(0xf9f871ff)]

struct Circle {
	radius f32
	fr     f32
	offset f32
	color  rl.Color
}

fn (c Circle) draw(pos rl.Vector2, time f32) {
	rl.draw_circle_lines(int(pos.x), int(pos.y), c.radius, c.color)
}

fn (c Circle) calc_end_pos(pos rl.Vector2, time f32) rl.Vector2 {
	return rl.Vector2{
		x: c.radius * math.cosf(time * c.fr + c.offset) + pos.x
		y: c.radius * math.sinf(time * c.fr + c.offset) + pos.y
	}
}

struct Buff[T] {
mut:
	i    int
	data []T
}

fn new_buff[T](init []T) Buff[T] {
	return Buff[T]{
		i: 0
		data: init
	}
}

fn (b Buff[T]) get(i int) T {
	return b.data[(b.i + i) % b.size()]
}

fn (mut b Buff[T]) push(n T) {
	b.i = if b.i == 0 { b.size() - 1 } else { b.i - 1 }
	b.data[b.i] = n
}

fn (b Buff[T]) size() int {
	return b.data.len
}
