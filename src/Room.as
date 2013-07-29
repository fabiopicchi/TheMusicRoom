package  
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
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
		
		private var _mcShadows : MovieClip;
		private var _mcEnemies : MovieClip;
		private var _mcPlayer : MovieClip;
		private var _mcObjects : MovieClip;
		
		
		public function Room() 
		{
			var i : int = 0;
			var obj : DisplayObject;
			
			var arShadow : Array = [];
			var arEnemies : Array = [];
			var arPlayer : Array = [];
			var arElements : Array = [];
			
			for (i = 0; i < numChildren; i++)
			{
				if ((obj = getChildAt(i)) is Shadow)
				{
					removeChild(obj);
					arShadow.push(obj);
				}
				else if ((obj = getChildAt(i)) is InteractiveElement || (obj = getChildAt(i)) is Hitbox)
				{
					removeChild(obj);
					arElements.push(obj);
				}
				else if ((obj = getChildAt(i)) is Enemy)
				{
					removeChild(obj);
					arEnemies.push(obj);
				}
				else if ((obj = getChildAt(i)) is Player)
				{
					removeChild(obj);
					arPlayer.push(obj);
				}
			}
			
			for (i = 0; i < arShadow.length; i++) _mcShadows.addChild(arShadow[i]);
			for (i = 0; i < arElements.length; i++) _mcShadows.addChild(arElements[i]);
			for (i = 0; i < arEnemies.length; i++) _mcShadows.addChild(arEnemies[i]);
			for (i = 0; i < arPlayer.length; i++) _mcShadows.addChild(arPlayer[i]);
			
			addChild(_mcObjects);
			addChild(_mcPlayer);
			addChild(_mcEnemies);
			addChild(_mcShadows);
			
			setChildIndex (getChildByName("back"), 0);
			setChildIndex (getChildByName("fronr"), numChildren - 1);
			
			updateAssets();
		}
		
		public function addPlayer () : void
		{
			_player = Game.playerInstance;
			addChild(Game.playerInstance);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			if (child is Enemy) _mcEnemies.addChild(child);
			if (child is Player) _mcPlayer.addChild(child);
			else super.addChild(child);
			return child;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			if (child is Enemy) _mcEnemies.removeChild(child);
			if (child is Player) _mcPlayer.removeChild(child);
			else super.removeChild(child);
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
		
		public function update():void 
		{
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
				var child : DisplayObject;
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
						child = getChildAt(i);
						if (child.name != "front")
						{
							if (child.name == "back" || child.name == "area")
							{
								getChildAt(i).x += scrollX;
							}
							else
							{
								for (var j : int = 0; j < (child as MovieClip).numChildren; j++)
									(child as MovieClip).getChildAt(j).x += scrollX;
							}
						}
						else
						{
							child.x += scrollX * _frontScrollFactor;
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
						child = getChildAt(i);
						if (child.name != "front")
						{
							if (child.name == "back" || child.name == "area")
							{
								getChildAt(i).x += scrollX;
							}
							else
							{
								for (var j : int = 0; j < (child as MovieClip).numChildren; j++)
									(child as MovieClip).getChildAt(j).x += scrollX;
							}
						}
						else
						{
							child.x += scrollX * _frontScrollFactor;
						}
					}
				}
				_scrollAcc += scrollX;
			}
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
	}

}