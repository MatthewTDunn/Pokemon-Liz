
# Unlocks the image with the given ID if it has not yet been unlocked.
def pbUnlockImage(id)
  $Trainer.unlocked_images << id if !$Trainer.unlocked_images.include?(id)
end

# Locks the image with the given ID if it had been previously unlocked.
def pbLockImage(id)
  $Trainer.unlocked_images.delete(id) if $Trainer.unlocked_images.include?(id)
end

# The list of unlocked images are stored in PokeBattle_Trainer#unlocked_images
class PokeBattle_Trainer
  # Separate reader and writer for compatibility with existing save files
  attr_writer :unlocked_images
  
  # Returns all unlocked images
  def unlocked_images
    return @unlocked_images ||= []
  end
end

# Registers the item handler for the Gallery item
ItemHandlers::UseFromBag.add(:GALLERY, proc { |item|
  # If the player has unlocked at least one image
  if $Trainer.unlocked_images.size > 0
    # Show the gallery
    g = Gallery.new
    next 1
  else
    # No images unlocked yet
    Kernel.pbMessage(_INTL("You haven't found any photos yet!"))
    next 0
  end
})

# The Gallery UI
class Gallery
  # Start the UI
  def initialize
    # Fade out
    showBlk
    # Setup viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 999999
    # Fetch the list of available images
    @images = $Trainer.unlocked_images.sort
    # The image to show
    @index = 0
    # The active image sprite
    @img = Sprite.new(@viewport)
    @img.bitmap = Bitmap.new("Graphics/Gallery/img#{@images[@index].to_digits(2)}")
    # Fade in
    hideBlk
    # Main UI loop
    main
  end
  
  # Main UI loop
  def main
    loop do
      update
      # Cancel if B is triggered
      break if Input.trigger?(Input::B)
      # If C or Right is triggered, move to the next image
      if Input.trigger?(Input::C) || Input.trigger?(Input::RIGHT)
        move_right
      # If Left is triggered, move back to the previous image
      elsif Input.trigger?(Input::LEFT)
        move_left
      end
    end
    # Dispose the UI once the loop finishes
    dispose
  end
  
  # Move to the next image
  def move_right
    # Return if we're already on the last image
    return if @index == @images.size - 1
    # Increment active image counter
    @index += 1
    # Create a new local sprite for the transition
    newimg = Sprite.new(@viewport)
    newimg.bitmap = Bitmap.new("Graphics/Gallery/img#{@images[@index].to_digits(2)}")
    newimg.x = Graphics.width
    p = 0
    frames = 32
    # Transition
    for i in 1..frames
      update
      # The exponential formula used for the smooth movement
      p = [Graphics.width, -0.5 * (i - frames) ** 2 + Graphics.width].min
      @img.x = -p
      newimg.x = Graphics.width - p
    end
    # Dispose the old sprite and bitmap and replace it with the local sprite
    @img.bitmap.dispose
    @img.dispose
    @img = newimg
  end
  
  # Move to the previous image
  def move_left
    # Return if we're already on the first image
    return if @index == 0
    # Decrement active image counter
    @index -= 1
    # Create a new local sprite for the transition
    newimg = Sprite.new(@viewport)
    newimg.bitmap = Bitmap.new("Graphics/Gallery/img#{@images[@index].to_digits(2)}")
    newimg.x = -Graphics.width
    p = 0
    frames = 32
    # Transition
    for i in 1..frames
      update
      # The exponential formula used for the smooth movement
      p = [Graphics.width, -0.5 * (i - frames) ** 2 + Graphics.width].min
      @img.x = p
      newimg.x = -Graphics.width + p
    end
    # Dispose the old sprite and bitmap and replace it with the local sprite
    @img.bitmap.dispose
    @img.dispose
    @img = newimg
  end
  
  # The update method that actually makes everything work
  def update
    Graphics.update
    Input.update
  end
  
  # Disposes the UI and all its components
  def dispose
    # Fade out
    showBlk
    # Dispose the sprite and images
    @img.dispose
    @viewport.dispose
    # Fade in
    hideBlk
  end
end