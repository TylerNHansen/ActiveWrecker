class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |method_name|
      define_method(method_name) { instance_eval("@#{method_name}") }
      define_method("#{method_name}=") do |arg|
        instance_eval("@#{method_name} = arg")
       end
    end
  end
end
