# ask-linear

linear service context for the ask-rb ecosystem.

Provides:
- `Ask::linear.client` — authenticated API client
- `Ask::linear.context` — context metadata for the system prompt
- `Ask::linear::Errors` — structured error knowledge for agents

## Installation

```ruby
gem "ask-linear"
```

## Usage

```ruby
client = Ask::linear.client
# ... use the client according to its API
```

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
