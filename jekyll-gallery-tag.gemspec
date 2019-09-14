Gem::Specification.new do |s|
    s.name = "jekyll-gallery-tag"
    s.license = "GPL-2.0-or-later"
    s.version = "1.2.1"
    s.summary = "New Jekyll tag to create a gallery"
    s.description = "Jekyll plugin to generate thumbnails from a directory of images and display them with a Liquid tag"
    s.author = "Matt Harzewski"
    s.files = Dir['lib/*']

    s.add_development_dependency "bundler", "~> 2.0.2"
end
