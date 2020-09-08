# double_take

## 0.2.1
- Added rubocop and fixed violations
- Added running test suite against bundler version 1.17.x to 2.1.x in CI
- Fixed bundler method deprecation warning

## 0.2.0
- Remove registering command and hooks at file loadtime
- Create method for loading and registering command and hooks and add to `plugins.rb`
- Bundle "next" lockfile on plugin install, removing the need to `bundle` twice

## 0.1.2
- Fix helper method

## 0.1.1
- Add necessary `plugins.rb`

## 0.1.0
- Initial version
