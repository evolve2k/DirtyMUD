requires = %w(room player server item mob)
requires.each do |r|
  require File.expand_path("../dirtymud/#{r}", __FILE__)
end
