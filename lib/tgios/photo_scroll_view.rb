module Tgios
  class PhotoScrollView < UIScrollView
    attr_accessor :image, :max_scale, :content_type, :min_content_type

    def init
      if super
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
        self.backgroundColor = :clear.uicolor
        @max_scale = 4.0
        @content_type = @min_content_type = :horizontal # :horizontal, :vertical, :fit, :fill

        @image_view = PlasticCup::Base.style(UIImageView.new, contentMode: UIViewContentModeScaleAspectFit)
        self.addSubview(@image_view)
      end
      self
    end

    def initWithFrame(frame, image: image)
      init
      self.frame = frame
      self.image = image

      self
    end

    def image=(image)
      super
      if image.is_a?(UIImage)

        fit_scale = get_scale(@content_type, image)

        image_view_size = CGSizeMake(image.size.width * fit_scale, image.size.height * fit_scale)

        #reset content
        self.contentOffset = CGPointZero
        self.zoomScale = 1.0

        @image_view.image= image
        @image_view.frame = [[0,0], [image_view_size.width, image_view_size.height]]

        #center image
        self.contentOffset = CGPointMake((image_view_size.width - frame.size.width)/2.0, (image_view_size.height - frame.size.height)/2.0)

        self.zoomScale = 0.995
        self.maximumZoomScale = @max_scale / fit_scale
        self.minimumZoomScale = get_scale(@min_content_type, image) / fit_scale

      end
    end

    def layoutSubviews
      super
      unless @image_view.nil?
        bsize = self.bounds.size
        center_frame = @image_view.frame

        center_frame.origin.x = center_frame.size.width < bsize.width ? (bsize.width - center_frame.size.width) / 2.0 : 0
        center_frame.origin.y = center_frame.size.height < bsize.height ? (bsize.height - center_frame.size.height) / 2.0 : 0

        @image_view.frame = center_frame
        @image_view.contentScaleFactor = 1.0

      end

    end

    def get_scale(type, image)
      horizontal_scale = frame.size.width / image.size.width
      vertical_scale = frame.size.height / image.size.height
      case type
        when :horizontal
          horizontal_scale
        when :vertical
          vertical_scale
        when :fit
          [horizontal_scale, vertical_scale].min
        when :fill
          [horizontal_scale, vertical_scale].max
        else
          horizontal_scale
      end
    end

    def viewForZoomingInScrollView(scrollView)
      @image_view
    end

    def dealloc
      ap "dealloc #{self.class.name}"
      super
    end

  end
end