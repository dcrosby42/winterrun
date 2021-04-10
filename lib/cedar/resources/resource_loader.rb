require "json"
require "yaml"

class Cedar::Resources::ResourceLoader
  def initialize(dir: "res")
    @resource_dir = dir
  end

  def load_image(name, tileable: true, retro: true)
    Gosu::Image.new(get_path(name), tileable: tileable, retro: retro)
  end

  def load_file(name)
    File.read(get_path(name))
  end

  def load_data(name)
    text = load_file(name)
    case File.extname(name)
    when ".json"
      JSON.parse(text, symbolize_names: true)
    when ".yaml", ".yml"
      YAML.load(text)
    else
      text
    end
  end

  def get_path(file)
    name = "#{@resource_dir}/#{file}"
    raise "Resource file doesn't exist: #{name.inspect}" if !File.exists?(name)
    name
  end
end
