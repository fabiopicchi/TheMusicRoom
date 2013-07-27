package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class GameObject extends Entity 
	{
		protected var _interactive : Boolean = true;
		
		public function GameObject() 
		{
			
		}
		
		override protected function init(e:Event):void 
		{
			stop();
			out();
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
		
		public function over():void
		{
			if (_interactive)
			{
				(getChildAt(0) as MovieClip).gotoAndStop("over");
			}
		}
		
		public function out():void
		{
			if (_interactive)
			{
				(getChildAt(0) as MovieClip).gotoAndStop("normal");
			}
		}
		
		public function interact(fromPlayer : Boolean = true):void
		{
			
		}
		
		public function get interactive():Boolean 
		{
			return _interactive;
		}
	}

}