require 'logging'
require 'eventmachine'
require 'sqlite3'
require 'rufus/scheduler'
require 'ostruct'

module Lapidary
  autoload :Server,             'lapidary/server'
  
  module Engine
    autoload :EventManager,     'lapidary/core/engine'
    autoload :Event,            'lapidary/core/engine'
    autoload :QueuePolicy,      'lapidary/core/engine'
    autoload :WalkablePolicy,   'lapidary/core/engine'
    autoload :Action,           'lapidary/core/engine' # TODO move to Actions
    autoload :ActionQueue,      'lapidary/core/engine' # TODO move to Actions
  end
  
  module Misc
    autoload :AutoHash,            'lapidary/core/util'
    autoload :HashWrapper,         'lapidary/core/util'
    autoload :Flags,               'lapidary/core/util'
    autoload :TextUtils,           'lapidary/core/util'
    autoload :NameUtils,           'lapidary/core/util'
    autoload :ThreadPool,          'lapidary/core/util'
    autoload :Cache,               'lapidary/core/cache'
  end
  
  module Actions
    autoload :HarvestingAction,    'lapidary/core/actions'
  end
  
  module Model
    autoload :HitType,             'lapidary/model/combat'
    autoload :Hit,                 'lapidary/model/combat'
    autoload :Damage,              'lapidary/model/combat'
    autoload :Animation,           'lapidary/model/effects'
    autoload :Graphic,             'lapidary/model/effects'
    autoload :ChatMessage,         'lapidary/model/effects'
    autoload :Entity,              'lapidary/model/entity'
    autoload :Location,            'lapidary/model/location'
    autoload :Player,              'lapidary/model/player'
    autoload :RegionManager,       'lapidary/model/region'
    autoload :Region,              'lapidary/model/region'
  end
  
  module Item
    autoload :Item,                       'lapidary/model/item'
    autoload :ItemDefinition,             'lapidary/model/item'
    autoload :Container,                  'lapidary/model/item'
    autoload :ContainerListener,          'lapidary/model/item'
    autoload :InterfaceContainerListener, 'lapidary/model/item'
    autoload :WeightListener,             'lapidary/model/item'
    autoload :BonusListener,              'lapidary/model/item'
  end
  
  module NPC
    autoload :NPC,                 'lapidary/model/npc'
    autoload :NPCDefinition,       'lapidary/model/npc'
  end
  
  module Player
    autoload :Appearance,          'lapidary/model/player/appearance'
    autoload :InterfaceState,      'lapidary/model/player/interfacestate'
    autoload :RequestManager,      'lapidary/model/player/requestmanager'
    autoload :Skills,              'lapidary/model/player/skills'
  end
  
  module Net
    autoload :ActionSender,        'lapidary/net/actionsender'
    autoload :ISAAC,               'lapidary/net/isaac'
    autoload :Session,             'lapidary/net/session'
    autoload :Connection,          'lapidary/net/connection'
    autoload :Packet,              'lapidary/net/packet'
    autoload :PacketBuilder,       'lapidary/net/packetbuilder'
    autoload :JaggrabConnection,   'lapidary/net/jaggrab'
  end
  
  module GroundItems
    autoload :GroundItem,          'lapidary/services/ground_items'
    autoload :GroundItemEvent,     'lapidary/services/ground_items'
    autoload :PickupItemAction,    'lapidary/services/ground_items'
  end
  
  module Shops
    autoload :ShopManager,         'lapidary/services/shops'
    autoload :Shop,                'lapidary/services/shops'
  end
  
  module Objects
    autoload :ObjectManager,       'lapidary/services/objects'
  end
  
  module Doors
    autoload :DoorManager,         'lapidary/services/doors'
    autoload :Door,                'lapidary/services/doors'
    autoload :DoubleDoor,          'lapidary/services/doors'
    autoload :DoorEvent,           'lapidary/services/doors'
  end
  
  module Tasks
    autoload :NPCTickTask,         'lapidary/tasks/npc_update'
    autoload :NPCResetTask,        'lapidary/tasks/npc_update'
    autoload :NPCUpdateTask,       'lapidary/tasks/npc_update'
    autoload :PlayerTickTask,      'lapidary/tasks/player_update'
    autoload :PlayerResetTask,     'lapidary/tasks/player_update'
    autoload :PlayerUpdateTask,    'lapidary/tasks/player_update'
    autoload :SystemUpdateEvent,   'lapidary/tasks/sysupdate_event'
    autoload :UpdateEvent,         'lapidary/tasks/update_event'
  end
  
  module World
    autoload :Profile,             'lapidary/world/profile'
    autoload :Pathfinder,          'lapidary/world/walking'
    autoload :Point,               'lapidary/world/walking'
    autoload :World,               'lapidary/world/world'
    autoload :LoginResult,         'lapidary/world/world'
    autoload :Loader,              'lapidary/world/world'
    autoload :YAMLFileLoader,      'lapidary/world/world'
    autoload :NPCSpawns,           'lapidary/world/npc_spawns'
    autoload :ItemSpawns,          'lapidary/world/item_spawns'
  end
end

require 'lapidary/plugin_hooks'
require 'lapidary/net/packetloader'

