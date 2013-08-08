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
		public static const RESTING:int = 1 << 5;
		public static const FADING:int = 1 << 6;
		
		private var _attackRange : Number = 10;
		private var _patrolRoom : Room;
		
		private var _animationData : Object = {
			idle : {looped : true},
			walking : { looped : true },
			attack : {looped : false},
			fade : {looped : false}
		};
		
		private var _arRoute : Array = [];
		private var _arWait : Array = [];
		private var _routePosition : int = 0;
		private var _minX : int = int.MAX_VALUE;
		private var _maxX : int = int.MIN_VALUE;
		private var _indexOfMinX : int = 0;
		private var _indexOfMaxX : int = 0;
		
		private var _lookingTimeout : Number;
		private var _lookingStartX : Number = 0;
		
		private var _waiting : Boolean = false;
		private var _waitingTimeout : int;
		
		private var _room : String = "";
		private var _speed : Number = 240;
		private var _facing : int;
		
		private var _target : Number;
		
		private var _body : MovieClip;
		private var _currentAnim : String = "idle";
		private var _pAnim : String = "";
		private var _looped : Boolean = false;
		private var hitbox : Rectangle = new Rectangle(0, 0, 110, 290); 
		private var _realTarget : Number = 0;
		private var _collided : Boolean = false;
		
		private var _enemyType : int;
		
		public function Enemy() 
		{
			setFlag(PATROL);
			_routePosition = 0;
			_arRoute = [0.25, 0.75, 0.50, 0.75, 0.25];
			_arWait = [1000, 1000, 1000, 1000, 1000];
			
			addEventListener(Event.COMPLETE, animationCompleted);
		}
		
		override public function get width():Number 
		{
			return hitbox.width;
		}
		
		public function loadData (data : Object) : void
		{
			_patrolRoom = Game.ROOM_MAP[data.room];
			if (data.type == "1")
			{
				_body = new Monster1;
			}
			else
			{
				_body = new Monster2;
			}
			
			addChild(_body);
			_body.x = hitbox.width / 2;
			_body.y = hitbox.height / 2;
			y = 300;
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
					setFlag(RESTING);
					setTimeout (function () : void
					{
						resetFlag(RESTING);
					}, 200);
					_pAnim = "";
					Game.playSfx(Game.ENEMY_ATTACK);
					_body.gotoAndPlay(_currentAnim = "idle");
				}
				
				else if (_currentAnim == "fade")
				{
					if (parent != _patrolRoom)
					{
						parent.removeChild(this);
						_patrolRoom.addChild(this);
					}					
					_status = 0;
					setFlag(RESTING);
					visible = false;
					_pAnim = "fade";
					_currentAnim = "walking";
				}
			}
		}
		
		public function spawn () : void
		{
			Game.playSfx(Game.ENEMY_SPAWN);
			
			var area : DisplayObject = _patrolRoom.getChildByName("area");
			var left : Boolean = (Math.random() > 0.5 ? true : false);
			
			if (_minX == int.MAX_VALUE)
			{
				var val : Number;
				for (var i : int = 0; i < _arRoute.length; i++)
				{
					val = area.x + _arRoute[i] * area.width - _patrolRoom.scrollAcc;
					if (val < _minX)
					{
						_minX = val;
						_indexOfMinX = i;
					}
					if (val > _maxX)
					{
						_maxX = val;
						_indexOfMaxX = i;
					}
				}
			}
			
			if (left)
			{
				x = Game.playerInstance.x - 200;
				_target = _minX;
				_routePosition = _indexOfMinX;
				_facing = LEFT;
				
				if (x < _minX + _patrolRoom.scrollAcc)
				{
					x = Game.playerInstance.x + 200;
					_target = _maxX;
					_routePosition = _indexOfMaxX;
					_facing = RIGHT;
				}
			}
			else
			{
				x = Game.playerInstance.x + 200;
				_target = _maxX;
				_routePosition = _indexOfMaxX;
				_facing = RIGHT;
				
				if (x > _maxX + _patrolRoom.scrollAcc)
				{
					x = Game.playerInstance.x - 200;
					_target = _minX;
					_routePosition = _indexOfMinX;
					_facing = LEFT;
				}
			}
			
			resetFlag(RESTING);
			setFlag(PATROL);
			visible = true;
		}
		
		override public function update():void 
		{
			if (!testFlag(RESTING) && !testFlag(FADING))
			{
				super.update();
				
				_room = parent.name;
				
				moveToTarget();
				
				if (isPatrolling())
				{
					if (x == _realTarget)
					{
						if (!_waiting && _arWait.length > 0)
						{
							_waiting = true
							_waitingTimeout = setTimeout(function () : void
							{
								_waiting = false;
								_routePosition++;
								if (_routePosition >= _arRoute.length - 1)
									_routePosition = 0;					
								var area : MovieClip = _patrolRoom.getChildByName("area");
								
								_target = area.x + _arRoute[_routePosition + 1] * area.width;
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
							_target = Game.playerInstance.getMidPoint().x - (parent as Room).scrollAcc;
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
								_target = (targetObject as Entity).getMidPoint().x - (parent as Room).scrollAcc;
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
									
									_lookingStartX = x - (parent as Room).scrollAcc;
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
					if (!_waiting && x == _realTarget)
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
					if (!_waiting && x == _realTarget)
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
					var dist : Number = x - Game.playerInstance.x;
					Game.tuneMonsterSfx(Math.abs(dist), (dist < 0));
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
				
				if (_collided) _collided = false;
			}
		}
		
		private function teleportBack () : void
		{
			_currentAnim = "fade";
			setFlag(FADING);
			_body.gotoAndPlay(_currentAnim);
			_looped = _animationData[_currentAnim].looped;
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
			_realTarget = Math.round(_target + (parent as Room).scrollAcc);
			
			if (x != _realTarget && !(isPursuing() && isWithinRange()))
			{
				if (x > _realTarget)
				{
					dx -= Math.round(_speed * Game.dt);
					_facing = Entity.LEFT;
				}
				else
				{
					dx += Math.round(_speed * Game.dt);
					_facing = Entity.RIGHT;
				}
				
				if ((isFacing(LEFT) && x + dx < _realTarget) || (isFacing(RIGHT) && x + dx > _realTarget))
				{
					dx = (_realTarget - x);
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
					Game.playMonsterSfx();
					Game.muteMusic();
					setFlag(PURSUE);
					_waiting = false;
					clearTimeout(_waitingTimeout);
				}
			}
			
			else if (Game.playerInstance.isCrouching() && !isLookingCrouch())
			{
				_lookingStartX = Game.playerInstance.getMidPoint().x - (parent as Room).scrollAcc;
				_status = 0;
				_lookingTimeout = 3;
				setFlag(LOOKING_CROUCH);
			}
		}
		
		public function get room():String 
		{
			return _room;
		}
		
		override public function get x():Number 
		{
			return super.x;
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
		}
		
		public function onCollision () : void
		{
			_target = x - (parent as Room).scrollAcc;
			_realTarget = _target + (parent as Room).scrollAcc;
			_collided = true;
		}
	}

}