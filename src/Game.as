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
	import flash.utils.setTimeout;
	
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
		private static var _arText : Array;
		private static var _textCallback:Function;
		private const _LETTER_INTERVAL : Number = 0.1;
		
		private static var _nextRoom:String = "";
		private static var _nextRoomPosition : Number;
		private static var _nextRoomCallback : Function;
		
		private static var _room : String = "porch";
		private static const _roomMap : Object = {
			porch : new Porch,
			foyer : new Foyer
			/*smpl1 : new SampleRoom,
			smpl2 : new SampleRoom2,*/
			/*porch : new Porch,
			foyer : new Foyer,
			livingroom : new LivingRoom*/
		};
		
		private static var _shade : Shape = new Shape();
		private static var _changingRooms : Boolean = false;
		private static var _changingPeriod : Boolean = false;
		
		// Teleport event list
		private static var _arTeleport : Array = [];
		
		// Day/Night event list
		private static var _arPeriod : Array = [];
		private static var _currentPeriod : int = 0;;
		
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
			
			var jsonArray : Array = [];
			var jsonObject : Object;
			var room : Room;
			
			jsonArray = (JSONLoader.loadFile("sceneElements.json") as Array);
			var el : SceneElement;
			for (var i : int = 0; i < jsonArray.length; i++)
			{
				jsonObject = jsonArray[i];
				room = _roomMap[jsonObject.room];
				if (room)
				{
					for (var j : int = 0; j < room.numChildren; j++)
					{
						if ((el = (room.getChildAt(j) as SceneElement)))
						{
							if (el.name == jsonObject.name)
							{
								el.loadData(jsonObject);
							}
						}
					}
				}
			}
			
			jsonArray = (JSONLoader.loadFile("switches.json") as Array);
			var l : LightSwitch;
			for (var i : int = 0; i < jsonArray.length; i++)
			{
				jsonObject = jsonArray[i];
				room = _roomMap[jsonObject.room];
				if (room)
				{
					for (var j : int = 0; j < room.numChildren; j++)
					{
						if ((l = (room.getChildAt(j) as LightSwitch)))
						{
							if (l.name == jsonObject.name)
							{
								l.loadData(jsonObject);
							}
						}
					}
				}
			}
			
			jsonArray = (JSONLoader.loadFile("shadows.json") as Array);
			var s : Shadow;
			for (var i : int = 0; i < jsonArray.length; i++)
			{
				jsonObject = jsonArray[i];
				room = _roomMap[jsonObject.room];
				if (room)
				{
					for (var j : int = 0; j < room.numChildren; j++)
					{
						if ((s = (room.getChildAt(j) as Shadow)))
						{
							if (s.name == jsonObject.name)
							{
								s.loadData(jsonObject);
							}
						}
					}
				}
			}
			
			_arTeleport = (JSONLoader.loadFile("teleports.json") as Array);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_shade.graphics.beginFill(0x000000);
			_shade.graphics.drawRect(0, 0, 1024, 768);
			_shade.graphics.endFill();
			
			_time = (new Date()).getTime();
			
			stage.frameRate = 30;
			stage.addEventListener(Event.ENTER_FRAME, run);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			
			_roomMap[_room].addChild(new Enemy ());
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
				fadeToBlack(function () : void
				{
					_changingRooms = false;
					_roomMap[_room].removePlayer();
					removeChild(_roomMap[_room]);
					
					_playerInstance.x = _nextRoomPosition;
					_room = _nextRoom;
					_nextRoom = "";
					_roomMap[_room].addPlayer();
					addChildAt(_roomMap[_room], 0);
					if (_nextRoomCallback != null) _nextRoomCallback();
				});
			}
			
			else if (_changingPeriod)
			{
				var event : Object = _arPeriod[_currentPeriod++];
				
				fadeToBlack(function () : void
				{
					_changingPeriod = false;
					for (var k : String in _roomMap)
					{
						_roomMap[k].updateAssets();
					}
				});
			}
			
			if (!_changingRooms && !_changingPeriod)
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
		
		public static function addToInventory(id : String) : void
		{
			_inventory.addItem(new InventoryItem(id));
		}
		
		public static function removeFromInventory(id : String) : void
		{
			_inventory.removeItem(id);
		}
		
		
		
		//Text typing methods
		public static function displayText(arText : Array, callback : Function = null) : void
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
			_arText = arText;
			_textCallback = callback;
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
		
		private static function closeText() : void
		{
			_textBox.text = "";
			_textBox.visible = false;
			_playerInstance.resetFlag(Player.INACTIVE);
			resetFlag(TYPING_TEXT);
			if (_textCallback != null) _textCallback();
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
		public static function setNextRoom (room : String, nextRoomPosition : Number, nextRoomCallback : Function = null) : void
		{
			_nextRoom = room;
			_nextRoomPosition = nextRoomPosition;
			_nextRoomCallback = nextRoomCallback;
		}
		
		public static function teleport (id : String) : void
		{
			var teleport : Object;
			for (var i : int = 0; i < _arTeleport.length; i++)
			{
				if (_arTeleport[i].name == id)
				{
					teleport = _arTeleport[i];
					break;
				}
			}
			
			setNextRoom (teleport.room, teleport.position, function () : void
			{
				_changingRooms = true;
				setTimeout(function () : void
				{
					_changingRooms = false;
					Game.displayText(teleport.text.split("\n\r"));
				}, 500);
			});
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
		
		
		
		//SceneElement spawn/destroy
		public static function changeSceneElement (id : String):Boolean
		{
			var r : Room;
			var found : Boolean = false;
			var el : SceneElement;
			for (var k : String in _roomMap)
			{
				r = _roomMap[k] as Room;
				for (var i : int = 0; i < r.numChildren; i++)
				{
					if ((el = (r.getChildAt(i) as SceneElement)))
					{
						if (el.name == id)
						{
							el.visible = !el.visible;
							found = true;
							break;
						}
					}
				}
				if (found) break;
			}
			
			return found;
		}
		
		
		
		//Puzzle spawn/destroy
		public static function changePuzzleElement (id : String):Boolean
		{
			var r : Room;
			var found : Boolean = false;
			var el : PuzzleElement;
			for (var k : String in _roomMap)
			{
				r = _roomMap[k] as Room;
				for (var i : int = 0; i < r.numChildren; i++)
				{
					if ((el = (r.getChildAt(i) as PuzzleElement)))
					{
						if (el.name == id)
						{
							el.visible = !el.visible;
							found = true;
							break;
						}
					}
				}
				if (found) break;
			}
			
			return found;
		}
		
		
		
		//Period change
		public static function periodChange () : void
		{
			_changingPeriod = true;
		}
		
		
		private function fadeToBlack (callback : Function) : void
		{
			_shade.alpha = 0;
			addChild(_shade);
			TweenLite.to(_shade, 0.5, { alpha : 1, onComplete : function () : void
			{
				callback();
				
				TweenLite.to(_shade, 0.5, { alpha : 0, ease:Quad.easeIn, onComplete : function () : void
				{
					removeChild(_shade);
				}});
			}});
		}
	}
}