package  
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
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
		
		private var _room : String;
		
		public function Player() 
		{
			super();
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
			
			var s : Shape = new Shape();
			s.graphics.beginFill(0xFFFFFF);
			s.graphics.drawRect(0, 0, 30, 100);
			s.graphics.endFill();
			
			this.y = 500;
			
			addChild(s);
			
			_keyPoints.push(new Point (0, 0));
			_keyPoints.push(new Point (width, 0));
			_keyPoints.push(new Point (width, height));
			_keyPoints.push(new Point (0, height));
		}
		
		override public function update():void 
		{
			super.update();
			
			_room = parent.name;
			
			if (Game.keyPressed(Action.LEFT))
			{
				this.x -= (1024) * Game.dt / 1000;
			}
			
			if (Game.keyPressed(Action.RIGHT))
			{
				this.x += (1024) * Game.dt / 1000;
			}
			
			if (Game.keyJustPressed(Action.INTERACT))
			{
				if (_gameObject)
				{
					_gameObject.interact();
				}
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