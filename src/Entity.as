package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Entity extends MovieClip
	{
		//Facing directions
		public static const LEFT : int = 0;
		public static const RIGHT : int = 1;
		
		protected var _status : int = 0;
		
		public function Entity() 
		{
			addEventListener (Event.ADDED, init);
		}
		
		protected function init(e:Event):void 
		{
			removeEventListener(Event.ADDED, init);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
		
		public function update () : void
		{
			for (var i : int = 0; i < numChildren; i++)
			{
				var e : Entity;
				if ((e = (getChildAt(i) as Entity)))
				{
					e.update();
				}
			}
		}
		
		public function draw () : void
		{
			for (var i : int = 0; i < numChildren; i++)
			{
				var e : Entity;
				if ((e = (getChildAt(i) as Entity)))
				{
					e.draw();
				}
			}
		}
		
		protected function destroy(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
		}
		
		public function getMidPoint () : Point
		{
			return new Point (x + width / 2, y + height / 2);
		}
		
		
		public function setFlag (flag : int) : void
		{
			_status |= flag;
		}
		
		public function resetFlag (flag : int) : void
		{
			_status &= ~flag;
		}
		
		public function testFlag (flag : int) : Boolean
		{
			return ((_status & flag) == flag);
		}
		
		public function updateAsset (time : String, mode : String) : void
		{
			gotoAndStop(time + "_" + mode);
		}
	}

}