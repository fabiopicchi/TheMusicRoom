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
		private var _gameObject : GameObject;
		private var _keyPoints : Array = [];
		
		public static const NONE : int = 0;
		public static const HIDDEN : int = 1 << 0;
		public static const INACTIVE : int = 1 << 1;
		public static const CROUCH : int = 1 << 2;
		
		private var _room : String;
		private var _currentAnim : String = "idle";
		private var _pAnim : String = "idle";
		private var b:Boy;
		private var hitbox : Rectangle = new Rectangle(0, 0, 110, 290);
		
		
		public function Player() 
		{
			super();
		}
		
		override public function get width():Number 
		{
			return hitbox.width;
		}
		
		override public function get height():Number 
		{
			return hitbox.height;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			addChild(b = new Boy());
			b.x += hitbox.width / 2;
			b.y += hitbox.height / 2;
			
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
			
			if (Game.keyPressed(Action.LEFT) && !((_status & INACTIVE) == INACTIVE))
			{
				b.scaleX = -1;
				dx -= Math.round((1024) * Game.dt);
			}
			
			if (Game.keyPressed(Action.RIGHT) && !((_status & INACTIVE) == INACTIVE))
			{
				b.scaleX = 1;
				dx += Math.round((1024) * Game.dt);
			}
			
			if (dx == 0)
				_currentAnim = "idle";
			else
			{
				this.x += dx;
				_currentAnim = "walking";
			}
			
			if (Game.keyJustPressed(Action.INTERACT))
			{
				if (_gameObject)
				{
					_gameObject.interact();
				}
			}
			
			
			if (_currentAnim != _pAnim)
			{
				b.gotoAndPlay(_currentAnim);
				_pAnim = _currentAnim;
			}
			
		}
		
		public function isOverlappedBy (s : Shadow) : Boolean
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
		
		public function set gameObject(value:GameObject):void 
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
	}

}