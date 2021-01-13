# ruby-libssw

![test](https://github.com/kojix2/ruby-libssw/workflows/CI/badge.svg)
[![Gem Version](https://badge.fury.io/rb/libssw.svg)](https://badge.fury.io/rb/libssw)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/libssw)

:checkered_flag: [libssw](https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library) - fast SIMD parallelized implementation of the Smith-Waterman algorithm - for Ruby

:construction: Under development.

## Installation

```ssh
gem install libssw
```

Set the environment variable `LIBSSWDIR` to specify the location of the shared library.
For example, on Ubuntu, you can use libssw in the following way.

```
sudo apt install libssw-dev
export LIBSSWDIR=/usr/lib/x86_64-linux-gnu/ # libssw.so
```

### Installing from source

When installing from source code using the following steps, the shared library `libssw.so` will be packed in the Ruby gem. In this case, the environment variable LIBSSWDIR is not required. (Only tested on Ubuntu)

```sh
git clone --recurse-submodules https://github.com/kojix2/ruby-libssw
bundle exec rake libssw:compile
bundle exec rake install
```

## Usage

```ruby
require 'libssw'

ref = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
read = [0, 1, 2, 3, 3]
mat = [2, -2, -2, -2,  0,
      -2,  2, -2, -2,  0,
      -2, -2,  2, -2,  0,
      -2, -2, -2,  2,  0,
       0,  0,  0,  0,  0]
profile = LibSSW.ssw_init(read, mat)
align   = LibSSW.ssw_align(profile, ref, 3, 1, 1, 0, 0, 15)
p align.to_h
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
