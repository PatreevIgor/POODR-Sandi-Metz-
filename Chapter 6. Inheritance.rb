# Inheritance initialize args ------------------------------------------------------------------------------------------

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

# BAD: -----------------------------------------------------------------------------------------------------------------
class Bicycle
  attr_reader :style, :size, :tape_color, :front_shock, :rear_shock

  def initialize(args)
    @style = args[:style]
    @size = args[:size]
    @tape_color = args[:tape_color]
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
  end

  # Проверка «стиля» проходит по скользкой дорожке
  def spares
    if style == :road
      { chain: '10-speed', tire_size: '23', tape_color: tape_color }
    else
      { chain: '10-speed', tire_size: '2.1', rear_shock: rear_shock }
    end
  end
end

bike = Bicycle.new( style: :mountain, size: 'S', front_shock: 'Manitou', rear_shock: 'Fox')
bike.spares # -> {:tire_size => "2.1", # :chain => "10-speed", # :rear_shock => 'Fox'}

# GOOD: ----------------------------------------------------------------------------------------------------------------

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
    super(args)
  end
  def spares
    super.merge(rear_shock: rear_shock)
  end
end

# VERY GOOD: -----------------------------------------------------------------------------------------------------------

class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size      = args[:size]
    @chain     = args[:chain]     || default_chain
    @tire_size = args[:tire_size] || default_tire_size
  end

  def spares
    { tire_size: tire_size, chain: chain}
  end

  def default_chain # <- общее исходное значение
    '10-speed'
  end

  def default_tire_size # for developer witch forgot add thise method in child class
    raise NotImplementedError
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

  def spares
    super.merge({ tape_color: tape_color})
  end

  def default_tire_size
    '23'
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
    super(args)
  end

  def spares
    super.merge({rear_shock: rear_shock})
  end

  def default_tire_size
    '2.1'
  end
end

# VERY VERY GOOD (without super): --------------------------------------------------------------------------------------

class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size      = args[:size]
    @chain     = args[:chain]     || default_chain
    @tire_size = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    { tire_size: tire_size, chain: chain}.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  # subclasses may override
  def post_initialize(args)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
  '10-speed'
  end
end

class RoadBike < Bicycle
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    {tape_color: tape_color}
  end

  def default_tire_size
  '23'
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock  = args[:rear_shock]
  end

  def local_spares
    {rear_shock: rear_shock}
  end

  def default_tire_size
    '2.1'
  end
end

# Example add new class:

class RecumbentBike < Bicycle
  attr_reader :flag

  def post_initialize(args)
    @flag = args[:flag]
  end

  def local_spares
    {flag: flag}
  end

  def default_chain
    "9-speed"
  end

  def default_tire_size
    '28'
  end
end

bent = RecumbentBike.new(flag: 'tall and orange')
bent.spares

# -> {:tire_size => "28",
# :chain => "9-speed",
# :flag => "tall and orange"}
