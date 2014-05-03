# Jekyll GalleryTag
# 
# Automatically creates thumbnails for a directory of images.
# Adds a "gallery" Liquid tag
# 
# Authors: Matt Harzewski, Oleksii Schastlyvyi, Markus Konrad
# Copyright: Copyright 2013 Matt Harzewski
# License: GPLv2 or later
# Version: 1.3.0


module Jekyll


	class GalleryTag < Liquid::Block


	 	def initialize(tag_name, markup, tokens)
			super
			@gallery_name, @max_img_num = markup.split
			@gallery_name.strip!
			if @max_img_num
			    @max_img_num.strip!
			    @max_img_num = @max_img_num.to_i
			end
		end


		def render(context)

			@config = context.registers[:site].config['gallerytag']
			columns = (@config['columns'] != nil) ? @config['columns'] : 4
			width = (@config['thumb_width'] != nil) ? @config['thumb_width'] : 150
			height = (@config['thumb_height'] != nil) ? @config['thumb_height'] : 150
			custom_attribute_name = (@config['custom_attribute_name'] != nil) ? @config['custom_attribute_name'] : 'rel'
			images = gallery_images(context)

			images_html = ""
			images_html << "<ul class=\"gallery-list\">\n" if columns <= 0 
			images.each_with_index do |image, key|
                if columns > 0
                    images_html << gen_images_column_html(image, width, height, custom_attribute_name, key, columns)
                else
                    images_html << gen_images_list_html(image, width, height, custom_attribute_name)
                end
			end
            images_html << "</ul>\n" if columns <= 0
			images_html << "<br style=\"clear: both;\">" if columns > 0 && images.count % columns != 0
			gallery_html = "<div class=\"gallery\">\n\n#{images_html}\n\n</div>\n"

			return gallery_html
		end
		
		def gen_images_column_html(image, width, height, custom_attribute_name, key, columns)
			html =  "<dl class=\"gallery-item\">\n"
			html << "<dt class=\"gallery-icon\">\n"
			html << gen_img_html(image['url'], image['thumbnail'], width, height, image['caption'], custom_attribute_name)
			html << "</dt>\n"
			html << "<dd class=\"gallery-caption\">#{image['caption']}</dd>"
			html << "</dl>\n\n"
			html << "<br style=\"clear: both;\">" if (key + 1) % columns == 0
			
			return html
		end
		
		def gen_images_list_html(image, width, height, custom_attribute_name)
		    html =  "\t<li>\n"
		    html << "\t\t" << gen_img_html(image['url'], image['thumbnail'], width, height, image['caption'], custom_attribute_name) << "\n"
		    html << "\t\t<span>#{image['caption']}</span>\n"
		    html << "\t</li>\n"
		    
		    return html
		end
		

        def gen_img_html(full_img_url, thumb_img_url, w, h, caption, custom_attribute_name)
            img_html =  "<a class=\"gallery-link\" href=\"#{full_img_url}\" title=\"#{caption}\" #{custom_attribute_name}=\"#{@gallery_name}\">"
            img_html << "<img src=\"#{thumb_img_url}\" class=\"thumbnail\" width=\"#{w}\" height=\"#{h}\" />"
            img_html << "</a>"
            
            return img_html
        end

		def gallery_images(context)
			input_data = block_contents(context)
			source_dir = @config['source_dir'] != nil ? @config['source_dir'].sub(/^\//, '') : (@config['url'] != nil ? @config['url'].sub(/^\//, '') : "images/thumbs");
			gallery_data = []
			input_data.each do |item|
			    full_item_path = File.join(source_dir, item[0])
			    item_ok = File.readable?(full_item_path)
			    if File.directory?(full_item_path) && item_ok   # check if this item points to a directory
			        itemnum = 1
                    Dir.glob(File.join(full_item_path, "*.{png,jpg,jpeg,gif}")).each do |file|
                        file_in_gal_path = File.join(item[0], File.basename(file))
                        
                        hsh = gen_gallery_data_from_item(file_in_gal_path, source_dir, item[1], itemnum)
	   			        gallery_data.push(hsh)
	   			        
	   			        itemnum += 1
	   			        
        				break if (@max_img_num && gallery_data.length >= @max_img_num)
                    end
			    elsif item_ok
                    hsh = gen_gallery_data_from_item(item[0], source_dir, item[1], nil)
				
				    gallery_data.push(hsh)
				else
				    puts "JekyllGalleryTag: Could not read file #{full_item_path}"
				end

				break if (@max_img_num && gallery_data.length >= @max_img_num)
			end
			return gallery_data
		end

        def gen_gallery_data_from_item(item, source_dir, cap_ref, itemnum)
            cap = nil
            
            if cap_ref != nil
                cap = String.new(cap_ref)
        
                if itemnum != nil
                    cap << " (#{itemnum})"
                end
            end
        
    		hsh = {
                "url" => "/#{source_dir}/#{item}",
                "thumbnail" => GalleryThumbnail.new(item, @config), #this should be url to a generated thumbnail, eventually
                "caption" => cap
            }
            
            return hsh
        end

		def block_contents(context)
			text = @nodelist[0].strip!
			if (text == nil || text.length == 0) && @nodelist[1] != nil # check if we have a variable in the nodelist
    			text = @nodelist[1].render(context)  # render the variable
	        end
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
	 		directory = @config['destination_dir'] != nil ? @config['destination_dir'].sub(/^\//, '') : (@config['url'] != nil ? @config['url'].sub(/^\//, '') : "images/thumbs")
			"/#{directory}/#{filename}"
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
	 		@gallery_dir  = File.expand_path(@config['source_dir'] != nil ? @config['source_dir'] : (@config['dir'] != nil ? @config['dir'].sub(/^\//, '') : "images/gallery"))
	 		@gallery_dest = @config['destination_dir'] != nil ? @config['destination_dir'] : (@config['url'] != nil ? @config['url'].sub(/^\//, '') : "images/thumbs")
	 		@gallery_full_dest = File.expand_path(File.join(site.source, @gallery_dest))


            if @config['magick_lib'] == 'mini'
	 		    thumbify_mini(files_to_resize(site))
	 		else
                thumbify(files_to_resize(site))
            end
	 	end


	 	def files_to_resize(site)

	 		to_resize = []

	 		Dir.glob(File.join(@gallery_dir, "**", "*.{png,jpg,jpeg,gif}")).each do |file|
	 			if !File.basename(file).include? "-thumb"

	 				# generate thumbnails in same folder as original files
	 				file_directory = File.dirname(file).sub(@gallery_dir, '');
	 				name = File.join(file_directory, File.basename(file).sub(File.extname(file), "-thumb#{File.extname(file)}"))
	 				thumbname = File.join(@gallery_full_dest, name)

	                # Keep the thumb files from being cleaned by Jekyll
	                site.static_files << Jekyll::GalleryFile.new(site, site.source, @gallery_dest + "/" + file_directory, File.basename(name))

	 				if !File.exists?(thumbname)
	 					to_resize.push({ "file" => file, "thumbname" => thumbname })
	 				end
	 			end
	 		end

	 		return to_resize

	 	end
	 	
	 	def thumbify(items)
	 	    require "RMagick"
	 	
	 		if items.count > 0
		 		items.each do |item|

		 			img = Magick::Image.read(item['file']).first
		 			thumb = img.resize_to_fill!(@config['thumb_width'], @config['thumb_height'])

		 			# create directory for thumbnail if it not exists
		 			if !Dir.exists?(File.dirname(item['thumbname']))
		 				FileUtils.mkdir_p File.dirname(item['thumbname'])
		 			end

		 			thumb.write(item['thumbname'])
		 			thumb.destroy!
		 		end
	 		end
	 	end

	 	def thumbify_mini(items)
	 	    require 'mini_magick'
	 	
	 		if items.count > 0
		 		items.each do |item|		 			
		 			thumb_w = @config['thumb_width']
		 			thumb_h = @config['thumb_height']
		 			
		 			img = MiniMagick::Image.open(item['file'])
		 			
		 			puts "JekyllGalleryTag: Generating #{item['thumbname']} from #{item['file']} (size #{thumb_w}x#{thumb_h})"
		 			
                    # Scale and crop via Mini_Magick - borrowed from https://github.com/robwierzbowski/jekyll-image-tag
                    img.combine_options do |i|
                      i.resize "#{thumb_w}x#{thumb_h}^"
                      i.gravity "center"
                      i.crop "#{thumb_w}x#{thumb_h}+0+0"
                    end

		 			# create directory for thumbnail if it not exists
		 			if !Dir.exists?(File.dirname(item['thumbname']))
		 				FileUtils.mkdir_p File.dirname(item['thumbname'])
		 			end

                    img.write item['thumbname']
		 		end
	 		end
	 	end


	end



end



Liquid::Template.register_tag('gallery', Jekyll::GalleryTag)
