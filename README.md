JekyllGalleryTag (enhanced version)
===================================

Jekyll plugin to generate thumbnails from a directory of images and display them with a Liquid tag.

This fork is based on [luckyalvy's fork](https://github.com/luckyalvy/JekyllGalleryTag) of [redwallhp's JekyllGalleryTag](https://github.com/redwallhp/JekyllGalleryTag).

Enhanced version features
-------------------------

* uses [minimagick](https://github.com/minimagick/minimagick) instead of [RMagick](https://github.com/rmagick/rmagick) which eats up less memory
* generate galleries by pointing to folders of images instead of pointing to each single file (see "Usage" below)
* includes the enhancements of [luckyalvy's fork](https://github.com/luckyalvy/JekyllGalleryTag)

Installation
------------
0. Install [ImageMagick](http://www.imagemagick.org/) and the [mini_magick gem](https://github.com/minimagick/minimagick).
1. Drop `galleries.rb` into your Jekyll site's `_plugins` folder.
2. Add the following to your `_config.yml` and customize to taste.

``` yaml
gallerytag:
    source_dir: images/gallery
    destination_dir: images/thumbs
    thumb_width: 150
    thumb_height: 150
    columns: 4
    custom_attribute_name: data-lightbox
```

* `source_dir` — The path (relative to your top Jekyll directory, where is `_config.yml` stored) to the folder containing your gallery images. Default value _images/gallery_
* `destination_dir` — The path to you thumbnails (relative to your top Jeyll directory). Recommend to use a different path in relation to `source_dir` to have possibility easily remove all thumbnails in one time. Default value: _images/thumbs_
* `thumb_width` — The width, in pixels, you want your thumbnails to have. Default value: _150_.
* `thumb_height` — The height, in pixels, you want your thumbnails to have. Default value: _150_.
* `columns` — How many columns galleries should display when the Liquid tag is used. Default value: _4_.
* `custom_attribute_name` - add into "a" tag custom attribute with specified name which contain the "galleryname" (userful for lightbox plugins, when need to tag). By default custom attribute name is _rel_ for backward capability with old version of JekyllGalleryTag.

Usage
-------

Jekyll will automatically generate (during builds) thumbnails for any images in the folder specified in `source_dir` variable of `_config.yml` and put them into `destination_dir`. To display specific images in a post, you would use a Liquid tag set up like this:

```
{% gallery galleryname %}
subfolder/myfirstimage.jpg:: A caption!
subfolder/myseconfimage.png:: Another caption
subfolder/mythirdimage.jpg
subfolder/myfourthimage.png
subfolder/myfifthimage.jpg
{% endgallery %}
```

Or you specify only the folder and the gallery will be generated with all images that are contained in this folder:

```
{% gallery galleryname %}
subfolder/:: A caption for all images in the folder
subfolder2/
{% endgallery %}
```

You can also mix both!

`subfolder/` is a directory with images in you `source_dir`. 

Jekyll will output some HTML that is (intentionally) similar to what WordPress does for galleries in posts, making it relatively simple to tweak your CSS. It will also add custom attribute (default - `rel`) to the links, which contain the "galleryname" text as shown in the above example. This makes is easy to integrate a lightbox script like [FancyBox](http://fancyapps.com/fancybox/) or [Lightbox2](http://lokeshdhakar.com/projects/lightbox2/).

You can see it in action on my personal blog, [here.](http://matt.harzewski.com/2012/03/13/winterspyre-a-minecraft-creation/)