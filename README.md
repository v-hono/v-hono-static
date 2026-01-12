# hono.static

Static file serving for v-hono-core framework.

## Features

- Serve static files from local filesystem
- File caching support
- MIME type detection
- Directory indexing (optional)

## Installation

```bash
v install hono
v install hono.static
```

## Usage

```v
import hono
import hono.static

fn main() {
    mut app := hono.Hono.new()

    // Serve files from ./public directory at /static path
    app.use(static.serve_static(static.StaticOptions{
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
