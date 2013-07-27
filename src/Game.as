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
		
		private static var _status : int = 0;
		
		private static const NONE : int = 0;
		private static const TYPING_TEXT : int = 1 << 0;
		
		private static var _dt : Number = 0;
		private static var _time : Number = 0;
		
		private var et : Entity;
		private var _room : Room;
		
		private static var _text : String;
		private static var _textBox : TextField;
		private var _textTime : Number = 0;
		private var _textCounter : Number = 0;
		private const _LETTER_INTERVAL : Number = 100;
		
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
			
			_textBox = new TextField();
			addChild(_textBox);
			
			var myFormat : TextFormat = new TextFormat("Verdana", 30, 0xFFFFFF);
			_textBox.setTextFormat(myFormat);
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
				
				if ((_status & TYPING_TEXT) == TYPING_TEXT)
				{
					typeText();
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
		
		public static function setFlag (flag : int) : void
		{
			_status |= flag;
		}
		
		public static function resetFlag (flag : int) : void
		{
			_status &= ~flag;
		}
		
		public static function displayText(text:String) : void
		{
			_textBox.width = 424;
			_textBox.height = 100;
			_textBox.x = 300;
			_textBox.y = 568;
			_textBox.selectable = false;
			_textBox.multiline = true;
			_textBox.wordWrap = true;
			_textBox.mouseEnabled = false;
			_textBox.border = true;
			_textBox.borderColor = 0xFFFFFF;
			
			_text = text;
			setFlag(TYPING_TEXT);
		}
		
		private function typeText() : void
		{
			_textTime += _dt
			
			if (_textTime >= _LETTER_INTERVAL)
			{
				_textTime = 0;
				_textBox.text = _text.slice(0, _textCounter);
				if (_textCounter == _text.length - 1)
				{
					_textCounter = 0;
					_textTime = 0;
					resetFlag(TYPING_TEXT);
				}
				else
				{
					_textCounter++
				}
			}
		}
		
		public static function scrollText() : void
		{
			_textBox.scrollV++;
		}
	}
}