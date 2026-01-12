# meiseayoung.hono_static

Static file serving for v-hono-core framework.

## Features

- Serve static files from local filesystem
- File caching support
- MIME type detection
- Directory indexing (optional)

## Installation

```bash
v install meiseayoung.hono
v install meiseayoung.hono_static
```

## Usage

```v
import meiseayoung.hono
import meiseayoung.hono_static

fn main() {
    mut app := hono.Hono.new()

    // Serve files from ./public directory at /static path
    app.use(hono_static.serve_static(hono_static.StaticOptions{
        root: './public'
        path: '/static'
    }))

    app.listen(':3000')
}
```

## Dependencies

- `hono` - Core framework

## License

MIT
