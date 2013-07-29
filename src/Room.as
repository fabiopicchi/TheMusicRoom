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
		private var _time : String = "day";
		private var _scrollAcc : Number = 0;
		
		public function Room() 
		{
			updateAssets();
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
				var h : Hitbox;
				if ((h = (getChildAt(i) as Hitbox)))
				{
					h.visible = false;
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
					var h : Hitbox;
					var s : Shadow;
					if ((el = (getChildAt(i) as InteractiveElement)))
					{
						el.resetFlag(InteractiveElement.HIDDEN);
						for (var j : int = 0; j < numChildren; j++)
						{
							if ((s = getChildAt(j) as Shadow))
							{
								if (s.visible && s.hitTestPoint(el.x, el.y, true) && s.hitTestPoint(el.x + el.width, el.y, true))
								{
									el.setFlag(InteractiveElement.HIDDEN);
									break;
								}
							}
						}
						
						if (el.visible && !el.testFlag(InteractiveElement.HIDDEN))
						{
							if ((h = (getChildByName(el.name + "_h") as Hitbox)))
							{
								if (_player.getMidPoint().x <= h.x + h.width && _player.getMidPoint().x >= h.x)
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
								if (_player.getMidPoint().x <= el.x + el.width && _player.getMidPoint().x >= el.x)
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
					
					if ((s = getChildAt(i) as Shadow))
					{
						if (s.visible)
						{
							if (_player.isOverlappedBy(s))
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
					if (_scrollAcc - 1024 * Game.dt < -(getChildByName("back").width - 1024))
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
					if ((_scrollAcc + 1024 * Game.dt) > 0)
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
		
		public function updateAssets () : void
		{
			(getChildByName("back") as MovieClip).gotoAndStop(_time);
			if (getChildByName("front"))
			{
				(getChildByName("front") as MovieClip).gotoAndStop(_time);
			}
			
			var obj : InteractiveElement;
			for (var i : int = 0; i < numChildren; i++)
			{
				if ((obj = (getChildAt(i) as InteractiveElement)))
				{
					obj.updateAsset(_time, "normal");
				}
			}
		}
		
		public function zOrder () : void
		{
			var arShadows : Array = [];
			var arPlayer : Array = [];
			var arEnemies : Array = [];
			var arObjects : Array = [];
			var i : int = 0;
			var child : Entity;
			
			for (i = 0; i < numChildren; i++)
			{
				if ((child = getChildAt(i) as Entity))
				{
					if (child is Shadow)
						arShadows.push(child);
					if (child is Player)
						arPlayer.push(child);
					if (child is Enemy)
						arEnemies.push (child);
					if (child is InteractiveElement)
						arObjects.push (child);
				}
			}
			
			setChildIndex(getChildByName("back"), 0);
			
			var zIndex : int = 1;
			
			var j : int = 1;
			for (j = 1; j < arObjects.length; j++)
				setChildIndex(arObjects[j], j);
				
			for (j = arObjects.length; j < arObjects.length + arPlayer.length; j++)
				setChildIndex(arPlayer[j - arObjects.length], j);
				
			for (j = arObjects.length + arPlayer.length; j < arObjects.length + arPlayer.length + arEnemies.length; j++)
				setChildIndex(arEnemies[j - arObjects.length - arPlayer.length], j);
				
			for (j = arObjects.length + arPlayer.length + arEnemies.length; j < arObjects.length + arPlayer.length + arEnemies.length + arShadows.length; j++)
				setChildIndex(arShadows[j - arEnemies.length - arObjects.length - arPlayer.length], j);
		}
	}

}