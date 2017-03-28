module DevicesHelper
  def get_device_directory(device_id)
    if Dir.exist?(file_path = "/home/redroid/video_saves/#{device_id}")
      files = Dir.entries(file_path).select { |e| /\A(\w|\d)+[_]([-:\w\d])+(.flv)\z/ =~ e  }
      result = []
      files.each do |file|
        result << { name: file, 
                    size: '%.2f' % (File.size("#{file_path}/#{file}").to_f / 2**20 ) }
      end
      result
    else
      []
    end
  end
end
