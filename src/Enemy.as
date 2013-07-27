package  
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Enemy extends Entity 
	{
		public static const PATROL:int = 1 << 0;
		public static const PURSUE:int = 1 << 1;
		public static const LOOKING:int = 1 << 2;
		
		private var _arRoute : Array = [];
		private var _arWait : Array = [];
		private var _speed : Number = 512;
		private var _room : String = "";
		private var _routePosition : int = 0;
		private var _facing : int;
		private var _waiting : Boolean = false;
		private var _waitingTimeout : int;
		private var _lookingTimeout : int;
		private var _attackRange : Number = 10;
		private var _lookingStartX : Number = 0;
		private var _patrolRoom : Room;
		
		public function Enemy() 
		{
			_arRoute = [100, 200, 400, 300, 500];
			_arWait = [1000, 1000, 1000, 1000, 1000];
			
			setFlag(PATROL);
			_routePosition = 0;
			this.x = _arRoute[_routePosition];
			if (x < _arRoute[_routePosition + 1])
			{
				_facing = Entity.RIGHT;
			}
			else
			{
				_facing = Entity.LEFT;
			}
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			if (!_patrolRoom) _patrolRoom = (parent as Room);
			
			var s : Shape = new Shape();
			s.graphics.beginFill(0xCC0408);
			s.graphics.drawRect(0, 0, 30, 100);
			s.graphics.endFill();
			
			this.y = 500;
			
			addChild(s);
			
		}
		
		override public function update():void 
		{
			super.update();
			
			_room = parent.name;
			
			if (isPatrolling())
			{
				if (x != _arRoute[_routePosition + 1])
				{
					if (isFacing(LEFT))
					{
						x -= _speed * Game.dt / 1000;
						if (x < _arRoute[_routePosition + 1]) x = _arRoute[_routePosition + 1];
					}
					else
					{
						x += _speed * Game.dt / 1000;
						if (x > _arRoute[_routePosition + 1]) x = _arRoute[_routePosition + 1];
					}
				}
				else
				{
					if (!_waiting)
					{
						_waiting = true
						_waitingTimeout = setTimeout(function () : void
						{
							_waiting = false;
							_routePosition++;
							if (_routePosition >= _arRoute.length - 1)
								_routePosition = 0;					
							
							if (x < _arRoute[_routePosition + 1])
							{
								_facing = Entity.RIGHT;
							}
							else
							{
								_facing = Entity.LEFT;
							}
						}, _arWait[_routePosition]);
					}
				}
				
				if (Game.playerInstance.room == room)
				{
					if (!Game.playerInstance.isHidden())
					{
						if (Game.playerInstance.getMidPoint().x < x && isFacing(LEFT) || Game.playerInstance.getMidPoint().x > x && isFacing(RIGHT))
						{
							resetFlag(PATROL);
							setFlag(PURSUE);
							_waiting = false;
							clearTimeout(_waitingTimeout);
						}
					}
				}
			}
			
			if (isPursuing())
			{
				if (Game.playerInstance.room == room)
				{
					if (!isWithinRange())
					{
						if (Game.playerInstance.getMidPoint().x < x)
						{
							_facing = Entity.LEFT;
							x -= _speed * Game.dt / 1000;
						}
						else
						{
							_facing = Entity.RIGHT;
							x += _speed * Game.dt / 1000;
						}
					}
				}
				else
				{
					var target : GameObject = (parent.getChildByName("object_" + Game.playerInstance.room) as GameObject);
					if (target)
					{
						if (!(target.x <= x + width && (target.x + target.width) >= x))
						{
							if (target.getMidPoint().x < x)
							{
								_facing = Entity.LEFT;
								x -= _speed * Game.dt / 1000;
							}
							else
							{
								_facing = Entity.RIGHT;
								x += _speed * Game.dt / 1000;
							}
						}
						else
						{
							var prevRoom : String = parent.name;
							parent.removeChild(this);
							Game.playerInstance.parent.addChild(this);
							x = (parent.getChildByName("object_" + prevRoom) as GameObject).x + ((parent.getChildByName("object_" + prevRoom) as GameObject).width - width) / 2;
							
							if (Game.playerInstance.isHidden())
							{
								resetFlag(PURSUE);
								setFlag(LOOKING);
								
								_lookingStartX = x;
								_facing = ((Math.floor(Math.random() * 2)) ? Entity.LEFT : Entity.RIGHT);
								_lookingTimeout = 3000;
							}
						}
					}
					else
					{
						teleportBack();
					}
				}
			}
			
			if (isLooking())
			{
				if (!_waiting)
				{
					if (isFacing(LEFT))
					{
						x -= _speed * Game.dt / 1000;
						if (getMidPoint().x < _lookingStartX - 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.RIGHT;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
					else
					{
						x += _speed * Game.dt / 1000;
						if (getMidPoint().x > _lookingStartX + 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.LEFT;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
				}
				
				if (Game.playerInstance.room == room)
				{
					if (!Game.playerInstance.isHidden())
					{
						if (Game.playerInstance.getMidPoint().x < x && isFacing(LEFT) || Game.playerInstance.getMidPoint().x > x && isFacing(RIGHT))
						{
							resetFlag(LOOKING);
							setFlag(PURSUE);
							_waiting = false
							clearTimeout(_waitingTimeout);
						}
					}
				}
				
				_lookingTimeout -= Game.dt;
			}
		}
		
		private function teleportBack () : void
		{
			parent.removeChild(this);
			_patrolRoom.addChild(this);
			_status = 0;
			setFlag(PATROL);
		}
		
		private function isWithinRange():Boolean
		{
			return ((Game.playerInstance.x > x && Math.abs(Game.playerInstance.x - (x + width)) < _attackRange) || 
					(Game.playerInstance.x < x && Math.abs(x - (Game.playerInstance.x + Game.playerInstance.width)) < _attackRange));
		}
		
		public function isPatrolling () : Boolean
		{
			return ((_status & PATROL) == PATROL);
		}
		
		public function isPursuing () : Boolean
		{
			return ((_status & PURSUE) == PURSUE);
		}
		
		public function isLooking () : Boolean
		{
			return ((_status & LOOKING) == LOOKING);
		}
		
		public function attack():void 
		{
			
		}
		
		public function patrol():void 
		{
			
		}
		
		public function pursue():void 
		{
			
		}
		
		public function isFacing (dir : int) : Boolean
		{
			return (_facing == dir);
		}
		
		public function get room():String 
		{
			return _room;
		}
	}

}