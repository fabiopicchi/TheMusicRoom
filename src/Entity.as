package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
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
			
		}
		
		public function draw () : void
		{
			
		}
		
		protected function destroy(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			
		}
	}

}