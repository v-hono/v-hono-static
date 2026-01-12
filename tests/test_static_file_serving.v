module main

import hono_static
import os

// 测试：默认配置
fn test_default_static_options() {
	options := hono_static.default_static_options()
	
	assert options.root == './public'
	assert options.path == '/'
	assert options.index == 'index.html'
	assert options.dotfiles == false
	assert options.etag == true
	assert options.last_modified == true
	assert options.max_age == 0
}

// 测试：Content-Type 检测
fn test_get_content_type() {
	// HTML 文件
	assert hono_static.get_content_type('index.html') == 'text/html; charset=utf-8'
	assert hono_static.get_content_type('page.htm') == 'text/html; charset=utf-8'
	
	// CSS 文件
	assert hono_static.get_content_type('style.css') == 'text/css; charset=utf-8'
	
	// JavaScript 文件
	assert hono_static.get_content_type('app.js') == 'application/javascript; charset=utf-8'
	
	// JSON 文件
	assert hono_static.get_content_type('data.json') == 'application/json; charset=utf-8'
	
	// 图片文件
	assert hono_static.get_content_type('image.png') == 'image/png'
	assert hono_static.get_content_type('photo.jpg') == 'image/jpeg'
	assert hono_static.get_content_type('photo.jpeg') == 'image/jpeg'
	assert hono_static.get_content_type('animation.gif') == 'image/gif'
	assert hono_static.get_content_type('icon.svg') == 'image/svg+xml'
	
	// 字体文件
	assert hono_static.get_content_type('font.woff') == 'font/woff'
	assert hono_static.get_content_type('font.woff2') == 'font/woff2'
	assert hono_static.get_content_type('font.ttf') == 'font/ttf'
	
	// 其他文件
	assert hono_static.get_content_type('document.pdf') == 'application/pdf'
	assert hono_static.get_content_type('text.txt') == 'text/plain; charset=utf-8'
	assert hono_static.get_content_type('unknown.xyz') == 'application/octet-stream'
}

// 测试：Content-Type 大小写不敏感
fn test_content_type_case_insensitive() {
	assert hono_static.get_content_type('INDEX.HTML') == 'text/html; charset=utf-8'
	assert hono_static.get_content_type('STYLE.CSS') == 'text/css; charset=utf-8'
	assert hono_static.get_content_type('IMAGE.PNG') == 'image/png'
}

// 测试：ETag 生成
fn test_generate_etag() {
	content1 := 'Hello, World!'
	content2 := 'Different content'
	mtime1 := i64(1234567890)
	mtime2 := i64(9876543210)
	
	// 相同内容和时间应该生成相同的 ETag
	etag1 := hono_static.generate_etag(content1, mtime1)
	etag2 := hono_static.generate_etag(content1, mtime1)
	assert etag1 == etag2
	
	// 不同内容应该生成不同的 ETag
	etag3 := hono_static.generate_etag(content2, mtime1)
	assert etag1 != etag3
	
	// 不同时间应该生成不同的 ETag
	etag4 := hono_static.generate_etag(content1, mtime2)
	assert etag1 != etag4
	
	// ETag 应该包含引号
	assert etag1.starts_with('"')
	assert etag1.ends_with('"')
}

// 测试：自定义配置
fn test_custom_static_options() {
	options := hono_static.StaticOptions{
		root: './custom_public'
		path: '/static'
		index: 'home.html'
		dotfiles: true
		etag: false
		last_modified: false
		max_age: 3600
		headers: {
			'X-Custom-Header': 'value'
		}
	}
	
	assert options.root == './custom_public'
	assert options.path == '/static'
	assert options.index == 'home.html'
	assert options.dotfiles == true
	assert options.etag == false
	assert options.last_modified == false
	assert options.max_age == 3600
	assert options.headers['X-Custom-Header'] == 'value'
}

// 测试：便捷函数 - serve_static_root
fn test_serve_static_root_convenience() {
	// 测试通过便捷函数创建中间件
	middleware := hono_static.serve_static_root('./my_public')
	assert middleware != unsafe { nil }
}

// 测试：便捷函数 - serve_static_path
fn test_serve_static_path_convenience() {
	// 测试通过便捷函数创建中间件
	middleware := hono_static.serve_static_path('/assets', './public/assets')
	assert middleware != unsafe { nil }
}

// 测试：便捷函数 - serve_static_default
fn test_serve_static_default_convenience() {
	// 测试默认中间件创建
	middleware := hono_static.serve_static_default()
	assert middleware != unsafe { nil }
}
