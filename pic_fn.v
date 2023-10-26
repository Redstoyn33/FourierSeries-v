module main

import raylibv as rl
import math

fn main() {
	rl.init_window(100, 100, 'hi'.str)
	w := rl.get_monitor_width(rl.get_current_monitor()) * 5 / 6
	h := rl.get_monitor_height(rl.get_current_monitor()) * 5 / 6
	rl.set_window_size(w, h)
	rl.set_window_position(rl.get_monitor_width(rl.get_current_monitor()) / 12, rl.get_monitor_height(rl.get_current_monitor()) / 12)

	rl.set_target_fps(60)
	mut time := f32(0.0)
	mut fns := []rl.Vector2{cap: q}
	for i in 0 .. q {
		fns << box(f32(i) / (q - 1))
	}
	mut count := 2
	mut circles := new_circles(fns,count)
	mut buff := new_buff[rl.Vector2]([]rl.Vector2{len: buff_len})

	mut speed := f32(1) / 4
	mut visual := true
	mut sel := 0
	mut rot := false
	mut new_camera_pos := rl.Vector2{0,0}
	mut new_camera_rot := f32(0)
	mut camera := rl.Camera2D{
		offset: rl.Vector2{w/2,h/2}
		target: rl.Vector2{w/2,h/2}
		rotation: 0.0
		zoom: 1
	}

	for !rl.window_should_close() {
		if rl.is_key_released(rl.key_d) {
			fns = new_pic() or { exit(0) }
			circles = new_circles(fns,count)
		}
		if rl.is_key_released(rl.key_v) {
			visual = !visual
		}
		if rl.is_key_released(rl.key_c) {
			p := buff.get(0)
			for _ in 0..buff.size() {
				buff.push(p)
			}
		}
		if rl.is_key_released(rl.key_a) {
			count++
			circles = new_circles(fns,count)
		}
		if rl.is_key_released(rl.key_z) {
			if count > 0 {
				count--
				circles = new_circles(fns,count)
			}
		}
		time += 1 / 60.0 * speed
		if rl.is_key_released(rl.key_right) {
			if sel < circles.len {
				sel++
			}
		}
		if rl.is_key_released(rl.key_left) {
			if sel > 0 {
				sel--
			}
		}
		if rl.is_key_released(rl.key_up) {
			camera.zoom *= 1 / 0.8
		}
		if rl.is_key_released(rl.key_down) {
			camera.zoom *= 0.8
		}
		if rl.is_key_released(rl.key_s) {
			speed *= 1 / 0.8
		}
		if rl.is_key_released(rl.key_x) {
			speed *= 0.8
		}
		if rl.is_key_released(rl.key_r) {
			rot = !rot
		}
		if sel == 0 {
			camera.target.x = w/2
			camera.target.y = h/2
		} else {
			camera.target = new_camera_pos
		}
		if rot {
			camera.rotation = new_camera_rot
		} else {
			camera.rotation = 0
		}
		//
		rl.begin_drawing()
		{
			rl.clear_background(rl.black)

			rl.begin_mode_2d(camera)
			{
				mut pos := rl.Vector2{w / 2, h / 2}
				for i,c in circles {
					if visual {
						c.draw(pos, time)
					}
					n_pos := c.calc_end_pos(pos, time)
					// rl.draw_text(n_pos.str().str,i*300,0,20,rl.white)
					// rl.draw_text(pos.str().str,i*300,500,20,rl.white)

					rl.draw_line(int(pos.x), int(pos.y), int(n_pos.x), int(n_pos.y), c.color)
					pos = n_pos
					if i+1 == sel {
						new_camera_pos = n_pos
						if rot {
							new_camera_rot = (time * 2 * 180 * c.fr) + 45 + 90
						}
					}
				}
				rl.draw_circle(int(pos.x), int(pos.y), 5, rl.white)

				buff.push(pos)
				for i in 1 .. buff.size() {
					n_pos := buff.get(i)
					rl.draw_line(int(pos.x), int(pos.y), int(n_pos.x), int(n_pos.y), rl.Color{
						r: 255
						g: 255
						b: 255
						a: u8((buff.size() - i) * 255 / buff.size())
					})
					pos = n_pos
				}
			}
			rl.end_mode_2d()

			rl.draw_text('fps: ${rl.get_fps()}\nsel: ${sel}\nrot: ${rot}\nspeed: ${speed}\ncount: ${count*2+1}\nzoom: ${camera.zoom}'.str,0,0,24,rl.white)

			// v := box(time - int(time))
			// rl.draw_circle(w / 2 + int(v.x * c_mul), h / 2 + int(v.y * c_mul), 10, rl.white)
			// rl.draw_text(circles.str().str, 0, 0, 16, rl.white)
		}
		rl.end_drawing()
	}
}

const q = 1000

const buff_len = 300

const c_mul = 300.0

