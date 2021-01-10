# ruby-libssw

[libssw](https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library) - fast SIMD parallelized implementation of the Smith-Waterman algorithm - for Ruby

## Installation

```ssh
gem install libssw
```

## Usage

```ruby
require 'libssw'
SSW = LibSSW
```

## Development

```sh
git clone --recurse-submodules https://github.com/kojix2/ruby-libssw
bundle exec rake libssw:compile
bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/ruby-libssw.

## License

* [MIT License](https://opensource.org/licenses/MIT).
