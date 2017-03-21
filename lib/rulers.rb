require "rulers/version"
require "rulers/routing"
require 'rulers/util'
require 'rulers/dependencies'
require 'rulers/controller'

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404,
          {'Content-Type' => 'text/html'}, []]
      end

      klass, act = get_controller_and_action(env)
      controller = klass.new(env)
      text = controller.send(act)
      if !controller.get_response
        assigns={}
        controller.instance_variables.each_with_object({}) do |key, hash|
          assigns[key[1..-1].to_sym] = controller.instance_variable_get key
        end
        controller.response(controller.render(act, **assigns), status = 200, headers = {})
        [200, {'Content-Type' => 'text/html'}, [text]]
      end
      st, hd, rs = controller.get_response.to_a
      [st, hd, [rs.body].flatten]
    end
  end
end
