# Inheritance initialize args

class Bicycle
  attr_reader :size 
  def initialize(args={})
    @size = args[:size] # <- перемещено из RoadBike
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color
  def initialize(args)
    @tape_color = args[:tape_color]
    super(args) # <- RoadBike теперь ДОЛЖЕН отправлять 'super'
  end
end

road_bike = RoadBike.new(size: 'M', tape_color: 'red')
road_bike.size # -> 'M'
