require "bloc_works/version"
require "bloc_works/controller"
require "bloc_works/dependencies"
require "bloc_works/router"
require "bloc_works/utility"

module BlocWorks
  class Application
    def call(env)
      controller_class, action_name = controller_and_action(env)
      if env['PATH_INFO'] == '/favicon.ico'
        [404, {'Content-Type' => 'text/html'}, ["404 (that's an error). No favicon currently available."]]
      elsif controller_class == nil || controller_class == false || action_name == nil
        [404, {'Content-Type' => 'text/html'}, ["404 (that's an error). That path does not exist."]]
      elsif controller_class.method_defined?(action_name)
        controller = controller_class.new(env)
        response_body = controller.send(action_name)
        return [200, {'Content-Type' => 'text/html'}, [response_body]]
      else
        return [404, {'Content-Type' => 'text/html'}, ["404 (that's an error). That path does not exist."]]
      end
    end
  end
end
