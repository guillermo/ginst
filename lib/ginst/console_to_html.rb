class Ginst::ConsoleToHtml

  def self.convert(input_text)
    output = convert_returns(input_text)
    output = convert_lines(output)
    output = convert_colors(output)
  end

  def self.convert_returns(input)
    input.split("\n").map{ |l|
      if l.include? "\r"
       l.split("\r").last
      else
       l
      end
    }.join("\n")
  end

  def self.convert_lines(input)
    input.gsub("\n",'<br/>')
  end

  def self.convert_colors(input)
    open = false
    input.split("\e").map{ |e|
      if e =~ /^\[(\d*)m(.*)/m
        color = $1.to_i
        open_tag_for_color(color)+$2+close_tag_for_color(color)
      else
        e
      end
    }.join
  end

  def self.open_tag_for_color(color)
    color = colors[color] or return ''
    "<span style=\"color: #{color};\">"
  end

  def self.close_tag_for_color(color)
    color = colors[color] or return ''
    "</span>"
  end

  def self.colors
    {
      30 => 'black',
      31 => 'red', 
      32 => 'green',
      33 => 'brown',
      34 => 'blue', 
      35 => 'magenta',
      36 => 'cyan', 
      37 => 'gray'
    }  
  end

end
