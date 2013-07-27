package  
{
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class Room extends Entity 
	{
		private var _player:Player;
		
		public function Room() 
		{
			
		}
		
		override protected function init(e:Event):void 
		{
			addChild(_player = new Player ());
			for (var i : int = 0; i < numChildren; i++)
			{
				var h : Hitbox;
				if ((h = (getChildAt(i) as Hitbox)))
				{
					h.visible = false;
				}
			}
			super.init(e);
		}
		
		override public function update():void 
		{
			super.update();
			
			_player.resetFlag(Player.HIDDEN);
			var objectSet : Boolean = false;
			for (var i : int = 0; i < numChildren; i++)
			{
				var o : GameObject;
				var oMidPoint : Point;
				var h : Hitbox;
				var s : Shadow;
				if ((o = (getChildAt(i) as GameObject)))
				{
					o.hidden = false;
					oMidPoint = o.getMidPoint();
					for (var j : int = 0; j < numChildren; j++)
					{
						if ((s = getChildAt(j) as Shadow))
						{
							if (s.visible && s.hitTestPoint(oMidPoint.x, oMidPoint.y, true))
							{
								o.hidden = true;
								break;
							}
						}
					}
					
					if (o.interactive && !o.hidden)
					{
						if ((h = (getChildByName("hitbox_" + o.id) as Hitbox)))
						{
							if (_player.x <= h.x + h.width && (_player.x + _player.width) >= h.x)
							{
								o.over();
								_player.gameObject = o;
								objectSet = true;
							}
							else
							{
								o.out();
							}
						}
						else 
						{
							if (_player.x <= o.x + o.width && (_player.x + _player.width) >= o.x)
							{
								objectSet = true;
								_player.gameObject = o;
								o.over();
							}
							else
							{
								o.out();
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
		}
		
		override public function draw():void 
		{
			super.draw();
		}
		
		override protected function destroy(e:Event):void 
		{
			super.destroy(e);
		}
	}

}