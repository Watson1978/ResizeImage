#
#  Image.rb
#  ResizeImage
#
#  Created by Watson on 11/09/20.
#
class Image
  IMAGE_TYPES = {
    ".png" => NSPNGFileType,
    ".gif" => NSGIFFileType,
    ".jpg" => NSJPEGFileType,
    ".jpeg" => NSJPEGFileType,
  }

  def initialize(img)
    bitmapRep = NSBitmapImageRep.imageRepWithData(img.TIFFRepresentation);
    @ciimage = CIImage.imageWithCGImage(bitmapRep.CGImage)
  end
  
  def width
    @ciimage.extent.size.width
  end
  
  def height
    @ciimage.extent.size.height
  end

  def resize(width, height)
    orig_w = @ciimage.extent.size.width
    orig_h = @ciimage.extent.size.height
    width_ratio = width.to_f / orig_w.to_f
    height_ratio = height.to_f / orig_h.to_f
    
    scale = height_ratio
    aspect = width_ratio / height_ratio

    filter = CIFilter.filterWithName('CILanczosScaleTransform')
    filter.setDefaults
    filter.setValue(@ciimage, forKey:'inputImage')
    filter.setValue(scale, forKey:'inputScale')
    filter.setValue(aspect, forKey:'inputAspectRatio')
    @ciimage = filter.valueForKey('outputImage')
  end
  
  def save(path)
    format = IMAGE_TYPES[File.extname(path).downcase]
    return if format.nil?
    
    bitmapRep = NSBitmapImageRep.alloc.initWithCIImage(@ciimage)
    blob = bitmapRep.representationUsingType(format, properties:nil)
    blob.writeToFile(path, atomically:true)
  end
end

