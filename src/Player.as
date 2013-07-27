package  
{
	import flash.display.Shape;
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Player extends Entity 
	{
		private var _gameObject : GameObject;
		
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
		}
		
		override public function update():void 
		{
			super.update();
			
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
		
		public function set gameObject(value:GameObject):void 
		{
			_gameObject = value;
		}
	}

}