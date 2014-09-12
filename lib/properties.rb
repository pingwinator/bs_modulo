
class Properties
  
  def initialize lines = []
    @props = {}
    @gradle_format = false
    lines.each do |line|
      line.strip!
      # comment
      next if line[0] == ?#
      # empty
      next if line.length == 0
      key, value = line.split '=', 2
      @props[key] = value
    end
  end
  
  def get key
    @props[key]
  end

  def gradle
    @gradle_format = true
  end  
  
  def set key, value = ''
    if key.is_a? Hash
      key.each do |k, v|
        set k, v
      end
    else
      if @gradle_format
        new_key = key.dup
        new_key.gsub! '.', '_'
        @props[new_key] = value
      else 
        @props[key] = value
      end
    end
  end
  
  def dump
    buffer = []
    @props.each do |key, value|
      buffer << "%s=%s" % [key, value]
    end
    buffer.join "\n"
  end
  
  def save_to_file file
    File.open(file, 'w') do |f|
      f << dump
    end
  end
  
  def self.load_from_file file
    File.open(file, "r") do |f|
      p = self.new f.readlines
    end
  end
  
end
