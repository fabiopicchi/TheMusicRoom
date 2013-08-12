package 
{
	import com.greensock.easing.Quad;
	import com.greensock.plugins.SoundTransformPlugin;
	import com.greensock.plugins.TweenPlugin;
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
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.SetIntervalTimer;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Game extends Sprite 
	{
		// Sound channels
		private static const NUM_LOOPS : int = int.MAX_VALUE;
		private static var _musicChannel1 : SoundChannel;
		private static var _musicChannel2 : SoundChannel;
		
		private static var _playerSfxChannel: SoundChannel;
		private static var _enemySfxChannel : SoundChannel;
		private static var _enemySfxChannel2 : SoundChannel;
		private static var _generalSfxChannel : SoundChannel;
		private static var _loopedSfxChannel : SoundChannel;
		
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
		public static const CHECKING_INVENTORY_ITEM : int = 1 << 7;
		
		private static var _dt : Number = 0;
		private static var _time : Number = 0;
		
		private static var _playerInstance: Player = new Player();
		private static var _closingEyes : ClosingEyes = new ClosingEyes ();
		
		private var mainMenu : MainMenuClass = new MainMenuClass();
		
		// Dialog text box
		private static var _text : String;
		private static var _textBox : TextBox;
		private static var _textTime : Number = 0;
		private static var _textCounter : int = 0;
		private static var _pageCounter : int = 0;
		private static var _typing : Boolean = false;
		private static var _waitingInput : Boolean = false;
		private static var _arText : Array;
		private static var _textCallback:Function;
		private const _LETTER_INTERVAL : Number = 0.1;
		
		// Room name
		private static var _roomNameBox : TextField;
		
		private static var _nextRoom:String = "";
		private static var _nextRoomPosition : Number;
		
		private static var _room : String = "porch";
		public static const ROOM_MAP : Object = {
			balcony : new Balcony,
			basement : new Basement,
			basementHallway : new BasementHallway,
			bathroom1 : new Bathroom1,
			bathroom2 : new Bathroom2,
			bathroom3 : new Bathroom3,
			bollierRoom : new BoilerRoom,
			centralHallway : new CentralHallway,
			daddyRoom : new DaddyRoom,
			darkPassage : new DarkPassage,
			dinnerRoom : new DinnerRoom,
			foyer : new Foyer,
			garden : new Garden,
			grandmaRoom : new GrandmaRoom,
			guestHallway : new GuestHallway,
			hallway : new Hallway,
			ivyGuestroom : new IvyGuestroom,
			kitchen : new Kitchen,
			lavenderGuestroom : new LavenderGuestroom,
			library : new Library,
			livingRoom : new LivingRoom,
			mainHallway : new MainHallway,
			masterSuite : new MasterSuite,
			musicHallway : new MusicHallway,
			nancyRoom : new NancyRoom,
			orchidGuestroom : new OrchidGuestroom,
			porch : new Porch,
			projectorRoom : new ProjectorRoom,
			secretStorage : new SecretStorage,
			secretStudy : new SecretStudy,
			storage : new Storage,
			study : new Study,
			upperHallway : new UpperHallway,
			wineCellar : new WineCellar
		};
		
		private static var _shade : Shape = new Shape();
		
		private static var _arSceneElement : Array = [];
		private static var _arDoors : Array = [];
		private static var _arLightSwitches : Array = [];
		private static var _arLights : Array = [];
		private static var _arElementsCreated : Array = [];
		
		// Inventory items list
		private static var _arInventoryItems: Array = [];
		
		// Teleport event list
		private static var _arTeleport : Array = [];
		
		// Day/Night event list
		private static var _arPeriod : Array = [];
		private static var _currentPeriod : int = 0;
		
		private static var _inventory : Inventory = new Inventory ();
		private static var _inventoryItemScreen : MovieClip;
		private static var _nextPage : int = 0;
		
		private static var _puzzleScreen : PuzzleScreen = null;
		private static var _fadeCallback : Function;
		private static var _periodChangeCallback : Function;
		
		public static const DEFAULT_TEXT_NO_SENSE : String = "Edgard: I don't think this would make sense.";
		public static const DEFAULT_TEXT_NO_ITEMS: String = "Edgard: I don't seem to have everything I need to solve this.";
		
		public function Game():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			TweenPlugin.activate([SoundTransformPlugin]);
			Font.registerFont(BookmanOld);
			
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
				
				if (room.getChildByName("shadow"))
					fStream.writeUTFBytes("    Has shadow: Yes\n");
				else
					fStream.writeUTFBytes("    Has shadow: No\n");
				
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
						if (room.getChildByName(obj.name) is SceneElement)
							fStream.writeUTFBytes(" -- Class(OK)");
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
						if (room.getChildByName(obj.name) is Door)
							fStream.writeUTFBytes(" -- Class(OK)");
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
						if (room.getChildByName(obj.name) is LightSwitch)
							fStream.writeUTFBytes(" -- Class(OK)");
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
						if (room.getChildByName(obj.name) is Light)
							fStream.writeUTFBytes(" -- Class(OK)");
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
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_time = (new Date()).getTime();
			
			stage.frameRate = 30;
			stage.addEventListener(Event.ENTER_FRAME, run);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			
			loadConfig();
			//debugDump();
			
			_shade.graphics.beginFill(0x000000);
			_shade.graphics.drawRect(0, 0, 1024, 768);
			_shade.graphics.endFill();
			
			ROOM_MAP[_room].addPlayer();
			//ROOM_MAP[_room].addChild(new Enemy);
			addChild(ROOM_MAP[_room]);
			
			_roomNameBox = new TextField ();
			var format : TextFormat = new TextFormat ();
			format.font = (new BookmanOld()).fontName;
			format.size = 24;
			format.color = 0xFFFFFF;
			_roomNameBox.defaultTextFormat = format;
			_roomNameBox.height = 100;
			_roomNameBox.width = 200;
			_roomNameBox.x = -200;
			_roomNameBox.y = 30;
			addChild(_roomNameBox);
			
			addChild(_inventory);
			_inventory.x = 0;
			_inventory.y = 705;
			
			_textBox = new TextBox();
			_textBox.visible = false;
			_textBox.y = 518;
			_textBox.x = 58;
			addChild(_textBox);
			
			addChild(_closingEyes);
			_closingEyes.gotoAndStop("opened");
			
			for (var k : String in ROOM_MAP)
			{
				for (var i : int = 0; i < (ROOM_MAP[k] as Room).numChildren; i++)
				{
					if (_arElementsCreated.indexOf((ROOM_MAP[k] as Room).getChildAt(i).name) != -1)
					{
						(ROOM_MAP[k] as Room).getChildAt(i).visible = false;
					}
				}
				(ROOM_MAP[k] as Room).updateAssets(_currentPeriod);
			}
			
			_musicChannel1 = (new DayTheme ()).play(0, NUM_LOOPS);
			setFlag(MAIN_MENU);
			addChild(mainMenu);
			mainMenu.gotoAndStop(1);
		}
		
		public function addElementsCreated (jsonArray : Array) : void
		{
			var i : int = 0;
			var j : int = 0;
			var ar : Array;
			for (i = 0; i < jsonArray.length; i++)
			{
				if ((ar = (jsonArray[i].elementsCreated as Array)))
				{
					for (j = 0; j < ar.length; j++)
					{
						_arElementsCreated.push(ar[j]);
					}
				}
			}
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
				if (mainMenu.currentFrame == 1)
				{
					if (keyJustPressed(Action.DOWN))
					{
						mainMenu.nextItem();
					}
					else if (keyJustPressed(Action.UP))
					{
						mainMenu.previousItem();
					}
				}
				if (keyJustPressed(Action.INTERACT))
				{
					if (mainMenu.currentFrame == 1)
					{
						switch (mainMenu.select())
						{
							case MainMenu.ENTER:
								fadeToBlack(function () : void
								{
									resetFlag(MAIN_MENU);
									removeChild(mainMenu);
									Game.displayName(ROOM_MAP[_room].displayName);
								});
								break;
							
							case MainMenu.LOAD:
								fadeToBlack(function () : void
								{
									resetFlag(MAIN_MENU);
									removeChild(mainMenu);
									Game.displayName(ROOM_MAP[_room].displayName);
								});
								break;
							
							case MainMenu.CREDITS:
								fadeToBlack(function () : void
								{
									mainMenu.gotoAndStop(2);
								});
								break;
							
							case MainMenu.RUN_AWAY:
								NativeApplication.nativeApplication.exit();
								break;
						}
					}
					else
					{
						fadeToBlack(function () : void
						{
							mainMenu.gotoAndStop(1);
							mainMenu.previousItem();
							mainMenu.nextItem();
						});
					}
				}
				
				return;
			}
			
			
			if ((changedStatus & PUZZLESCREEN_OPEN) == PUZZLESCREEN_OPEN && (_status & PUZZLESCREEN_OPEN) != PUZZLESCREEN_OPEN)
			{
				fadeToBlack(function () : void
				{
					removeChild(_puzzleScreen);
					_puzzleScreen = null;
					if (_fadeCallback != null) _fadeCallback();
				});
			}
			
			if ((changedStatus & CHANGING_ROOM) == CHANGING_ROOM && (_status & CHANGING_ROOM) == CHANGING_ROOM)
			{
				fadeToBlack(function () : void
				{
					if ((_status & PERIOD_CHANGE) == PERIOD_CHANGE)
					{
						onPeriodChange();
					}
					
					_playerInstance.x = _nextRoomPosition;
					
					resetFlag(CHANGING_ROOM);
					
					if (_loopedSfxChannel != null)
					{
						_loopedSfxChannel.stop();
						_loopedSfxChannel = null;
					}
					
					//removes old room
					ROOM_MAP[_room].removePlayer();
					(ROOM_MAP[_room] as Room).resetScroll();
					removeChild(ROOM_MAP[_room]);
					_room = _nextRoom;
					_nextRoom = "";
					
					//adds new room
					ROOM_MAP[_room].addPlayer();
					ROOM_MAP[_room].update();
					ROOM_MAP[_room].onEnter();
					addChildAt(ROOM_MAP[_room], 0);
					
					if (_fadeCallback != null) _fadeCallback();
					
					Game.displayName(ROOM_MAP[_room].displayName);
				});
			}
			
			else if ((changedStatus & PERIOD_CHANGE) == PERIOD_CHANGE && (_status & PERIOD_CHANGE) == PERIOD_CHANGE)
			{
				fadeToBlack(function () : void
				{
					onPeriodChange();
				});
			}
			
			if ((_status & PERIOD_CHANGE) != PERIOD_CHANGE && (_status & CHANGING_ROOM) != CHANGING_ROOM)
			{
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
							if (_puzzleScreen.type == PuzzleElement.INSERT_SLOT)
							{
								showInventory();
								addChildAt (_puzzleScreen, getChildIndex(_inventory));
							}
							else
							{
								addChildAt (_puzzleScreen, getChildIndex(_textBox));
							}
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
						}
						else
						{
							hideInventory();
						}
					}
					
					for (var k : String in ROOM_MAP)
					{
						ROOM_MAP[k].update();
					}
				}
				
				if ((_pStatus & INVENTORY_OPEN) == INVENTORY_OPEN)
				{
					if ((changedStatus  & CHECKING_INVENTORY_ITEM) == CHECKING_INVENTORY_ITEM && (_status & CHECKING_INVENTORY_ITEM) == CHECKING_INVENTORY_ITEM)
					{
						fadeToBlack(function () : void
						{
							addChildAt(_inventoryItemScreen, getChildIndex(_textBox));
							_inventoryItemScreen.gotoAndStop(_nextPage = 1);
						});
					}
					
					if ((_status & CHECKING_INVENTORY_ITEM) != CHECKING_INVENTORY_ITEM)
					{
						if (keyJustPressed(Action.LEFT))
						{
							_inventory.nextLeft();
						}
						else if (keyJustPressed(Action.RIGHT))
						{
							_inventory.nextRight();
						}
						
						if ((_status & PUZZLESCREEN_OPEN) != PUZZLESCREEN_OPEN)
						{
							if (keyJustPressed(Action.INTERACT))
							{
								var item : InventoryItem = getInventoryItem(false);
								if (item.itemType == InventoryItem.USABLE)
								{
									hideInventory();
									if (_playerInstance.gameObject as SceneElement)
									{
										_playerInstance.gameObject.interact(item);
									}
									else
									{
										displayText([DEFAULT_TEXT_NO_SENSE]);
									}
								}
								else
								{
									setFlag (CHECKING_INVENTORY_ITEM);
									_inventoryItemScreen = getItemScreen(item.id);
								}
							}
						}
					}
					else if (contains(_inventoryItemScreen))
					{
						if (keyJustPressed(Action.LEFT))
						{
							if (_inventoryItemScreen.currentFrame != 1 && _inventoryItemScreen.currentFrame == _nextPage)
							{
								_nextPage = _inventoryItemScreen.currentFrame - 1;
								fadeToBlack (function () : void
								{
									_inventoryItemScreen.gotoAndStop(_inventoryItemScreen.currentFrame - 1);
								});
							}
						}
						else if (keyJustPressed(Action.RIGHT))
						{
							if (_inventoryItemScreen.currentFrame != _inventoryItemScreen.totalFrames && _inventoryItemScreen.currentFrame == _nextPage)
							{
								_nextPage = _inventoryItemScreen.currentFrame + 1;
								fadeToBlack (function () : void
								{
									_inventoryItemScreen.gotoAndStop(_inventoryItemScreen.currentFrame + 1);
								});
							}
						}
						else if (keyJustPressed(Action.BACK))
						{
							resetFlag(CHECKING_INVENTORY_ITEM);
							fadeToBlack(function () : void
							{
								removeChild(_inventoryItemScreen);
								_inventoryItemScreen = null;
							});
						}
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
		public static function showInventory():void 
		{
			TweenLite.to(_inventory, 0.5, { y : 563 } );
			_status |= INVENTORY_OPEN;
			_playerInstance.setFlag(Player.INACTIVE);
		}
		
		public static function hideInventory():void 
		{
			TweenLite.to(_inventory, 0.5, { y : 705 } );
			_status &= ~INVENTORY_OPEN;
			_playerInstance.resetFlag(Player.INACTIVE);
		}
		
		public static function addToInventory(id : String, playSound : Boolean = true) : void
		{
			if (playSound) playSfx(ITEM_GOT);
			for (var i : int = 0; i < _arInventoryItems.length; i++)
			{
				if (_arInventoryItems[i].name == id)
				{
					_inventory.addItem(new InventoryItem(_arInventoryItems[i]));
					break;
				}
			}
		}
		
		public static function removeFromInventory(hide : Boolean) : InventoryItem
		{
			if (hide)
				hideInventory();
			return _inventory.removeItem();
		}
		
		public static function getInventoryItem (hide : Boolean) : InventoryItem
		{
			if (hide)
				hideInventory();
			return _inventory.getItem();
		}
		
		
		
		//Text typing methods
		public static function displayText(arText : Array, callback : Function = null) : void
		{
			_textBox.visible = true;
			
			_textCounter = 0;
			_pageCounter = 0;
			_textTime = 0;
			_waitingInput = false;
			_arText = arText;
			_textCallback = callback;
			_playerInstance.setFlag(Player.INACTIVE);
			setFlag(TYPING_TEXT);
			nextText();
		}
		
		private static function nextText () : void
		{
			_waitingInput = false;
			if (_pageCounter < _arText.length)
			{
				_text = _arText[_pageCounter++].split("#lb").join('\n');
			}
			else
			{
				closeText();
			}
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
				nextText();
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
		
		
		
		//Room name display API
		private static var _roomNameBoxTimeout : int = -1;
		public static function displayName (name : String) : void
		{
			var delay : Number = 0.5;
			_roomNameBox.text = name;
			TweenLite.killTweensOf(_roomNameBox);
			
			if (_roomNameBoxTimeout != -1)
			{
				delay = 0;
				clearTimeout (_roomNameBoxTimeout);
			}
			TweenLite.to(_roomNameBox, 0.5, { delay : delay, x : 30, onComplete : function () : void
			{
				_roomNameBoxTimeout = setTimeout (function () : void
				{
					TweenLite.to(_roomNameBox, 0.5, { x : -200 } );
					_roomNameBoxTimeout = -1;
				}, 1000);
			}});
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
		
		
		
		//Closing eyes effect
		public static function closeEyes () : void 
		{
			_closingEyes.gotoAndPlay("close");
		}
		
		public static function openEyes () : void 
		{
			_closingEyes.gotoAndPlay("open");
		}
		
		
		
		//Room control
		public static function setNextRoom (room : String, nextRoomPosition : Number, nextRoomCallback : Function = null) : void
		{
			_nextRoom = room;
			_nextRoomPosition = nextRoomPosition;
			_fadeCallback = nextRoomCallback;
			setFlag(CHANGING_ROOM);
		}
		
		public static function teleport (id : String, callback : Function = null) : void
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
				if (callback != null)
				{
					callback();
				}
				setTimeout(function () : void
				{					
					resetFlag(CHANGING_ROOM);
					if ((teleport.text as String) != "")
					{
						Game.displayText((teleport.text as String).split("#pb"));
					}
				}, 500);
			});
		}
		
		public static function teleportHit (callback : Function = null) : void
		{
			setNextRoom ("daddyRoom", 300, function () : void
			{
				setFlag(CHANGING_ROOM);
				if (callback != null)
				{
					callback();
				}
				setTimeout(function () : void
				{					
					resetFlag(CHANGING_ROOM);
					Game.displayText(["Edgar: I'd better be more careful next time."]);
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
		public static function changeElement (id : String, setElement:Boolean):Boolean
		{
			var r : Room;
			var found : Boolean = false;
			var el : InteractiveElement;
			for (var k : String in ROOM_MAP)
			{
				r = ROOM_MAP[k] as Room;
				for (var i : int = 0; i < r.numChildren; i++)
				{
					if ((el = (r.getChildAt(i) as InteractiveElement)))
					{
						if (el.name == id)
						{
							el.visible = setElement;
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
		public static function periodChange (callback : Function = null) : void
		{
			setFlag(PERIOD_CHANGE);
			if (callback != null)
			{
				_fadeCallback = function () : void
				{
					_fadeCallback();
					callback();
				}
			}
		}
		
		private function onPeriodChange () : void
		{
			var event : Object = _arPeriod[_currentPeriod++];
			var i : int = 0;
			for (i = 0; i < event.elementsCreated.length; i++)
			{
				Game.changeElement(event.elementsCreated[i], true);
			}
			for (i = 0; i < event.elementsDestroyed.length; i++)
			{
				Game.changeElement(event.elementsDestroyed[i], false);
			}
			_musicChannel1.stop();
			if (_currentPeriod % 2 == 1)
			{
				_musicChannel1 = (new NightTheme ()).play(0, NUM_LOOPS);
			}
			else
			{
				_musicChannel1 = (new DayTheme ()).play(0, NUM_LOOPS);
			}
			resetFlag(PERIOD_CHANGE);
			for (var k : String in ROOM_MAP)
			{
				ROOM_MAP[k].updateAssets(_currentPeriod);
			}
		}
		
		
		
		// Fade to black
		private function fadeToBlack (callback : Function) : void
		{
			if (!contains(_shade)) 
			{
				_shade.alpha = 0;
				addChild(_shade);
			}
			else
			{
				TweenLite.killTweensOf(_shade);
			}
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
			switch (element.name)
			{
				case "toyBoxPuzzle":
					_puzzleScreen = new ToyBoxScreen();
					break;
				case "teaChestPuzzle":
					_puzzleScreen = new TeaChestScreen();
					break;
				default:
					return;
			}
			_puzzleScreen.initPuzzleScreen(element);
			setFlag(PUZZLESCREEN_OPEN);
		}
		
		public static function removePuzzleScreen (fadeCallback : Function = null) : void
		{
			resetFlag(PUZZLESCREEN_OPEN);
			_fadeCallback = fadeCallback;
		}
		
		
		
		//load config files
		private function loadConfig () : void
		{	
			loadJSONProperties("sceneElements.json", SceneElement);
			loadJSONProperties("switches.json", LightSwitch);
			loadJSONProperties("lights.json", Light);
			loadJSONProperties("doors.json", Door);
			loadJSONProperties("puzzleElements.json", PuzzleElement);
			
			addElementsCreated(_arTeleport = (JSONLoader.loadFile("teleports.json") as Array));
			addElementsCreated(_arPeriod = (JSONLoader.loadFile("periods.json") as Array));
			addElementsCreated(_arInventoryItems = (JSONLoader.loadFile("inventoryItems.json") as Array));
			
			var _arEnemies : Array = (JSONLoader.loadFile("enemies.json") as Array);
			var _arRooms : Array = (JSONLoader.loadFile("rooms.json") as Array);
			
			for (var i : int = 0; i < _arRooms.length; i++)
			{
				var room : Room = ROOM_MAP[_arRooms[i].name];
				if (room)
				{
					room.loadData(_arRooms[i]);
					for (var j : int = 0; j < _arEnemies.length; j++)
					{
						if (_arEnemies[j].room == room.name)
						{
							var en : Enemy = new Enemy();
							en.loadData(_arEnemies[j]);
							room.addEnemy(en);
							break;
						}
					}
				}
			}
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
						if ((obj = room.getChildAt(j)) is cl)
						{
							if (obj.name == jsonObject.name)
							{
								if (jsonObject.elementsCreated)
								{
									for (var k : int = 0; k < jsonObject.elementsCreated.length; k++)
									{
										_arElementsCreated.push(jsonObject.elementsCreated[k]);
									}
								}
								(obj as cl).loadData(jsonObject);
							}
						}
					}
				}
			}
		}
		
		
		
		//Sfx API
		public static const SWITCH_ON : String = "switchOn";
		public static const SWITCH_OFF : String = "switchOff";
		public static const ITEM_GOT : String = "itemGot";
		public static const FIT_SLOT : String = "fitSlot";
		public static const PROJECTOR : String = "projector";
		public static const ANALOG_BUTTON : String = "analogButton";
		public static const BASEMENT_DOOR : String = "basementDoor";
		public static const DAY_NIGHT : String = "dayNight";
		public static const NIGHT_DAY : String = "nightDay";
		public static const PAPERWEIGHT : String = "paperweight";
		public static const STAIRS : String = "stairs";
		public static const DOOR : String = "door";
		public static const VIOLIN : String = "violin";
		
		public static const ENEMY_ATTACK : String = "enemyAttack";
		public static const ENEMY_SPAWN : String = "enemySpawn";
		
		public static const UNEASY_SOUND : String = "uneasySound";
		public static const UNEASY_SOUND_2 : String = "uneasySound2";
		
		public static function playSfx (code : String, looped : Boolean = false) : void
		{
			var sound : Sound;
			var channel : SoundChannel;
			switch (code)
			{
				case SWITCH_ON:
					sound = new SwitchOnSfx;
					break;
				case SWITCH_OFF:
					sound = new SwitchOffSfx;
					break;
				case ITEM_GOT:
					sound = new ItemGotSfx;
					break;
				case FIT_SLOT:
					sound = new FitSlotSfx;
					break;
				case PROJECTOR:
					sound = new ProjectorSfx;
					break;
				case ANALOG_BUTTON:
					sound = new AnalgoButtonSfx;
					break;
				case BASEMENT_DOOR:
					sound = new BasementDoorSfx;
					break;
				case DAY_NIGHT:
					sound = new DayNightSfx;
					break;
				case NIGHT_DAY:
					sound = new NightDaySfx;
					break;
				case PAPERWEIGHT:
					sound = new PaperweightSfx;
					break;
				case STAIRS:
					sound = new StairsSfx;
					break;
				case DOOR:
					sound = new DoorSfx;
					break;
				case VIOLIN:
					sound = new ViolinSfx;
					break;
					
				case UNEASY_SOUND:
					sound = new UneasySfx;
					break;
				case UNEASY_SOUND_2:
					sound = new Uneasy2Sfx;
					channel = _musicChannel2;
					break;
				
				case ENEMY_ATTACK:
					sound = new EnemyAttackSfx;
					break;
				case ENEMY_SPAWN:
					sound = new EnemySpawnSfx;
					channel = _enemySfxChannel;
					break;
			}
			
			switch (code)
			{
				case SWITCH_ON:
				case SWITCH_OFF:
				case ITEM_GOT:
				case FIT_SLOT:
				case PROJECTOR:
				case ANALOG_BUTTON:
				case BASEMENT_DOOR:
				case DAY_NIGHT:
				case NIGHT_DAY:
				case PAPERWEIGHT:
				case STAIRS:
				case DOOR:
				case VIOLIN:
					if (!looped)
					{
						if (_generalSfxChannel) _generalSfxChannel.stop();
						_generalSfxChannel = sound.play();
					}
					else
					{
						if (_loopedSfxChannel) _loopedSfxChannel.stop();
						_loopedSfxChannel = sound.play(0, NUM_LOOPS);
					}
					break;
					
				case UNEASY_SOUND:
				case UNEASY_SOUND_2:
					if (_musicChannel2) _musicChannel2.stop();
					_musicChannel2 = sound.play();
					break;
				
				case ENEMY_ATTACK:
				case ENEMY_SPAWN:
					if (_enemySfxChannel) _enemySfxChannel.stop();
					_enemySfxChannel = sound.play();
					break;
			}
			
		}
		
		public static function playMonsterSfx () : void
		{
			var sound : Sound = new EnemyChasingSfx;
			_enemySfxChannel2 = sound.play(0, NUM_LOOPS);
			_enemySfxChannel2.soundTransform = new SoundTransform(0.5, 0);
			TweenLite.from(_enemySfxChannel2 , 1, { soundTransform: { volume:0 }} );
		}
		
		public static function muteMonsterSfx () : void
		{
			TweenLite.to(_enemySfxChannel2 , 1, { soundTransform: { volume:0 }} );
		}
		
		private static const MIN_DIST : Number = 150;
		private static const MAX_DIST : Number = 450;
		private static const MIN_VOL : Number = 0.2;
		private static const MAX_VOL : Number = 1.0;
		public static function tuneMonsterSfx (dist : Number, left : Boolean) : void
		{
			var s : SoundTransform = new SoundTransform();
			if (dist < MIN_DIST)
			{
				s.volume = 1;
				s.pan = 0;
			}
			else if (dist > MAX_DIST)
			{
				s.volume = 0.2;
				if (left)
				{
					s.pan = -1;
				}
				else
				{
					s.pan = 1;
				}
			}
			else
			{
				s.volume = MAX_VOL - (dist - MIN_DIST) / (MAX_DIST - MIN_DIST) * (MAX_VOL - MIN_VOL);
				s.pan = (left ? 1 : -1) * (dist - MIN_DIST) / (MAX_DIST - MIN_DIST);
			}
			_enemySfxChannel2.soundTransform = s;
		}
		
		public static function muteMusic () : void
		{
			if (_musicChannel1) TweenLite.to(_musicChannel1, 1, { soundTransform: { volume:0 }} );
			if (_musicChannel2) TweenLite.to(_musicChannel2, 1, { soundTransform: { volume:0 }} );
		}
		
		public static function unmuteMusic () : void
		{
			if (_musicChannel1) TweenLite.to(_musicChannel1, 1, { soundTransform: { volume:1 }} );
			if (_musicChannel2) TweenLite.to(_musicChannel2, 1, { soundTransform: { volume:1 }} );
		}
		
		
		
		// Show item screen
		public function getItemScreen (id : String) : MovieClip
		{
			var cl:Class = Class(getDefinitionByName(id + "Screen"));
			return (new cl() as MovieClip);
		}
	}
}