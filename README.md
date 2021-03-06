# DoubleTake :eyes: :eyes:

DoubleTake is a [bundler plugin](https://bundler.io/v2.0/guides/bundler_plugins.html) that doubly bundles gems from multiple lockfiles for projects that are using a [dual boot strategy](https://www.youtube.com/watch?v=I-2Xy3RS1ns&t=368s).

The motivation for this tool was for instances where both sets of gems are needed and the gems are decided at boot time. For example: docker images that are built with the gem bundle in a pipeline and can't determine which gem set to use until the docker image is run. A single docker image is useful for debugging as you don't have to guess which image had which gem set.

## Installation

Add this line to your application's Gemfile:

```ruby
plugin "double_take"
```

_NOTE_: We use the `plugin` method, not `gem`. Did you do a ...double take? (I promise there won't be any more jokes)

And then execute:

    $ bundle

## Usage

The plugin is installed with `bundle install`. It will also install all gems from both `Gemfile.lock` and `Gemfile_next.lock` on the initial `bundle` and every subsequent one as well.

_NOTE_: This plugin does not generate a `Gemfile_next.lock`, keep both lockfiles in sync over gem bumps, nor does it implement any strategy for bifurcating the `Gemfile` to load different gems. For those reasons, this plugin pairs really well with [`bootboot`](https://github.com/Shopify/bootboot). For more info on dual booting I recommend reading the `README` for `bootboot`.

As mentioned in the `bootboot` plugin the `Gemfile` needs to be bifurcated with the environment variable `DEPENDENCIES_NEXT`. As of now, this library does not support custom environment variables for bifurcating.


### Clean
The `bundle clean` command is useful for removing unused gems on your system. The problem is that the default `bundle clean` only respects the gem set in `Gemfile.lock` which will remove any differing gems in `Gemfile_next.lock`. To avoid this, you can use the command:

    $ bundle double_take clean

It accepts all options that bundler's clean command does:

    $ bundle double_take clean --help
    $ bundle double_take clean --dry-run
    $ bundle double_take clean --force


### Supported Versions
This plugin is intended to be used with `bundler` versions 1.17.x to 2.1.x. The test suite is run against 1.17.x, 2.0.x, and 2.1.x in CI.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


### Testing Versions
To run the test suite against a specific version of bundler you can use the `TEST_BUNDLER_VERSION` environment variable. It supports full versions ie. `1.17.3` or abbreviated minor level versions ie. `2.0` and will choose the latest patch version. If a version is not specified the default bundler version will be used. This can all be verified with output that is printed before the spec suite runs.

Because of the backward incompatibilities between versions 1.x and 2.x you will have to run `bundle update --bundler` to properly test for 2.x versions. Please do not commit the changed `Gemfile.lock` if you are contributing code.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zoso10/double_take. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DoubleTake project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/double_take/blob/master/CODE_OF_CONDUCT.md).
