# Jekyll GalleryTag
# 
# Automatically creates thumbnails for a directory of images.
# Adds a "gallery" Liquid tag
# 
# Author: Matt Harzewski
# Copyright: Copyright 2013 Matt Harzewski
# License: GPLv2 or later
# Version: 1.1.0


require "RMagick"

module Jekyll


	class GalleryTag < Liquid::Block


	 	def initialize(tag_name, markup, tokens)
			super
			@gallery_name = markup
		end


		def render(context)

			@config = context.registers[:site].config['gallerytag']
			columns = (@config['columns'] != nil) ? @config['columns'] : 4
			images = gallery_images

			images_html = ""
			images.each_with_index do |image, key|
				images_html << "<dl class=\"gallery-item\">\n"
				images_html << "<dt class=\"gallery-icon\">\n"
				images_html << "<a class=\"gallery-link\" rel=\"#{@gallery_name}\" href=\"#{image['url']}\" title=\"#{image['caption']}\">"
				images_html << "<img src=\"#{image['thumbnail']}\" class=\"thumbnail\" width=\"150\" height=\"150\" />\n"
				images_html << "</a>\n"
				images_html << "</dt>\n"
				images_html << "<dd class=\"gallery-caption\">#{image['caption']}</dd>"
				images_html << "</dl>\n\n"
				images_html << "<br style=\"clear: both;\">" if (key + 1) % columns == 0
			end
			images_html << "<br style=\"clear: both;\">" if images.count % 4 != 0
			gallery_html = "<div class=\"gallery\">\n\n#{images_html}\n\n</div>\n"

			return gallery_html

		end


		def gallery_images
			input_data = block_contents
			gallery_data = []
			input_data.each do |item|
				hsh = {
					"url" => "#{@config['url']}/#{item[0]}",
					"thumbnail" => GalleryThumbnail.new(item[0], @config), #this should be url to a generated thumbnail, eventually
					"caption" => item[1]
				}
				gallery_data.push(hsh)
			end
			return gallery_data
		end


		def block_contents
			text = @nodelist[0]
			lines = text.split(/\n/).map {|x| x.strip }.reject {|x| x.empty? }
			lines = lines.map { |line|
				line.split(/\s*::\s*/).map(&:strip)
			}
			return lines
		end


	end



	class GalleryThumbnail


	 	def initialize(image_filename, config)
	 		@img_filename = image_filename
	 		@config = config
	 	end


	 	def to_s
	 		get_url
	 	end


	 	def get_url
	 		filename = File.path(@img_filename).sub(File.extname(@img_filename), "-thumb#{File.extname(@img_filename)}")
	 		"#{@config['url']}/#{filename}"
	 	end


	end


	# This part is copied from https://github.com/kinnetica/jekyll-plugins
	# Without it, generation does fail. --dmytro
	# Recover from strange exception when starting server without --auto
	class GalleryFile < StaticFile
		def write(dest)
			begin
				super(dest)
			rescue
			end
			true
		end
	end



	class ThumbGenerator < Generator


	 	def generate(site)

	 		@config = site.config['gallerytag']
	 		@gallery_dir  = File.expand_path(@config['dir'])
	 		@gallery_dest = File.expand_path(File.join(site.dest, @config['dir']))

	 		thumbify(files_to_resize(site))

	 	end


	 	def files_to_resize(site)

	 		to_resize = []

	 		Dir.glob(File.join(@gallery_dir, "**", "*.{png,jpg,jpeg,gif}")).each do |file|
	 			if !File.basename(file).include? "-thumb"
	 				name = File.basename(file).sub(File.extname(file), "-thumb#{File.extname(file)}")
	 				thumbname = File.join(@gallery_dest, name)
	                # Keep the thumb files from being cleaned by Jekyll
	                site.static_files << Jekyll::GalleryFile.new(site, site.dest, @config['dir'], name )
	 				if !File.exists?(thumbname)
	 					to_resize.push({ "file" => file, "thumbname" => thumbname })
	 				end
	 			end
	 		end

	 		return to_resize

	 	end


	 	def thumbify(items)
	 		if items.count > 0
		 		items.each do |item|
		 			img = Magick::Image.read(item['file']).first
		 			thumb = img.resize_to_fill!(@config['thumb_width'], @config['thumb_height'])
		 			thumb.write(item['thumbname'])
		 			thumb.destroy!
		 		end
	 		end
	 	end


	end



end



Liquid::Template.register_tag('gallery', Jekyll::GalleryTag)
