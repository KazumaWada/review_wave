require 'rtesseract'
require 'mini_magick'

class HandwritingRecognizer
  def self.preprocess_image(input_path, output_path)
    Rails.logger.debug "Starting image preprocessing..."
    image = MiniMagick::Image.open(input_path)
  
    # サイズ縮小
    image.resize '1200x1200>'
    image.format('png')
    image.write(output_path)
  
    # ノイズ除去
    image = MiniMagick::Image.open(output_path)
    image.morphology 'Erode', 'Diamond'
  
    # 傾き補正
    image.deskew '40%'
    image.morphology 'Close', 'Octagon'
  
    # 最終出力
    image.write(output_path)
    Rails.logger.debug "Image preprocessing completed. Output: #{output_path}"
    output_path
  end
  

end



