package  
{
	import flash.events.Event;
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
			
			var objectSet : Boolean = false;
			for (var i : int = 0; i < numChildren; i++)
			{
				var o : GameObject;
				var h : Hitbox;
				if ((o = (getChildAt(i) as GameObject)))
				{
					if (o.interactive)
					{
						if ((h = (getChildByName("hitbox_" + o.name.split("_")[1]) as Hitbox)))
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