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
		protected var _hidden : Boolean = false;
		protected var _id : String = "";
		
		public function GameObject() 
		{
			gotoAndStop("A");
			out();
		}
		
		override protected function init(e:Event):void 
		{
			_id = name.split("_")[1];
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
				if ((getChildAt(0) as MovieClip))
					(getChildAt(0) as MovieClip).gotoAndStop("over");
			}
		}
		
		public function out():void
		{
			if (_interactive)
			{
				if ((getChildAt(0) as MovieClip))
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
		
		public function get id():String 
		{
			return _id;
		}
		
		public function set interactive(value:Boolean):void 
		{
			_interactive = value;
		}
		
		public function get hidden():Boolean 
		{
			return _hidden;
		}
		
		public function set hidden(value:Boolean):void 
		{
			_hidden = value;
		}
	}

}