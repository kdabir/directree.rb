directree.rb
============

A simple DSL to create Directory Tree and Files with content.

A [Directree](https://github.com/kdabir/directree) implementation powered by ruby.

[![Build Status](https://travis-ci.org/kdabir/directree.rb.svg?branch=master)](https://travis-ci.org/kdabir/directree.rb)

## Installation

Add this line to your application's Gemfile:

    gem 'directree'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install directree

## Usage

```ruby
require 'directree'

Directree.create("mygem") {
    dir("lib")
    dir("spec") {
        file("spec_helper.rb") {
            <<-EOF
            RSpec.configure do |config|
                config.color_enabled = true
            end
            EOF
        }
    }
    file("README.txt") {
        "This is README of mygem"
    }
}
```

That's it, Seriously !!

Verify it:

    $ tree mygem
    
    mygem
    |-- README.txt
    |-- lib
    `-- spec
        `-- spec_helper.rb

    2 directories, 2 files

And check the file content:

    $ cat mygem/spec/spec_helper.rb
    
            RSpec.configure do |config|
                config.color_enabled = true
            end

See the [specs](spec) for more details usage

## Contributing

1. Fork it ( https://github.com/kdabir/directree.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
