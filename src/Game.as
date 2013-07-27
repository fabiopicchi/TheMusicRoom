package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Game extends Sprite 
	{
		private static var keyMap : int = 0;
		private static var keyState : int = 0;
		private static var pKeyState : int = 0;
		
		private static var _dt : Number = 0;
		private static var _time : Number = 0;
		
		private var et : Entity;
		private var _room : Room;
		
		private static var _textField : TextField;
		
		public function Game():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_time = (new Date()).getTime();
			
			stage.frameRate = 30;
			stage.addEventListener(Event.ENTER_FRAME, run);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			
			_room = new SampleRoom();
			addChild(_room);
			
			_textField = new TextField();
			addChild(_textField);
		}
		
		private function run(e:Event):void 
		{
			pKeyState = keyState;
			keyState = keyMap;
			
			var cTime : Number = (new Date()).getTime();
			_dt = cTime - _time;
			_time = cTime;
			
			update();
			draw();
		}
		
		private function update():void 
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
		
		private function draw():void 
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
		
		private function onKeyReleased(e:KeyboardEvent):void 
		{
			var action : int;
			if ((action = Action.getAction(e.keyCode)) != Action.NONE)
			{
				keyMap &= (~action);
			}
		}
		
		private function onKeyPressed(e:KeyboardEvent):void 
		{
			var action : int;
			if ((action = Action.getAction(e.keyCode)) != Action.NONE)
			{
				keyMap |= action;
			}
		}	
		
		public static function keyPressed(action:int) : Boolean
		{
			return ((keyState & action) == action);
		}
		
		public static function keyJustPressed(action:int) : Boolean
		{
			return (((keyState ^ pKeyState) & action) == action && keyPressed(action));
		}
		
		public static function keyJustReleased(action:int) : Boolean
		{
			return (((keyState ^ pKeyState) & action) == action && !keyPressed(action));
		}
		
		public static function get dt():Number 
		{
			return _dt;
		}
		
		public static function displayText(text:String) : void
		{
			_textField.text = text;
			_textField.width = 824;
			_textField.height = 200;
			_textField.x = 100;
			_textField.y = 468;
			_textField.multiline = true;
			
			var myFormat : TextFormat;
			myFormat.font = "Verdana";
			myFormat.color = 0xFFFFFF;
			myFormat.size = 10;
			
			_textField.defaultTextFormat = myFormat;
		}
	}
}