# Als

Ableton live set parser, allows you to read information about your ableton set in ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'als'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install als

## Usage

```ruby
require 'als'

als = ALS::Set.load('path/to/your/set.als')
puts als.tempo
puts midi_tracks.length
puts audio_tracks.length
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/willm/als.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
