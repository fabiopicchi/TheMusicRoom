package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class GameObject extends Entity 
	{
		
		public function GameObject() 
		{
			
		}
		
		override protected function init(e:Event):void 
		{
			super.init(e);
		}
		
		override public function update():void 
		{
			super.update();
		}
		
		override public function draw():void 
		{
			super.draw();
		}
		
		override protected function destroy(e:Event):void 
		{
			super.destroy(e);
		}
	}

}