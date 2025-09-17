class Return
  #: Object
  attr_reader :value

  #: (Object) -> Return
  def initialize(value)
    @value = value
  end
end
