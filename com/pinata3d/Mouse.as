package com.pinata3d
{
	import flash.events.MouseEvent;
	import flash.display.Stage;
	
	public class Mouse
	{
		private static var initialized:Boolean = false;		// marks whether or not the class has been initialized
		private static var _polled:Boolean = false;		// marks whether or not the class has been initialized
		
		// absolute mouse position
		private static var _x:Number;
		private static var _y:Number;
		
		// relative to last poll
		private static var _rx:Number;
		private static var _ry:Number;
		
		private static var _button:Boolean = false;
		private static var _clicked:Boolean = false;
		
		
		/**
		* Initializes mouse event.
		* Called internally by engine.
		*
		* @param stage Flash stage
		*/
		public static function _initialize(stage:Stage):void 
		{
			if (!initialized) 
			{
				//These three eventlisteners are telling flash to "listen" for specific events  
				//in our case if the mouse moves and if the mouse button is down or up.  
				//then if one of these events happens, it calls a function (mouse_down, mouse_up or moving).  
				stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouse_down);   
				stage.addEventListener(MouseEvent.MOUSE_UP, _mouse_up);   
				stage.addEventListener(MouseEvent.MOUSE_MOVE, _moving); 
			}
		}
		
		/**
		* Mouse move event
		*/
		private static function _moving(e:MouseEvent):void   
		{   
			//mouse_events.text = "mouse is moving"  
			if (!_polled)
			{
				_polled = true;
				_rx = 0;
				_ry = 0;
				_x = e.stageX;
				_y = e.stageY;
			}
			_rx = e.stageX - _x;
			_ry = e.stageY - _y;
			_x = e.stageX;
			_y = e.stageY;
			
		}   
		
		/**
		* Mouse down event
		*/
		private static function _mouse_down(e:MouseEvent):void   
		{   
			//mouse_events.text = "Mouse button is down"  
			_button = true;
			_clicked = true;
		}   
		
		/**
		* Mouse up event
		*/
		private static function _mouse_up(e:MouseEvent):void   
		{   
			//mouse_events.text = "Mouse button is up again"  
			
			_button = false;
			_clicked = false;
		}  
		
		/**
		* Mouse x position
		*/
		public static function get x():Number 
		{
			return _x;
		}
		
		/**
		* Mouse y position
		*/
		public static function get y():Number 
		{
			return _y;
		}
		
		/**
		* Is mouse pressed
		*/
		public static function get button():Boolean 
		{
			return _button;
		}
		
		/**
		* Mouse x position relative to last poll
		*/
		public static function get rx():Number 
		{
			var tmp:Number = _rx;
			_rx = 0;
			return tmp;
		}
		
		/**
		* Mouse y position relative to last poll
		*/
		public static function get ry():Number 
		{
			var tmp:Number = _ry;
			_ry = 0;
			return tmp;
		}
		
		/**
		* Was mouse just clicked
		*/
		public static function get clicked():Boolean 
		{
			var tmp:Boolean = _clicked;
			_clicked = false;
			return tmp;
		}
	}
}