const colors = [rl.get_color(0x845ec2ff), rl.get_color(0xd65db1ff),
	rl.get_color(0xff6f91ff), rl.get_color(0xff9671ff), rl.get_color(0xffc75fff),
	rl.get_color(0xf9f871ff)]

struct Circle {
	fr     f32
	c      rl.Vector2
	radius f32
	color  rl.Color
}

fn (c Circle) draw(pos rl.Vector2, time f32) {
	rl.draw_circle_lines(int(pos.x), int(pos.y), c.radius * c_mul, c.color)
}

fn (c Circle) calc_end_pos(pos rl.Vector2, time f32) rl.Vector2 {
	return vec_sum(vec_mul_scal(vec_mul_complex_like(rot(c.fr, time), c.c), c_mul), pos)
}

fn rot(fr f32, time f32) rl.Vector2 {
	return rl.Vector2{
		x: math.cosf(time * -2 * math.pi * fr)
		y: math.sinf(time * -2 * math.pi * fr)
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

fn lerp(time f32, s f32, e f32) f32 {
	return e * time + s * (1 - time)
}

fn vec_mul_scal(vec rl.Vector2, scalar f32) rl.Vector2 {
	return rl.Vector2{
		x: vec.x * scalar
		y: vec.y * scalar
	}
}

fn vec_sum(vec1 rl.Vector2, vec2 rl.Vector2) rl.Vector2 {
	return rl.Vector2{
		x: vec1.x + vec2.x
		y: vec1.y + vec2.y
	}
}

fn vec_len(vec rl.Vector2) f32 {
	return math.sqrtf(vec.x * vec.x + vec.y * vec.y)
}

fn vec_mul_complex_like(c1 rl.Vector2, c2 rl.Vector2) rl.Vector2 {
	return rl.Vector2{(c1.x * c2.x) - (c1.y * c2.y), (c1.x * c2.y) + (c1.y * c2.x)}
}

fn calc_c(fns []rl.Vector2, fr f32) rl.Vector2 {
	mut res := rl.Vector2{}
	for i, v in fns {
		mul := vec_mul_complex_like(v, rot(fr, f32(i) / (fns.len - 1)))
		res.x += mul.x / fns.len
		res.y += mul.y / fns.len
	}
	return res
}

fn new_circles(fns []rl.Vector2, count int) []Circle {
	mut circles := []Circle{cap: count * 2 + 1}
	{
		c := calc_c(fns, 0)
		circles << Circle{
			fr: 0
			c: c
			radius: vec_len(c)
			color: colors[0]
		}
		// println(circles[0].calc_end_pos(rl.Vector2{},0))
	}
	for i in 1 .. count {
		{
			c := calc_c(fns, i)
			circles << Circle{
				fr: i
				c: c
				radius: vec_len(c)
				color: colors[(i * 2) % colors.len]
			}
		}
		{
			c := calc_c(fns, -i)
			circles << Circle{
				fr: -i
				c: c
				radius: vec_len(c)
				color: colors[(i * 2 + 1) % colors.len]
			}
		}
	}

	return circles
}

fn box(time f32) rl.Vector2 {
	return if time <= 0.25 {
		rl.Vector2{
			x: -lerp(time * 4, 2, -2)
			y: 2
		}
	} else if time <= 0.5 {
		rl.Vector2{
			x: -lerp((time - 0.25) * 4, -2, 0)
			y: lerp((time - 0.25) * 4, 2, 0)
		}
	} else if time <= 0.75 {
		rl.Vector2{
			x: -lerp((time - 0.5) * 4, 0, 2)
			y: lerp((time - 0.5) * 4, 0, -2)
		}
	} else {
		rl.Vector2{
			x: -2
			y: lerp((time - 0.75) * 4, -2, 2)
		}
	}
}

const sensitivity = 10
fn new_pic() ![]rl.Vector2 {
	w := rl.get_monitor_width(rl.get_current_monitor()) * 5 / 6
	h := rl.get_monitor_height(rl.get_current_monitor()) * 5 / 6
	mut pos := rl.get_mouse_position()
	mut points := [pos]
	for !rl.window_should_close() {
		if rl.is_key_released(rl.key_f) {
			return points.map(fn [w, h] (it rl.Vector2) rl.Vector2 {
				return rl.Vector2{
					x: (it.x - w/2) / c_mul
					y: (it.y - h/2) / c_mul
				}
			})
		}
		if vec_len(vec_sum(vec_mul_scal(pos,-1),rl.get_mouse_position())) > sensitivity {
			pos = rl.get_mouse_position()
			points << pos
		}
		//
		rl.begin_drawing()
		{
			rl.clear_background(rl.black)
			mut point := points.first()
			for p in points[..points.len-1]{
				rl.draw_line(int(point.x),int(point.y),int(p.x),int(p.y),rl.white)
				point = p
			}
			rl.draw_circle(rl.get_mouse_x(),rl.get_mouse_y(),sensitivity,rl.color_alpha(rl.white,0.3))
		}
		rl.end_drawing()
	}
	return error('exit')
}