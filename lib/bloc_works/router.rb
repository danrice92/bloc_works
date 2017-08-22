module BlocWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
      if controller != "Controller"
        [Object.const_get(controller), action]
      else
        return nil
      end
    end
  end
end
