module main

import hono_static
import os

// 测试：默认配置
fn test_default_config() {
	config := hono_static.default_config()
	
	// 服务器配置
	assert config.server.host == '127.0.0.1'
	assert config.server.port == 8080
	assert config.server.read_timeout == 30
	assert config.server.write_timeout == 30
	assert config.server.max_request_size == 10 * 1024 * 1024
	assert config.server.enable_cors == true
	assert config.server.enable_gzip == true
	
	// 静态文件配置
	assert config.static.enabled == true
	assert config.static.root_dir == './static'
	assert config.static.cache_max_age == 3600
	
	// 上传配置
	assert config.upload.enabled == true
	assert config.upload.upload_dir == './uploads'
	assert config.upload.max_file_size == 100 * 1024 * 1024
	
	// 缓存配置
	assert config.cache.enabled == true
	assert config.cache.max_size == 1000
	assert config.cache.default_ttl == 300
	
	// 安全配置
	assert config.security.enable_path_validation == true
	assert config.security.enable_file_type_check == true
	assert config.security.enable_xss_protection == true
	
	// 日志配置
	assert config.log.enabled == true
	assert config.log.level == 'info'
	assert config.log.output == 'console'
	
	// 环境配置
	assert config.debug == false
	assert config.env == 'development'
}

// 测试：配置验证 - 有效配置
fn test_validate_valid_config() {
	config := hono_static.default_config()
	
	hono_static.validate_config(config) or {
		assert false, 'Valid config should not fail: ${err}'
		return
	}
}

// 测试：配置验证 - 无效端口
fn test_validate_invalid_port() {
	mut config := hono_static.default_config()
	config.server.port = 0
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('端口')
		return
	}
	
	assert false, 'Should fail for invalid port'
}

// 测试：配置验证 - 端口范围
fn test_validate_port_range() {
	mut config := hono_static.default_config()
	
	// 端口 < 1
	config.server.port = 0
	hono_static.validate_config(config) or {
		assert err.msg().contains('端口')
	}
	
	// 端口 > 65535
	config.server.port = 70000
	hono_static.validate_config(config) or {
		assert err.msg().contains('端口')
		return
	}
	
	assert false, 'Should fail for out of range port'
}

// 测试：配置验证 - 无效超时
fn test_validate_invalid_timeout() {
	mut config := hono_static.default_config()
	config.server.read_timeout = 0
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('超时')
		return
	}
	
	assert false, 'Should fail for invalid timeout'
}

// 测试：配置验证 - 无效文件大小
fn test_validate_invalid_file_size() {
	mut config := hono_static.default_config()
	config.upload.max_file_size = 100  // 小于 1024
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('最大文件大小')
		return
	}
	
	assert false, 'Should fail for too small file size'
}

// 测试：配置验证 - 无效缓存大小
fn test_validate_invalid_cache_size() {
	mut config := hono_static.default_config()
	config.cache.max_size = 0
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('缓存')
		return
	}
	
	assert false, 'Should fail for invalid cache size'
}

// 测试：配置验证 - 无效日志级别
fn test_validate_invalid_log_level() {
	mut config := hono_static.default_config()
	config.log.level = 'invalid'
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('日志级别')
		return
	}
	
	assert false, 'Should fail for invalid log level'
}

// 测试：配置验证 - 无效环境
fn test_validate_invalid_environment() {
	mut config := hono_static.default_config()
	config.env = 'invalid_env'
	
	hono_static.validate_config(config) or {
		assert err.msg().contains('环境')
		return
	}
	
	assert false, 'Should fail for invalid environment'
}

// 测试：配置摘要
fn test_get_config_summary() {
	config := hono_static.default_config()
	summary := hono_static.get_config_summary(config)
	
	// 验证摘要包含关键信息
	assert summary.contains('应用配置摘要')
	assert summary.contains('127.0.0.1:8080')
	assert summary.contains('development')
	assert summary.contains('静态文件')
	assert summary.contains('文件上传')
	assert summary.contains('缓存')
	assert summary.contains('安全')
	assert summary.contains('日志')
}

// 测试：合并配置
fn test_merge_config() {
	mut base := hono_static.default_config()
	base.server.port = 8080
	base.server.host = '127.0.0.1'
	
	mut override := hono_static.default_config()
	override.server.port = 9000
	override.env = 'production'
	
	merged := hono_static.merge_config(base, override)
	
	// 被覆盖的值
	assert merged.server.port == 9000
	assert merged.env == 'production'
	
	// 未覆盖的值保持原样
	assert merged.server.host == '127.0.0.1'
}

// 测试：保存和加载配置
fn test_save_and_load_config() {
	config_path := './test_config.json'
	
	// 清理旧文件
	os.rm(config_path) or {}
	
	// 创建配置
	mut config := hono_static.default_config()
	config.server.port = 9000
	config.env = 'test'
	
	// 保存配置
	hono_static.save_config(config, config_path) or {
		assert false, 'Failed to save config: ${err}'
		return
	}
	
	// 验证文件已创建
	assert os.exists(config_path)
	
	// 加载配置
	loaded := hono_static.load_config(config_path) or {
		assert false, 'Failed to load config: ${err}'
		return
	}
	
	// 验证配置正确加载
	assert loaded.server.port == 9000
	assert loaded.env == 'test'
	
	// 清理
	os.rm(config_path) or {}
}

// 测试：加载不存在的配置文件
fn test_load_nonexistent_config() {
	config_path := './nonexistent_config.json'
	
	// 加载不存在的配置应该返回默认配置
	config := hono_static.load_config(config_path) or {
		assert false, 'Should return default config: ${err}'
		return
	}
	
	// 应该是默认配置
	assert config.server.port == 8080
	assert config.env == 'development'
}

// 测试：从环境变量加载配置
fn test_load_config_from_env() {
	// 设置环境变量
	os.setenv('HONO_HOST', '0.0.0.0', true)
	os.setenv('HONO_PORT', '9999', true)
	os.setenv('HONO_ENV', 'production', true)
	os.setenv('HONO_DEBUG', 'true', true)
	
	config := hono_static.load_config_from_env()
	
	// 验证环境变量被正确读取
	assert config.server.host == '0.0.0.0'
	assert config.server.port == 9999
	assert config.env == 'production'
	assert config.debug == true
	
	// 清理环境变量
	os.unsetenv('HONO_HOST')
	os.unsetenv('HONO_PORT')
	os.unsetenv('HONO_ENV')
	os.unsetenv('HONO_DEBUG')
}

// 测试：创建示例配置文件
fn test_create_example_config() {
	config_path := './example_config.json'
	
	// 清理旧文件
	os.rm(config_path) or {}
	
	// 创建示例配置
	hono_static.create_example_config(config_path) or {
		assert false, 'Failed to create example config: ${err}'
		return
	}
	
	// 验证文件已创建
	assert os.exists(config_path)
	
	// 清理
	os.rm(config_path) or {}
}
