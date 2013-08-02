package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		public static const ATTACKING:int = 1 << 4;
		
		private var _attackRange : Number = 10;
		private var _patrolRoom : Room;
		
		private var _animationData : Object = {
			idle : {looped : true},
			walking : { looped : true },
			attack : {looped : false}
		};
		
		private var _arRoute : Array = [];
		private var _arWait : Array = [];
		private var _routePosition : int = 0;
		
		private var _lookingTimeout : Number;
		private var _lookingStartX : Number = 0;
		
		private var _waiting : Boolean = false;
		private var _waitingTimeout : int;
		
		private var _room : String = "";
		private var _speed : Number = 512;
		private var _facing : int;
		
		private var _target : Number;
		
		private var _body : MovieClip;
		private var _currentAnim : String = "idle";
		private var _pAnim : String = "";
		private var _looped : Boolean = false;
		private var hitbox : Rectangle = new Rectangle(0, 0, 110, 290);
		
		public function Enemy() 
		{
			_arRoute = [500, 600, 800, 700, 900];
			_arWait = [1000, 1000, 1000, 1000, 1000];
			
			setFlag(PATROL);
			_routePosition = 0;
			_target = _arRoute[_routePosition + 1]; 
			this.x = _arRoute[_routePosition];
			addEventListener(Event.COMPLETE, animationCompleted);
		}
		
		override public function get width():Number 
		{
			return hitbox.width;
		}
		
		private function animationCompleted(e:Event):void 
		{
			if (_looped)
			{
				_body.gotoAndPlay(_currentAnim);
			}
			else
			{
				if (_currentAnim == "attack")
				{
					resetFlag(ATTACKING);
					_pAnim = "";
				}
			}
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			if (!_patrolRoom) _patrolRoom = (parent as Room);
			
			addChild(_body = new Monster1);
			_body.x = hitbox.width / 2;
			_body.y = hitbox.height / 2;
			
			y = 300;
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
					else
					{
						_currentAnim = "attack";
						setFlag(ATTACKING);
					}
				}
				else
				{
					var door : Door;
					var targetObject : DisplayObject;
					var i : int;
					for (i = 0; i < parent.numChildren; i++)
					{
						if ((door = (parent.getChildAt(i) as Door)))
						{
							if (door.destiny == Game.playerInstance.room)
								break;
						}
					}
					
					if (door)
					{
						if (!(targetObject = parent.getChildByName(door.name + "_h") )) targetObject = door;
						
						if (!(targetObject.x <= x + width && (targetObject.x + targetObject.width) >= x))
						{
							_target = (targetObject as Entity).getMidPoint().x;
						}
						else
						{
							var prevRoom : String = parent.name;
							parent.removeChild(this);
							Game.playerInstance.parent.addChild(this);
							
							for (i = 0; i < parent.numChildren; i++)
							{
								if ((door = (parent.getChildAt(i) as Door)))
								{
									if (door.destiny == prevRoom)
										break;
								}
							}
							if (!(targetObject = parent.getChildByName(door.name + "_h") )) targetObject = door;
							
							x = targetObject.x + (targetObject.width - width) / 2;
							
							if (Game.playerInstance.isHidden())
							{
								_status = 0;
								setFlag(LOOKING);
								
								_lookingStartX = x;
								_facing = ((Math.floor(Math.random() * 2)) ? Entity.LEFT : Entity.RIGHT);
								if (isFacing(LEFT)) _target = _lookingStartX - 100;
								if (isFacing(RIGHT)) _target = _lookingStartX + 100;
								_lookingTimeout = 3;
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
				if (!_waiting && x == _target)
				{
					if (isFacing(LEFT))
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
					else
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
				
				_lookingTimeout -= Game.dt;
			}
			
			if (isLookingCrouch())
			{
				if (!_waiting && x == _target)
				{
					if (isFacing(LEFT))
					{
						_waiting = true;
						_waitingTimeout = setTimeout(function () : void
						{
							_waiting = false;
							_facing = Entity.RIGHT;
							if (_lookingTimeout >= 0)
							{
								_target = _lookingStartX + 150;
							}
							else
							{
								//Go far
								if (Math.floor(Math.random() * 2) == 0)
								{
									_target = _lookingStartX + 300 + Math.floor(Math.random() * 200);
								}
								//Go near
								else
								{
									if (_lookingStartX - x >= 150)
									{
										if (Math.floor(Math.random() * 2) == 0)
										{
											_target = _lookingStartX + 150 - Math.floor(Math.random() * 75);
										}
										else
										{
											_target = _lookingStartX - 150 + Math.floor(Math.random() * 75);
										}
									}
									else
									{
										_target = _lookingStartX + 150;
									}
								}
							}
						}, 500);
					}
					else
					{
						_waiting = true;
						_waitingTimeout = setTimeout(function () : void
						{
							_waiting = false;
							_facing = Entity.LEFT;
							if (_lookingTimeout >= 0)
							{
								_target = _lookingStartX - 150;
							}
							else
							{
								//Go far
								if (Math.floor(Math.random() * 2) == 0)
								{
									_target = _lookingStartX - 300 - Math.floor(Math.random() * 200);
								}
								//Go near
								else
								{
									if (x - _lookingStartX >= 150)
									{
										if (Math.floor(Math.random() * 2) == 0)
										{
											_target = _lookingStartX - 150 + Math.floor(Math.random() * 75);
										}
										else
										{
											_target = _lookingStartX + 150 - Math.floor(Math.random() * 75);
										}
									}
									else
									{
										_target = _lookingStartX - 150;
									}
								}
							}
						}, 500);
					}
				}
				
				if (_lookingTimeout > 0) _lookingTimeout -= Game.dt;
			}
			
			if (_currentAnim != _pAnim)
			{
				_looped = _animationData[_currentAnim].looped;
				_body.gotoAndPlay(_currentAnim);
				_pAnim = _currentAnim;
			}
			if (isFacing(LEFT))
				_body.scaleX = -1;
			else
				_body.scaleX = 1;
			
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
			return ((Game.playerInstance.x > x && Game.playerInstance.x - (x + width) < _attackRange) || 
					(Game.playerInstance.x < x && x - (Game.playerInstance.x + Game.playerInstance.width) < _attackRange));
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
			var dx : Number = 0;
			
			_target = Math.round(_target);
			
			if (x != _target && !(isPursuing() && isWithinRange()))
			{
				if (x > _target)
				{
					dx -= Math.round(_speed * Game.dt);
					_facing = Entity.LEFT;
				}
				else
				{
					dx += Math.round(_speed * Game.dt);
					_facing = Entity.RIGHT;
				}
				
				if ((isFacing(LEFT) && x + dx < _target) || (isFacing(RIGHT) && x + dx > _target))
				{
					dx = (_target - x);
				}
			}
			
			if ((_status & ATTACKING) != ATTACKING)
			{
				if (dx == 0)
					_currentAnim = "idle";
				else
				{
					this.x += dx;
					_currentAnim = "walking";
				}
			}

			if (!isPursuing() && Game.playerInstance.room == room && (!Game.playerInstance.isHidden() && !Game.playerInstance.isCrouching()))
			{
				if (Game.playerInstance.getMidPoint().x < x && isFacing(LEFT) || Game.playerInstance.getMidPoint().x > x && isFacing(RIGHT))
				{
					_status = 0;
					setFlag(PURSUE);
					_waiting = false;
					clearTimeout(_waitingTimeout);
				}
			}
			
			else if (Game.playerInstance.isCrouching() && !isLookingCrouch())
			{
				_lookingStartX = Game.playerInstance.getMidPoint().x;
				_status = 0;
				_lookingTimeout = 3;
				setFlag(LOOKING_CROUCH);
			}
		}
		
		public function get room():String 
		{
			return _room;
		}
	}

}