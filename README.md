JekyllGalleryTag
================

Jekyll plugin to generate thumbnails from a directory of images and display them with a Liquid tag

Installation
--------------
1. Drop `galleries.rb` into your Jekyll site's `_plugins` folder.
2. Add the following to your `_config.yml` and customize to taste.

``` yaml
gallerytag:
    dir: images/galleries
    url: /images/galleries
    thumb_width: 150
    thumb_height: 150
    columns: 4
```

* `dir` — The path (relative to your top Jekyll directory) to the folder containing your gallery images.
* `url` — The URL to your gallery folder.
* `thumb_width` — The width, in pixels, you want your thumbnails to have
* `thumb_height` — The height, in pixels, you want your thumbnails to have
* `columns` — How many columns galleries should display when the Liquid tag is used.


Usage
-------

Jekyll will automatically generate (during builds) thumbnails for any images in the folder specified in `_config.yml`. To display them in a post, you would use a Liquid tag set up like this:

```
{% gallery galleryname %}
myfirstimage.jpg:: A caption!
myseconfimage.png:: Another caption
mythirdimage.jpg
myfourthimage.png
myfifthimage.jpg
{% endgallery %}
```

Jekyll will output some HTML that is (intentionally) similar to what WordPress does for galleries in posts, making it relatively simple to tweak your CSS. It will also add `rel` attributes to the links, which contain the "galleryname" text as shown in the above example. This makes is easy to integrate a lightbox script like [FancyBox.](http://fancyapps.com/fancybox/)