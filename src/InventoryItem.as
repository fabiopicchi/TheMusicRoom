package
{
	import avmplus.getQualifiedClassName;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author arthur e fabio
	 */
	public class InventoryItem extends MovieClip
	{
		imap
		irecipeBook
		icupboardKey
		icupcakeTin
		icirclePiece
		itrianglePiece
		isquarePiece
		ihanger
		isecondFloorKey
		itoyShovel
		imarble
		ifirstGear
		iivyKey
		imint
		iginger
		iinfuser
		iroseWine
		iscissors
		imonocle
		ipaperweight
		isecondGear
		iscrewdriver
		ipliers
		iredWine
		ipendant
		inote
		ideskKey
		ipearl
		ibroom
		iwineBook
		iboilerKey
		isapphire
		ioil
		ilightbulb
		iputtyKnife
		inotebook
		ifirePoker
		iruby
		ioldPaper
		idoorknob
		icassette
		imusicRoomKey
		iwhiteWine
		isecretNote
		ithirdGear
		idrawerHandle
		ipassword
		
		imapScreen
		
		private var _id:String;
		private var _text:String;
		private var _arElementsCreated:Array;
		private var _arElementsDestroyed:Array;
		private var _itemType : int = 0;
		
		public static const READABLE : int = 0;
		public static const USABLE : int = 1;
		
		public function InventoryItem(objData:Object)
		{
			_id = objData.name;
			_text = objData.text;
			_arElementsCreated = (objData.elementsCreated == "" ? [] : objData.elementsCreated);
			_arElementsDestroyed = (objData.elementsDestroyed == "" ? [] : objData.elementsDestroyed);
			_itemType = objData.type;
			
			addChild(getAsset());
		}
		
		public function over():void
		{
			(getChildAt(0) as MovieClip).gotoAndStop(2);
		}
		
		public function out():void
		{
			(getChildAt(0) as MovieClip).gotoAndStop(1);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get itemType():int 
		{
			return _itemType;
		}
		
		private function getAsset():MovieClip
		{
			var cl:Class = Class(getDefinitionByName(id));
			var mc:Object = new cl();
			(mc as MovieClip).gotoAndStop(1);
			return (mc as MovieClip);
		}
	}
}