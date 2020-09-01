# frozen_string_literal: true

module GemfileHelper
  def with_next_lockfile
    dir = Dir.mktmpdir
    file = Tempfile.new("Gemfile_next.lock", dir).tap do |f|
      f.write("")
    end
    yield Pathname(file)
  ensure
    FileUtils.remove_dir(dir, true)
  end
end
