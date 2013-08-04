package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	
	public class Room extends Entity 
	{
		private var _player:Player;
		private var _frontScrollFactor : Number;
		private var _time : String = "night";
		private var _scrollAcc : Number = 0;
		
		public function Room() 
		{
			
		}
		
		public function checkObjectNames () : String
		{
			var arLights : Array = [];
			var arSwitches : Array = [];
			var arDoors : Array = [];
			
			var lightStatus : String = "";
			var switchStatus : String = "";
			var doorStatus : String = "";
			
			var i : int = 0;
			var child : Entity;
			
			for (i = 0; i < numChildren; i++)
			{
				if ((child = getChildAt(i) as Entity))
				{
					if (child is Light)
						arLights.push(child);
					if (child is Door)
						arDoors.push(child);
					if (child is LightSwitch)
						arSwitches.push (child);
				}
			}
			
			arLights.sortOn(["x"], Array.NUMERIC);
			arSwitches.sortOn(["x"], Array.NUMERIC);
			arDoors.sortOn(["x"], Array.NUMERIC);
			
			for (i = 0; i < arDoors.length; i++)
			{
				if (arDoors[i].name != "d" + name + (i + 1))
				{
					doorStatus += "        Error at door name: " + arDoors[i].name + ". Should be: " + "d" + name + (i + 1) + "\n";
				}
			}
			
			for (i = 0; i < arLights.length; i++)
			{
				if (arLights[i].name != "l" + name + (i + 1))
				{
					lightStatus += "        Error at light name: " + arLights[i].name + ". Should be: " + "l" + name + (i + 1) + "\n";
				}
			}
			
			for (i = 0; i < arSwitches.length; i++)
			{
				if (arSwitches[i].name != "s" + name + (i + 1))
				{
					switchStatus += "        Error at switch name: " + arSwitches[i].name + ". Should be: " + "s" + name + (i + 1) + "\n";
				}
			}
			
			if (switchStatus == "" && lightStatus == "" && doorStatus == "") return "        Success\n";
			else return doorStatus + lightStatus + switchStatus;
		}
		
		public function addPlayer () : void
		{
			_player = Game.playerInstance;
			addChild(Game.playerInstance);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			super.addChild(child);
			zOrder();
			return child;
		}
		
		public function removePlayer () : void
		{
			_player = null;
			removeChild(Game.playerInstance);
		}
		
		override protected function init(e:Event):void 
		{
			if (getChildByName("front"))
			{
				_frontScrollFactor = (getChildByName("front").width - 1024) / (getChildByName("back").width - 1024);
			}
			for (var i : int = 0; i < numChildren; i++)
			{
				if (getChildAt(i).name.indexOf("_h") != -1)
				{
					getChildAt(i).visible = false;
				}
				if (getChildAt(i).name == "area")
				{
					getChildAt(i).visible = false;
				}
			}
			super.init(e);
		}
		
		override public function update():void 
		{
			super.update();
			
			if (_player)
			{
				if (_player.x < getChildByName("area").x)
				{
					_player.x = getChildByName("area").x;
				}
				else if (_player.x + _player.width > getChildByName("area").x + getChildByName("area").width)
				{
					_player.x = getChildByName("area").x + getChildByName("area").width - _player.width;
				}
				
				_player.resetFlag(Player.HIDDEN);
				var objectSet : Boolean = false;
				for (var i : int = 0; i < numChildren; i++)
				{
					var el : InteractiveElement;
					var oMidPoint : Point;
					var h : MovieClip;
					var light : Light;
					if ((el = (getChildAt(i) as InteractiveElement)))
					{
						if (_time == "night")
						{
							el.setFlag(InteractiveElement.HIDDEN);
							for (var j : int = 0; j < numChildren; j++)
							{
								if ((light = getChildAt(j) as Light))
								{
									if (light.visible && light.hitTestPoint(el.x, el.y, true) && light.hitTestPoint(el.x + el.width, el.y, true))
									{
										el.resetFlag(InteractiveElement.HIDDEN);
										break;
									}
								}
							}
						}
						else
						{
							el.resetFlag(InteractiveElement.HIDDEN);
						}
						
						
						if (el.visible && !el.testFlag(InteractiveElement.HIDDEN))
						{
							if ((h = (getChildByName(el.name + "_h") as MovieClip)))
							{
								trace (h.x);
								trace (_player.x);
								trace (h.name);
								if (h.hitTestPoint(_player.getMidPoint().x, h.y + h.height / 2, false))
								{
									el.updateAsset(_time, "over");
									_player.gameObject = el;
									objectSet = true;
								}
								else
								{
									el.updateAsset(_time, "normal");
								}
							}
							else 
							{
								if (el.hitTestPoint(_player.getMidPoint().x, el.y + el.height / 2, false))
								{
									objectSet = true;
									_player.gameObject = el;
									el.updateAsset(_time, "over");
								}
								else
								{
									el.updateAsset(_time, "normal");
								}
							}
						}
					}
					
					if ((light = getChildAt(i) as Light))
					{
						if (light.visible)
						{
							if (!_player.isOverlappedBy(light))
							{
								_player.setFlag(Player.HIDDEN);
								break;
							}
						}
					}
				}
				
				if (!objectSet)
				{
					_player.gameObject = null;
				}
				
				//scrollX
				var scrollX : Number = 0;
				if (_player.x >= 724 && _scrollAcc > -(getChildByName("back").width - 1024))
				{
					if (_scrollAcc - Game.playerInstance.speed * Game.dt < -(getChildByName("back").width - 1024))
					{
						scrollX = -Math.round((_scrollAcc + (getChildByName("back").width - 1024)));
					}
					else
					{
						scrollX = -(_player.x - 724);
					}
					
					for (i = 0; i < numChildren; i++)
					{
						if (getChildAt(i).name != "front")
						{
							getChildAt(i).x += scrollX;
						}
						else
						{
							getChildAt(i).x += scrollX * _frontScrollFactor;
						}
					}
				}
				
				if (_player.x <= 300 && _scrollAcc < 0)
				{
					if ((_scrollAcc + Game.playerInstance.speed * Game.dt) > 0)
					{
						scrollX = -Math.round(_scrollAcc);
					}
					else
					{
						scrollX = 300 - _player.x;
					}
					for (i = 0; i < numChildren; i++)
					{
						if (getChildAt(i).name != "front")
						{
							getChildAt(i).x += scrollX;
						}
						else
						{
							getChildAt(i).x += scrollX * _frontScrollFactor;
						}
					}
				}
				_scrollAcc += scrollX;
			}
		}
		
		override public function draw():void 
		{
			super.draw();
		}
		
		override protected function destroy(e:Event):void 
		{
			super.destroy(e);
		}
		
		public function updateAssets (period : int) : void
		{
			if (period % 2 == 1)
			{
				_time = "night";
			}
			else
			{
				_time = "day";
			}
				
			
			(getChildByName("back") as MovieClip).gotoAndStop(_time);
			if (getChildByName("front"))
			{
				(getChildByName("front") as MovieClip).gotoAndStop(_time);
			}
			
			if (_time == "night")
			{
				if (getChildByName("shadow")) getChildByName("shadow").visible = true;
			}
			else
			{
				if (getChildByName("shadow")) getChildByName("shadow").visible = false;
			}
			
			var el : InteractiveElement;
			var light : Light;
			for (var i : int = 0; i < numChildren; i++)
			{
				if ((el = (getChildAt(i) as InteractiveElement)))
				{
					el.updateAsset(_time, "normal");
				}
				
				if ((light = (getChildAt(i) as Light)))
				{
					if (_time == "night")
						light.resetNightState();
					else
						light.visible = false;
				}
			}
		}
		
		public function zOrder () : void
		{
			var arLights : Array = [];
			var arPlayer : Array = [];
			var arEnemies : Array = [];
			var arObjects : Array = [];
			var i : int = 0;
			var child : Entity;
			
			for (i = 0; i < numChildren; i++)
			{
				if ((child = getChildAt(i) as Entity))
				{
					if (child is Light)
						arLights.push(child);
					if (child is Player)
						arPlayer.push(child);
					if (child is Enemy)
						arEnemies.push (child);
					if (child is InteractiveElement)
						arObjects.push (child);
				}
			}
			
			setChildIndex(getChildByName("back"), 0);
			setChildIndex(getChildByName("area"), 1);
			
			var zIndex : int = 2;
			
			var j : int = 1;
			for (j = 0; j < arObjects.length; j++)
			{
				setChildIndex(arObjects[j], zIndex++);
			}
				
			for (j = 0; j < arPlayer.length; j++)
			{
				setChildIndex(arPlayer[j], zIndex++);
			}
			
			for (j = 0; j < arEnemies.length; j++)
			{
				setChildIndex(arEnemies[j], zIndex++);
			}
			
			setChildIndex(getChildByName("shadow"), zIndex++);
			
			for (j = 0; j < arLights.length; j++)
			{
				setChildIndex(arLights[j], zIndex++);
			}
			
			setChildIndex(getChildByName("front"), numChildren - 1);
		}
		
		public function get time():String 
		{
			return _time;
		}
	}

}