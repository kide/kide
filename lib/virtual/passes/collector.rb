module Virtual

  #  collect anything that is in the space but and reachable from init
  class Collector
    def run
      # init= Parfait::Space.object_space.get_class_by_name("Kernel").get_instance_method "__init__"
      keep Parfait::Space.object_space
    end

    def keep object
      return if object.nil?
      return unless Machine.instance.add_object object
#      puts "adding #{object.class}"
      unless object.has_layout?
        object.init_layout
      end
      layout = object.get_layout
      puts "Layout #{layout.get_object_class.name} #{Machine.instance.objects.include?(layout)}"
      keep layout
      layout.each do |name|
        inst = object.instance_variable_get "@#{name}".to_sym
        keep inst
      end
      if object.is_a? Parfait::List
        object.each do |item|
          keep item
        end
      end
    end
  end
end
