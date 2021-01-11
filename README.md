# ruby-libssw

[libssw](https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library) - fast SIMD parallelized implementation of the Smith-Waterman algorithm - for Ruby

## Installation

```ssh
gem install libssw
```

Set the environment variable `LIBSSWDIR` to specify the location of the shared library.

### ubuntu

```
sudo apt install libssw-dev
export LIBSSWDIR=/usr/lib/x86_64-linux-gnu/ # libssw.so
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
