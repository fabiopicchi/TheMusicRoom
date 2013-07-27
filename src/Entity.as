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
		
		public function Entity() 
		{
			addEventListener (Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
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
	}

}