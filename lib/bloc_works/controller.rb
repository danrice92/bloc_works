require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      proc { |env| self.new(env).dispatch(action, response) }
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params)
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render_partial(partial)
      @partial = partial
    end

    def render(*args)
      response(create_response_array(*args))
    end

    def redirect_to(*args)
      if args.first == :google
        search_url = construct_google_search(args.last)
        return response([], 302, {'Location' => search_url})
      end

      klass = self.class.to_s
      klass.slice!("Controller")
      directory = BlocWorks.snake_case(klass)
      action = args[0]

      text = self.send(action)
      @response = nil
      return response([text].flatten, 302, {'Location' => "/#{directory}/#{action}"})
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(*args)
      locals = {}
      if args.length == 0
        view = self.params["action"]
      elsif args[0].class == Symbol
        view = args.shift
        for i in 0..args.length - 1
          args.each do |arg|
            locals[arg.keys[i]] = arg.values[i]
          end
        end
      else
        view = self.params["action"]
        for i in 0..args.length - 1
          args.each do |arg|
            locals[arg.keys[i]] = arg.values[i]
          end
        end
      end
      klass = self.class.to_s
      klass.slice!("Controller")
      controller_dir = BlocWorks.snake_case(klass)
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      if @partial != nil
        partialname = File.join("app", "views", controller_dir, "#{@partial}.html.erb")
        template = File.read(partialname) + File.read(filename)
      else
        template = File.read(filename)
      end

      self.instance_variables.each do |iv|
        locals[iv] = instance_variable_get(iv)
      end

      eruby = Erubis::Eruby.new(template)
      eruby.result(locals)
    end

    def construct_google_search(search_params)
      search_string = "http://www.google.com/search?q="
      search_params.gsub!(' ', '+')
      search_params.gsub!(/(['"])/, '')
      return search_string + search_params
    end
  end
end
