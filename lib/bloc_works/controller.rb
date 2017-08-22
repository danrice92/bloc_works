require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
    end

    def render(view, locals = {})
      klass = self.class.to_s
      klass.slice!("Controller")
      controller_dir = BlocWorks.snake_case(klass)

      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)

      self.instance_variables.each do |iv|
        locals[iv] = instance_variable_get(iv)
      end

      eruby = Erubis::Eruby.new(template)
      eruby.result(locals)
    end
  end
end
