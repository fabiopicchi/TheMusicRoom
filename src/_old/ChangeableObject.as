package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class ChangeableObject extends GameObject 
	{
		
		public function ChangeableObject() 
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
			
			if (_asset == "A")
			{
				_asset = "B";
			}
			else
			{
				_asset = "A";
			}
			if (fromPlayer)
			{
				over();
			}
			else
			{
				out();
			}
			updateAsset();
		}
	}

}