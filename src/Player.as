package  
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Player extends Entity 
	{
		private var _gameObject : InteractiveElement;
		private var _keyPoints : Array = [];
		
		public static const NONE : int = 0;
		public static const HIDDEN : int = 1 << 0;
		public static const INACTIVE : int = 1 << 1;
		public static const CROUCH : int = 1 << 2;
		private var _speed : Number = 256;
		
		private var _animationData : Object = {
			idle : {looped : false},
			walking : {looped : true}
		};
		
		private var _room : String;
		private var _currentAnim : String = "idle";
		private var _pAnim : String = "";
		private var b:Boy;
		private var hitbox : Rectangle = new Rectangle(0, 0, 110, 290);
		private var _looped : Boolean = false;
		
		public function Player() 
		{
			super();
			_status = NONE;
			addEventListener(Event.COMPLETE, animationCompleted);
		}
		
		private function animationCompleted(e:Event):void 
		{
			if (_looped)
			{
				b.gotoAndPlay(_currentAnim);
			}
			else
			{
				
			}
		}
		
		override public function get width():Number 
		{
			return hitbox.width;
		}
		
		override public function get height():Number 
		{
			return hitbox.height;
		}
		
		override public function getMidPoint():Point 
		{
			return new Point (x + hitbox.width / 2, y + hitbox.height / 2);
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			addChild(b = new Boy());
			b.x = hitbox.width / 2;
			b.y = hitbox.height;
			
			y = 300;
			
			_keyPoints.push(new Point (0, 0));
			_keyPoints.push(new Point (width, 0));
			_keyPoints.push(new Point (width, height));
			_keyPoints.push(new Point (0, height));
		}
		
		override public function update():void 
		{
			super.update();
			
			_room = parent.name;
			
			var dx : Number = 0;
			
			if (!isInactive())
			{
				if (!isCrouching())
				{
					if (Game.keyPressed(Action.LEFT))
					{
						b.scaleX = -1;
						dx -= Math.round((_speed) * Game.dt);
					}
					
					if (Game.keyPressed(Action.RIGHT))
					{
						b.scaleX = 1;
						dx += Math.round((_speed) * Game.dt);
					}
					
					if (Game.keyJustPressed(Action.INTERACT))
					{
						if (_gameObject)
						{
							_gameObject.interact();
						}
					}
				}
				
				if (Game.keyJustPressed(Action.CROUCH))
				{
					setFlag(CROUCH);
				}
				else if (Game.keyJustReleased(Action.CROUCH))
				{
					resetFlag(CROUCH);
				}
			}
			
			if (dx == 0)
				_currentAnim = "idle_" + (parent as Room).time;
			else
			{
				this.x += dx;
				_currentAnim = "walking_" + (parent as Room).time;
			}
			
			if (_currentAnim != _pAnim)
			{
				_looped = _animationData[_currentAnim.split("_")[0]].looped;
				b.gotoAndPlay(_currentAnim);
				_pAnim = _currentAnim;
			}
			
		}
		
		public function isOverlappedBy (s : Light) : Boolean
		{
			for (var i : int = 0; i < _keyPoints.length; i++)
			{
				if (!s.hitTestPoint(x + _keyPoints[i].x, y + _keyPoints[i].y, true))
				{
					return false;
				}
			}
			return true;
		}
		
		public function isHidden () : Boolean
		{
			return ((_status & HIDDEN) == HIDDEN);
		}
		
		public function isInactive () : Boolean
		{
			return ((_status & INACTIVE) == INACTIVE);
		}
		
		public function isCrouching () : Boolean
		{
			return ((_status & CROUCH) == CROUCH);
		}
		
		public function set gameObject(value:InteractiveElement):void 
		{
			_gameObject = value;
		}
		
		public function get status():int 
		{
			return _status;
		}
		
		public function get room():String 
		{
			return _room;
		}
		
		public function get speed():Number 
		{
			return _speed;
		}
		
		public function set speed(value:Number):void 
		{
			_speed = value;
		}
		
		override public function setFlag(flag:int):void 
		{
			super.setFlag(flag);
			if (flag == INACTIVE)
			{
				b.stop();
			}
		}
		
		override public function resetFlag(flag:int):void 
		{
			super.resetFlag(flag);
			if (flag == INACTIVE)
			{
				b.gotoAndPlay(b.currentFrame - 1);
				b.gotoAndPlay(b.currentFrame + 1);
			}
		}
	}

}