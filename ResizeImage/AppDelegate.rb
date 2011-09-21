#
#  AppDelegate.rb
#  ResizeImage
#
#  Created by Watson on 11/09/20.
#
require "fileutils"

class AppDelegate
  attr_accessor :window
  attr_accessor :textWidth, :textHeight
  attr_accessor :checkAspect
  attr_accessor :tableView
  attr_accessor :arrayController

  FILE_TYPES = ["jpg", "jpeg", "png", "gif"]

  def awakeFromNib
    @defaults = NSUserDefaults.standardUserDefaults
    @alert = NSAlert.alloc.init
    @alert.addButtonWithTitle("OK")

    tableView.registerForDraggedTypes([NSFilenamesPboardType])
  end

  def tableView(aView, writeRowsWithIndexes:rowIndexes, toPasteboard:pboard)
    return true
  end

  def tableView(aView, validateDrop:info, proposedRow:row, proposedDropOperation:op)
    return NSDragOperationEvery
  end

  def tableView(aView, acceptDrop:info, row:droppedRow, dropOperation:op)
    pbd = info.draggingPasteboard
    files = pbd.propertyListForType(NSFilenamesPboardType)

    files.each do |file|
      addItem(file)
    end
    return true
  end

  def application(theApplication,
                  openFile:path)
    addItem(path)
    return true
  end

  def open(sender)
    panel = NSOpenPanel.openPanel
    panel.setCanChooseFiles(true)
    panel.setAllowsMultipleSelection(true)
    panel.setCanChooseDirectories(false)
    result = panel.runModalForDirectory(NSHomeDirectory(),
                                        file:nil,
                                        types:FILE_TYPES)
    if(result == NSOKButton)
      panel.filenames.each do |path|
        addItem(path)
      end
    end
  end

  def can_open?(path)
    FILE_TYPES.each do |ext|
      if File.extname(path).downcase == "." + ext
        return true
      end
    end
    return false
  end

  def addItem(file)
    if can_open?(file)
      image = NSImage.alloc.initWithContentsOfFile(file)
      arrayController.addObject({'image'   => image,
                                'filename' => File.basename(file)})
    end
  end

  def alert(msg, info = "")
    @alert.setMessageText(msg)
    @alert.runModal
  end

  # actions
  def deleteItems(sender)
    indexes = tableView.selectedRowIndexes
    arrayController.removeObjectsAtArrangedObjectIndexes(indexes)
  end

  def setAspect(sender)
    case checkAspect.state
    when NSOnState
      textHeight.setEditable(false)
      textHeight.setBackgroundColor(NSColor.lightGrayColor)
    when NSOffState
      textHeight.setEditable(true)
      textHeight.setBackgroundColor(NSColor.whiteColor)
    end
  end

  def resize(sender)
    width = textWidth.stringValue
    height = textHeight.stringValue

    if !is_valid_pixel?(width)
      alert("invalid width")
      return
    end

    if checkAspect.state == NSOffState
      if !is_valid_pixel?(height)
        alert("invalid height")
        return
      end
    end

    output_dir = @defaults.stringForKey("output_dir")
    if output_dir.nil? || output_dir.length == 0
      output_dir = "~/Desktop/ResizeImage/"
    end
    output_dir = File.expand_path(output_dir)
    FileUtils.mkdir_p(output_dir)

    ary = arrayController.arrangedObjects
    ary.each do |item|
      image = Image.new(item['image'])

      if checkAspect.state == NSOnState
        rate =  width.to_f / image.width
        height = image.height * rate
      end

      image.resize(width, height)
      image.save("#{output_dir}/#{item['filename']}")
      GC.start
    end
  end

  def is_valid_pixel?(str)
    return false if str.length == 0
    return false if str !~ /^\d+$/
    return false if str.to_i == 0

    return true
  end
end

