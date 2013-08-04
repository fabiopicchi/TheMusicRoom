package 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.SetIntervalTimer;
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
		private static var _pStatus : int = 0;
		public static const NONE : int = 0;
		public static const TYPING_TEXT : int = 1 << 0;
		public static const PLAYING_CUTSCENE : int = 1 << 1;
		public static const INVENTORY_OPEN : int = 1 << 2;
		public static const PUZZLESCREEN_OPEN : int = 1 << 3;
		public static const CHANGING_ROOM : int = 1 << 4;
		public static const PERIOD_CHANGE : int = 1 << 5;
		public static const MAIN_MENU : int = 1 << 6;
		
		private static var _dt : Number = 0;
		private static var _time : Number = 0;
		
		private static var _playerInstance: Player = new Player();
		
		private var mainMenu : MainMenuClass = new MainMenuClass();
		
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
		
		private static var _room : String = "daddyRoom";
		public static const ROOM_MAP : Object = {
			bathroom1 : new Bathroom1,
			bathroom2 : new Bathroom2,
			centralHallway : new CentralHallway,
			daddyRoom : new DaddyRoom,
			dinnerRoom : new DinnerRoom,
			foyer : new Foyer,
			garden : new Garden,
			grandmaRoom : new GrandmaRoom,
			hallway : new Hallway,
			kitchen : new Kitchen,
			livingRoom : new LivingRoom,
			mainHallway : new MainHallway,
			musicHallway : new MusicHallway,
			nancyRoom : new NancyRoom,
			porch : new Porch,
			projectorRoom : new ProjectorRoom,
			upperHallway : new UpperHallway
		};
		
		private static var _shade : Shape = new Shape();
		
		private static var _arSceneElement : Array = [];
		private static var _arDoors : Array = [];
		private static var _arLightSwitches : Array = [];
		private static var _arLights : Array = [];
		
		// Teleport event list
		private static var _arTeleport : Array = [];
		
		// Day/Night event list
		private static var _arPeriod : Array = [];
		private static var _currentPeriod : int = 0;
		
		private static var _inventory : Inventory = new Inventory ();
		
		private static var _puzzleScreen : PuzzleScreen = null;
		
		public function Game():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			for (var k : String in ROOM_MAP)
			{
				ROOM_MAP[k].name = k;
			}
		}
		
		public static function debugDump () : void
		{
			var appPath:File = File.applicationDirectory.resolvePath("");
			var file : File;
			var fStream:FileStream;
			var room : Room;
			var j : int = 0;
			
			for (var k : String in ROOM_MAP)
			{
				room = ROOM_MAP[k];
				file = new File (appPath.nativePath + "/../logs/" + room.name + ".txt");
				fStream = new FileStream();
				fStream.open(file, FileMode.WRITE);
				fStream.writeUTFBytes("Room code: " + k + "\n");
				fStream.writeUTFBytes("    Object naming status: \n" + room.checkObjectNames() + "\n");
				
				if (room.getChildByName("area"))
					fStream.writeUTFBytes("    Has area: Yes\n");
				else
					fStream.writeUTFBytes("    Has area: No\n");
					
				if (room.getChildByName("back"))
					fStream.writeUTFBytes("    Has back: Yes\n");
				else
					fStream.writeUTFBytes("    Has back: No\n");
					
				if (room.getChildByName("front"))
					fStream.writeUTFBytes("    Has front: Yes\n");
				else
					fStream.writeUTFBytes("    Has front: No\n");
				
				fStream.writeUTFBytes ("\n");
				for (var i : int = 0; i < room.numChildren; i++)
				{
					var child : DisplayObject = room.getChildAt(i);
					if (child is Door)
					{
						fStream.writeUTFBytes ("	Object class: Door\n");
					}
					else if (child is SceneElement)
					{
						fStream.writeUTFBytes ("	Object class: SceneElement\n");
					}
					else if (child is LightSwitch)
					{
						fStream.writeUTFBytes ("	Object class: LightSwitch\n");
					}
					else if (child is Light)
					{
						fStream.writeUTFBytes ("	Object class: Light\n");
					}
					else if (child is PuzzleElement)
					{
						fStream.writeUTFBytes ("	Object class: PuzzleElement\n");
					}
					else
					{
						fStream.writeUTFBytes ("	Object class: " + getQualifiedClassName(child) + "\n");
					}
					fStream.writeUTFBytes ("		Name: " + child.name + "\n");
					fStream.writeUTFBytes ("		Position: (" + child.x + ", " + child.y + ")\n");
					fStream.writeUTFBytes ("		Dimensions: (" + child.width + ", " + child.height + ")\n");
					
					if (child is InteractiveElement)
					{
						fStream.writeUTFBytes ("		IsInteractive: Yes\n");
						if (room.getChildByName(child.name + "_h"))
							fStream.writeUTFBytes ("		Has hitbox: Yes\n");
						else 
							fStream.writeUTFBytes ("		Has hitbox: No\n");
						
						fStream.writeUTFBytes ("		Frame Names:\n");
						for (j = 1; j <= (child  as MovieClip).totalFrames; j++)
						{
							(child as MovieClip).gotoAndStop(j);
							fStream.writeUTFBytes ("			" + j + ": " + (child as MovieClip).currentFrameLabel + "\n");
						}
					}
					fStream.writeUTFBytes ("\n");
					
				}
				
				fStream.close();
			}
			
			file = new File (appPath.nativePath + "/../logs/sceneElementCheck.txt");
			fStream = new FileStream();
			fStream.open(file, FileMode.WRITE);
			for (j = 0; j < _arSceneElement.length; j++)
			{
				obj = _arSceneElement[j];
				room = ROOM_MAP[obj.room];
				
				if (!room)
				{
					fStream.writeUTFBytes("    Object " + obj.name + " has an invalid room name in the json file!");
				}
				else
				{
					if (room.getChildByName(obj.name))
					{
						fStream.writeUTFBytes("    Object " + obj.name + " succesfully found at room " + obj.room);
					}
					else
					{
						fStream.writeUTFBytes("    Object " + obj.name + " not found at room " + obj.room);
					}
				}
				fStream.writeUTFBytes ("\n");
			}
			
			file = new File (appPath.nativePath + "/../logs/doorCheck.txt");
			fStream = new FileStream();
			fStream.open(file, FileMode.WRITE);
			var obj : Object;
			for (j = 0; j < _arDoors.length; j++)
			{
				obj = _arDoors[j];
				room  = ROOM_MAP[obj.room];
				
				if (!room)
				{
					fStream.writeUTFBytes("    Object " + obj.name + " has an invalid room name in the json file!");
				}
				else
				{
					if (room.getChildByName(obj.name))
					{
						fStream.writeUTFBytes("    Object " + obj.name + " succesfully found at room " + obj.room);
					}
					else
					{
						fStream.writeUTFBytes("    Object " + obj.name + " not found at room " + obj.room);
					}
				}
				fStream.writeUTFBytes ("\n");
			}
			
			file = new File (appPath.nativePath + "/../logs/lightSwitchCheck.txt");
			fStream = new FileStream();
			fStream.open(file, FileMode.WRITE);
			for (j = 0; j < _arLightSwitches.length; j++)
			{
				obj = _arLightSwitches[j];
				room  = ROOM_MAP[obj.room];
				
				if (!room)
				{
					fStream.writeUTFBytes("    Object " + obj.name + " has an invalid room name in the json file!");
				}
				else
				{
					if (room.getChildByName(obj.name))
					{
						fStream.writeUTFBytes("    Object " + obj.name + " succesfully found at room " + obj.room);
					}
					else
					{
						fStream.writeUTFBytes("    Object " + obj.name + " not found at room " + obj.room);
					}
				}
				fStream.writeUTFBytes ("\n");
			}
			
			file = new File (appPath.nativePath + "/../logs/lightCheck.txt");
			fStream = new FileStream();
			fStream.open(file, FileMode.WRITE);
			for (j = 0; j < _arLights.length; j++)
			{
				obj = _arLights[j];
				room = ROOM_MAP[obj.room];
				
				if (!room)
				{
					fStream.writeUTFBytes("    Object " + obj.name + " has an invalid room name in the json file!");
				}
				else
				{
					if (room.getChildByName(obj.name))
					{
						fStream.writeUTFBytes("    Object " + obj.name + " succesfully found at room " + obj.room);
					}
					else
					{
						fStream.writeUTFBytes("    Object " + obj.name + " not found at room " + obj.room);
					}
				}
				fStream.writeUTFBytes ("\n");
			}
			fStream.close();
		}
		
		private function init(e:Event):void 
		{
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			loadJSONProperties("sceneElements.json", SceneElement);
			loadJSONProperties("switches.json", LightSwitch);
			loadJSONProperties("lights.json", Light);
			loadJSONProperties("doors.json", Door);
			loadJSONProperties("puzzleElements.json", PuzzleElement);
			
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
			
			debugDump();
			
			ROOM_MAP[_room].addPlayer();
			addChild(ROOM_MAP[_room]);
			
			_textBox = new TextField();
			addChild(_textBox);
			
			addChild(_inventory);
			_inventory.x = 0;
			_inventory.y = 768;
			
			var myFormat : TextFormat = new TextFormat("Comic Sans MS", 30, 0xFFFFFF);
			_textBox.defaultTextFormat = myFormat;
			
			for (var k : String in ROOM_MAP)
			{
				(ROOM_MAP[k] as Room).updateAssets();
			}
			
			setFlag(MAIN_MENU);
			
			addChild(mainMenu);
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
			var changedStatus : int = 0;
			if (_status != _pStatus)
			{
				changedStatus = (_status ^ _pStatus);
				_pStatus = _status;
			}
			
			if ((_status & MAIN_MENU) == MAIN_MENU)
			{
				if (keyJustPressed(Action.DOWN))
				{
					mainMenu.nextItem();
				}
				else if (keyJustPressed(Action.UP))
				{
					mainMenu.previousItem();
				}
				else if (keyJustPressed(Action.INTERACT))
				{
					switch (mainMenu.select())
					{
						case MainMenu.ENTER:
							fadeToBlack(function () : void
							{
								resetFlag(MAIN_MENU);
								removeChild(mainMenu);
							});
							break;
						
						case MainMenu.LOAD:
							
							break;
						
						case MainMenu.CREDITS:
							
							break;
						
						case MainMenu.RUN_AWAY:
							NativeApplication.nativeApplication.exit();
							break;
					}
				}
				
				return;
			}
			
			if ((changedStatus & CHANGING_ROOM) == CHANGING_ROOM && (_status & CHANGING_ROOM) == CHANGING_ROOM)
			{
				fadeToBlack(function () : void
				{
					resetFlag(CHANGING_ROOM);
					ROOM_MAP[_room].removePlayer();
					removeChild(ROOM_MAP[_room]);
					
					_playerInstance.x = _nextRoomPosition;
					_room = _nextRoom;
					_nextRoom = "";
					ROOM_MAP[_room].addPlayer();
					addChildAt(ROOM_MAP[_room], 0);
					if (_nextRoomCallback != null) _nextRoomCallback();
				});
			}
			
			else if ((changedStatus & PERIOD_CHANGE) == PERIOD_CHANGE && (_status & PERIOD_CHANGE) == PERIOD_CHANGE)
			{
				var event : Object = _arPeriod[_currentPeriod++];
				fadeToBlack(function () : void
				{
					resetFlag(PERIOD_CHANGE);
					for (var k : String in ROOM_MAP)
					{
						ROOM_MAP[k].updateAssets();
					}
				});
			}
			
			if ((_status & PERIOD_CHANGE) != PERIOD_CHANGE && (_status & CHANGING_ROOM) != CHANGING_ROOM)
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
				else if ((_status & PUZZLESCREEN_OPEN) == PUZZLESCREEN_OPEN)
				{
					if ((changedStatus & PUZZLESCREEN_OPEN) == PUZZLESCREEN_OPEN)
					{
						fadeToBlack(function () : void
						{
							addChild (_puzzleScreen);
						});
					}
					if (contains(_puzzleScreen))
					{
						_puzzleScreen.update();
					}
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
					
					if (keyJustPressed(Action.BACK))
					{
						periodChange();
					}
					
					for (var i : int = 0; i < numChildren; i++)
					{
						var e : Entity;
						if ((e = (getChildAt(i) as Entity)) && !(e is Room))
						{
							e.update();
						}
					}
					
					for (var k : String in ROOM_MAP)
					{
						ROOM_MAP[k].update();
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
				setFlag(CHANGING_ROOM);
				setTimeout(function () : void
				{
					resetFlag(CHANGING_ROOM);
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
			for (var k : String in ROOM_MAP)
			{
				r = ROOM_MAP[k] as Room;
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
			for (var k : String in ROOM_MAP)
			{
				r = ROOM_MAP[k] as Room;
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
			setFlag(PERIOD_CHANGE);
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
		
		
		//go to puzzle screen
		public static function puzzleScreen (element : PuzzleElement) : void
		{
			_puzzleScreen = new ToyBoxScreen();
			_puzzleScreen.initPuzzleScreen(element);
			setFlag(PUZZLESCREEN_OPEN);
		}
		
		
		
		//load JSON properties
		private function loadJSONProperties (fileName : String, cl : Class) : void
		{
			var jsonArray : Array = [];
			var jsonObject : Object;
			var room : Room;
			jsonArray = (JSONLoader.loadFile(fileName) as Array);
			
			if (getQualifiedClassName(cl) == getQualifiedClassName(SceneElement))
			{
				_arSceneElement = jsonArray;
			}
			else if (getQualifiedClassName(cl) == getQualifiedClassName(Light))
			{
				_arLights = jsonArray;
			}
			else if (getQualifiedClassName(cl) == getQualifiedClassName(LightSwitch))
			{
				_arLightSwitches = jsonArray;
			}
			else if (getQualifiedClassName(cl) == getQualifiedClassName(Door))
			{
				_arDoors = jsonArray;
			}
			
			var obj : DisplayObject;
			for (var i : int = 0; i < jsonArray.length; i++)
			{
				jsonObject = jsonArray[i];
				room = ROOM_MAP[jsonObject.room];
				if (room)
				{
					for (var j : int = 0; j < room.numChildren; j++)
					{
						if (jsonObject.room == "daddyRoom")
						{
							trace (getQualifiedClassName(room.getChildAt(j)));
						}
						if ((obj = room.getChildAt(j)) is cl)
						{
							if (obj.name == jsonObject.name)
							{
								(obj as cl).loadData(jsonObject);
							}
						}
					}
				}
			}
		}
	}
}