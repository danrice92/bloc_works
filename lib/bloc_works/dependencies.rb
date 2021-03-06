class Object
  def self.const_missing(const)
    begin
      require BlocWorks.snake_case(const.to_s)
      Object.const_get(const)
    rescue LoadError => e
      return false
    end
  end
end
