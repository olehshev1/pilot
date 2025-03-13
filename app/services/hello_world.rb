class HelloWorld
  def initialize(name:)
    @name = name
  end

  def call
    "#{@name}, Hello World!"
  end
end
