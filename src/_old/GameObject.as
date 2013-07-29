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
		
		protected var _time:String = "day";
		protected var _asset:String = "A";
		protected var _mode:String = "normal";
		
		
		public function GameObject() 
		{
			updateAsset();
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
				_mode = "over";
				updateAsset();
			}
		}
		
		public function out():void
		{
			if (_interactive)
			{
				_mode = "normal";
				updateAsset();
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
		
		public function set time(value:String):void 
		{
			_time = value;
		}
		
		public function updateAsset () : void
		{
			gotoAndStop(_mode + "_" + _time + "_" + _asset);
		}
	}

}