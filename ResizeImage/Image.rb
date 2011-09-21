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
    @image = img
  end
  
  def width
    @image.size.width
  end
  
  def height
    @image.size.height
  end

  def resize(width, height)
    newSize = NSSize.new
    newSize.width  = width
    newSize.height = height
    newImage = NSImage.alloc.initWithSize(newSize)
    
    oldSize = @image.size
    sourceRect = NSMakeRect(0, 0, oldSize.width, oldSize.height)
    destRect = NSMakeRect(0, 0, newSize.width, newSize.height)

    newImage.lockFocus
    @image.drawInRect(destRect, fromRect:sourceRect,
                      operation:NSCompositeCopy, fraction:1.0)
    newImage.unlockFocus
    
    @image = newImage
  end
  
  def save(path)
    format = IMAGE_TYPES[File.extname(path).downcase]
    return if format.nil?
    
    bitmapRep = NSBitmapImageRep.imageRepWithData(@image.TIFFRepresentation)
    blob = bitmapRep.representationUsingType(format, properties:nil)
    blob.writeToFile(path, atomically:false)
  end
end

