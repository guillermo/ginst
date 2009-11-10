
class Ginst::Configuration
  @adapter  = 'mysql'
  @database = 'ginst'
  @username = 'root'
  @password = nil
  @host     = 'localhost'
  class << self
    attr_accessor :adapter, :database, :username, :password, :host
  end

end
