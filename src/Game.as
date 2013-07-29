package 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
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
		private static const PLAYING_CUTSCENE : int = 1 << 1;
		private static const INVENTORY_OPEN : int = 1 << 2;
		
		private static var _dt : Number = 0;
		private static var _time : Number = 0;
		
		private static var _playerInstance: Player = new Player();
		
		private static var _text : String;
		private static var _textBox : TextField;
		private static var _textTime : Number = 0;
		private static var _textCounter : int = 0;
		private static var _pageCounter : int = 0;
		private static var _typing : Boolean = false;
		private static var _waitingInput : Boolean = false;
		private static var _arText : Array = [
			"Qwerty uiop asd fghjkl\nçzxcvbnm qwe",
			"Uiop asdfg hjkl"
		];
		private const _LETTER_INTERVAL : Number = 0.1;
		
		private static var _nextRoom:String = "";
		private var _room : String = "foyer";
		private var _roomMap : Object = {
			/*smpl1 : new SampleRoom,
			smpl2 : new SampleRoom2,*/
			porch : new Porch,
			foyer : new Foyer,
			livingroom : new LivingRoom
		};
		
		private var _shade : Shape = new Shape();
		private var _changingRooms : Boolean = false;
		
		private static var _inventory : Inventory = new Inventory ();
		
		public function Game():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			for (var k : String in _roomMap)
			{
				_roomMap[k].name = k;
			}
		}
		
		private function init(e:Event):void 
		{
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_shade.graphics.beginFill(0x000000);
			_shade.graphics.drawRect(0, 0, 1024, 768);
			_shade.graphics.endFill();
			
			_time = (new Date()).getTime();
			
			stage.frameRate = 30;
			stage.addEventListener(Event.ENTER_FRAME, run);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			
			_roomMap[_room].addChild(new Enemy());
			_roomMap[_room].addPlayer();
			addChild(_roomMap[_room]);
			
			_textBox = new TextField();
			addChild(_textBox);
			
			addChild(_inventory);
			_inventory.x = 0;
			_inventory.y = 768;
			
			var myFormat : TextFormat = new TextFormat("Comic Sans MS", 30, 0xFFFFFF);
			_textBox.defaultTextFormat = myFormat;
		}
		
		private function run(e:Event):void 
		{	
			pKeyState = keyState;
			keyState = keyMap;
			
			var cTime : Number = (new Date()).getTime();
			_dt = (cTime - _time) / 1000;
			_time = cTime;
			
			update();
			draw();
		}
		
		private function update():void 
		{
			if (!_changingRooms && _nextRoom != "")
			{
				_changingRooms = true;
				_shade.alpha = 0;
				addChild(_shade);
				TweenLite.to(_shade, 0.5, { alpha : 1, onComplete : function () : void
				{
					_changingRooms = false;
					_roomMap[_room].removePlayer();
					removeChild(_roomMap[_room]);
					
					var nextDoor : DisplayObject;
					nextDoor = (_roomMap[_nextRoom] as Room).getChildByName("h" + _nextRoom + "_" + _room);
					if (!nextDoor)
						nextDoor = (_roomMap[_nextRoom] as Room).getChildByName("o" + _nextRoom + "_" + _room);
						
					_playerInstance.x = nextDoor.x + (nextDoor.width - _playerInstance.width) / 2;
					_room = _nextRoom;
					_nextRoom = "";
					_roomMap[_room].addPlayer();
					addChildAt(_roomMap[_room], 0);
					
					TweenLite.to(_shade, 0.5, { alpha : 0, ease:Quad.easeIn, onComplete : function () : void
					{
						removeChild(_shade);
					}});
				}});
			}
			
			if (!_changingRooms)
			{
				if ((_status & INVENTORY_OPEN) == INVENTORY_OPEN)
				{
					if (keyJustPressed(Action.LEFT))
					{
						_inventory.nextLeft();
					}
					else if (keyJustPressed(Action.RIGHT))
					{
						_inventory.nextRight();
					}
				}
				
				if ((_status & TYPING_TEXT) == TYPING_TEXT)
				{
					typeText();
				}
				
				else
				{
					if (keyJustPressed(Action.INVENTORY))
					{
						if ((_status & INVENTORY_OPEN) != INVENTORY_OPEN)
						{
							showInventory();
							_status |= INVENTORY_OPEN;
							_playerInstance.setFlag(Player.INACTIVE);
						}
						else
						{
							hideInventory();
							_status &= ~INVENTORY_OPEN;
							_playerInstance.resetFlag(Player.INACTIVE);
						}
					}
					
					for (var i : int = 0; i < numChildren; i++)
					{
						var e : Entity;
						if ((e = (getChildAt(i) as Entity)) && !(e is Room))
						{
							e.update();
						}
					}
					
					for (var k : String in _roomMap)
					{
						_roomMap[k].update();
					}
				}
			}
		}
		
		private function draw():void 
		{
			for (var i : int = 0; i < numChildren; i++)
			{
				var e : Entity;
				if ((e = (getChildAt(i) as Entity)) && !(e is Room))
				{
					e.draw();
				}
			}
		}
		
		
		
		//Inventory control methods
		private function showInventory():void 
		{
			TweenLite.to(_inventory, 0.5, { y : 668 } );
		}
		
		private function hideInventory():void 
		{
			TweenLite.to(_inventory, 0.5, { y : 768 } );
		}
		
		
		
		//Text typing methods
		public static function displayText(id:String) : void
		{
			_textBox.visible = true;
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
			
			_textCounter = 0;
			_pageCounter = 0;
			_textTime = 0;
			_waitingInput = false;
			_text = _arText[_pageCounter];
			_playerInstance.setFlag(Player.INACTIVE);
			setFlag(TYPING_TEXT);
		}
		
		private function typeText() : void
		{
			_textTime += _dt;
			
			if (!_waitingInput )
			{
				if (keyJustPressed(Action.INTERACT))
				{
					_textCounter = _text.length;
					_textTime = _LETTER_INTERVAL;
				}
				if (_textTime >= _LETTER_INTERVAL)
				{
					_textTime = 0;
					_textBox.text = _text.slice(0, _textCounter);
					if (_textCounter == _text.length)
					{
						_textCounter = 0;
						_textTime = 0;
						_waitingInput = true;
					}
					else
					{
						_textCounter++;
					}
				}
			}
			else if (keyJustPressed(Action.INTERACT))
			{
				_waitingInput = false;
				_pageCounter++;
				if (_pageCounter < _arText.length)
				{
					_text = _arText[_pageCounter];
				}
				else
				{
					Game.closeText();
				}
			}
		}
		
		public static function completedText() : Boolean
		{
			_textCounter = 0;
			_textTime = 0;
			
			if (_textBox.text.length == _text.length)
			{
				return true;
			}
			else
			{
				_textBox.text = _text;
				resetFlag(TYPING_TEXT);
				return false;
			}
		}
		
		public static function closeText() : void
		{
			_textBox.text = "";
			_textBox.visible = false;
			_playerInstance.resetFlag(Player.INACTIVE);
			resetFlag(TYPING_TEXT);
		}
		
		
		
		//Game state control
		public static function setFlag (flag : int) : void
		{
			_status |= flag;
		}
		
		public static function resetFlag (flag : int) : void
		{
			_status &= ~flag;
		}
		
		
		
		//Room control
		public static function setNextRoom (room : String) : void
		{
			_nextRoom = room;
		}
		
		
		
		//Input API
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
		
		
		
		//Keyboard Events
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
		
		
		
		//Static getters
		public static function get dt():Number 
		{
			return _dt;
		}
		
		public static function get playerInstance():Player 
		{
			return _playerInstance;
		}
	}
}