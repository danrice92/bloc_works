module BlocWorks
  class Application

    # def controller_and_action(env)
    #   _, controller, action, _ = env["PATH_INFO"].split("/", 4)
    #   controller = controller.capitalize
    #   controller = "#{controller}Controller"
    #   if controller != ":controller"
    #     [Object.const_get(controller), action]
    #   else
    #     return nil
    #   end
    # end

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end

      @router.look_up_url(env["PATH_INFO"], env["REQUEST_METHOD"])
    end
  end

  class Router

    def initialize
      @rules = []
    end

    def resources(controller)
      controller = controller.to_s

      # manages POST create and GET index
      map "#{controller}", default: { "controller" => controller }

      # these manage index and new and are consistently GET requests
      map "#{controller}/index", default: { "controller" => controller, "action" => "index" }
      map "#{controller}/new", default: { "controller" => controller, "action" => "new" }

      # GET show, PUT update, and DELETE destroy all require the :id
      map "#{controller}/:id", default: { "controller" => controller }

      # if the user wants to explicitly call show, edit, update, or destroy on an ID
      map "#{controller}/:id/:action", default: { "controller" => controller, "action" => :action}
    end

    def map(url, *args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0

      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = [], []

      parts.each do |part|
        # puts part
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end

      regex = regex_parts.join("/")

      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
    end

    def look_up_url(url, request_verb)
      @rules.each do |rule|
        rule_match = rule[:regex].match(url)

        if rule_match
          options = rule[:options]
          params = options[:default].dup

          rule[:vars].each_with_index do |var, index|
            params[var] = rule_match.captures[index]
          end


          if rule[:destination] && params == {}
            params["controller"] = rule[:destination][/^[^#]+/]
            params["action"] = rule[:destination][/[^#]+$/]
          end

          if params["action"] == nil && params["id"] == nil
            if request_verb == "GET"
              params["action"] = "index"
            elsif request_verb == "POST"
              params["action"] = "create"
            else
              raise "No action could be determined."
            end
          elsif params["action"] == nil && params["id"] != nil
            if request_verb == "GET"
              params["action"] = "show"
            elsif request_verb == "PUT"
              params["action"] = "update"
            elsif request_verb == "DELETE"
              params["action"] = "destroy"
            else
              raise "No action could be determined."
            end
          end

          if rule[:destination]
            return get_destination(rule[:destination], params)
          else
            controller = params["controller"]
            action = params["action"]
            return get_destination("#{controller}##{action}", params)
          end
        end
      end
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      end

      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")

        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end
  end
end
