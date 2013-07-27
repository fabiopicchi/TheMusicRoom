package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class PermaChangeObject extends GameObject 
	{
		
		public function PermaChangeObject() 
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
		
		override public function interact(fromPlayer : Boolean = true):void 
		{
			super.interact();
			
			if (currentFrameLabel == "A")
			{
				gotoAndStop("B");
			}
			out();
			_interactive = false;
		}
	}

}