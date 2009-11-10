module TasksHelper

  def show_elapsed(seconds)
    return nil unless seconds.kind_of? Integer
    case
    when seconds < 60
      "#{seconds} seconds"
    else
      "%d:%02d minutes" % [seconds/60, seconds % 60]
    end
  end
end
