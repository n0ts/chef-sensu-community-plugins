actions :install, :remove

attribute :kind, :kind_of => String

def initialize(*args)
  super
  @action = :install
end

