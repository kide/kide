module Crystal
  module Kernel
    def self.exit context
      function = Virtual::Method.new(:exit , [] , Virtual::Integer)
      return function
      ret = Virtual::RegisterMachine.instance.exit(function)
      function.set_return ret
      function
    end
  end
end
