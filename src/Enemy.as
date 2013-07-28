package  
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
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
		public static const LOOKING_CROUCH:int = 1 << 3;
		
		private var _attackRange : Number = 10;
		private var _patrolRoom : Room;
		
		private var _arRoute : Array = [];
		private var _arWait : Array = [];
		private var _routePosition : int = 0;
		
		private var _lookingTimeout : int;
		private var _lookingStartX : Number = 0;
		
		private var _waiting : Boolean = false;
		private var _waitingTimeout : int;
		
		private var _room : String = "";
		private var _speed : Number = 512;
		private var _facing : int;
		
		private var _target : Number;
		
		public function Enemy() 
		{
			_arRoute = [500, 600, 800, 700, 900];
			_arWait = [1000, 1000, 1000, 1000, 1000];
			
			setFlag(PATROL);
			_routePosition = 0;
			_target = _arRoute[_routePosition + 1]; 
			this.x = _arRoute[_routePosition];
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
			
			moveToTarget();
			
			if (isPatrolling())
			{
				if (x == _target)
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
							
							_target = _arRoute[_routePosition + 1];
						}, _arWait[_routePosition]);
					}
				}
			}
			
			if (isPursuing())
			{
				if (Game.playerInstance.room == room)
				{
					if (!isWithinRange())
					{
						_target = Game.playerInstance.getMidPoint().x;
					}
				}
				else
				{
					var porta : GameObject = (parent.getChildByName("object_" + Game.playerInstance.room) as GameObject);
					if (porta)
					{
						if (!(porta.x <= x + width && (porta.x + porta.width) >= x))
						{
							_target = porta.getMidPoint().x;
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
								if (isFacing(LEFT)) _target = _lookingStartX - 100;
								if (isFacing(RIGHT)) _target = _lookingStartX + 100;
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
						if (getMidPoint().x < _lookingStartX - 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.RIGHT;
								_target = _lookingStartX + 100;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
					else
					{
						if (getMidPoint().x > _lookingStartX + 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.LEFT;
								_target = _lookingStartX - 100;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
				}
				
				_lookingTimeout -= Game.dt;
			}
			
			if (isLookingCrouch())
			{
				if (!_waiting)
				{
					if (isFacing(LEFT))
					{
						if (getMidPoint().x < _lookingStartX - 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.RIGHT;
								_target = _lookingStartX + 100;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
					else
					{
						if (getMidPoint().x > _lookingStartX + 100)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_facing = Entity.LEFT;
								_target = _lookingStartX - 100;
								if (_lookingTimeout <= 0)
								{
									teleportBack();
								}
							}, 500);
						}
					}
				}
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
		
		public function isLookingCrouch () : Boolean
		{
			return ((_status & LOOKING_CROUCH) == LOOKING_CROUCH);
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
		
		public function moveToTarget () : void
		{
			if (x != _target)
			{
				if (x > _target)
				{
					x -= Math.round(_speed * Game.dt);
					_facing = Entity.LEFT;
				}
				else
				{
					x += Math.round(_speed * Game.dt);
					_facing = Entity.RIGHT;
				}
				
				if ((isFacing(LEFT) && x < _target) || (isFacing(RIGHT) && x > _target))
				{
					x = _target;
				}
			}

			if (!isPursuing() && Game.playerInstance.room == room && !Game.playerInstance.isHidden())
			{
				if (Game.playerInstance.getMidPoint().x < x && isFacing(LEFT) || Game.playerInstance.getMidPoint().x > x && isFacing(RIGHT))
				{
					_status = 0;
					setFlag(PURSUE);
					_waiting = false;
					clearTimeout(_waitingTimeout);
				}
			}
		}
		
		public function get room():String 
		{
			return _room;
		}
	}

}