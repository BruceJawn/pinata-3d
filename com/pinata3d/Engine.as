package  com.pinata3d
{
	import com.pinata3d.Mouse;
	import com.pinata3d.Key;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.geom.Vector3D;
 
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
 
	
	public class Engine extends Sprite
	{
		private var _entities:Vector.<Entity>;
		//Context3D is where the rendering happens
		//It's like BitmapData to Bitmap (Stage3D)
		private var context3d:Context3D;
		
		public var _width:int;
		public var _height:int;
		public var antialias:int;
		
		//public var camera:Camera = null;
		
		
		/**
		* Pinata3D main engine class constructor
		* @param w swf width
		* @param h swf height
		* @param aa Anti-aliasing value
		*/
		public function Engine(w:int,h:int,aa:int)
		{
			_width = w;
			_height = h;
			antialias = aa;
			//standard flash stuff to just tell the stage not to scale and stay in the top left corner
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			
			//We want to add an event listener for when flash gives us our Context3D
			//Flash may not be able to give it right away so thats why we do this
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, _onGotContext);
			
			//Here we are saying "Oh please Flash give us some GPU goodness"
			//and Flash will respond to us through the function onGotContext
			stage.stage3Ds[0].requestContext3D();
			
			//Here we are just saying that Flash should render the 3d stuff
			//in a rectangle that is 980px wide and 570px hight at 0,0
			stage.stage3Ds[0].viewPort = new Rectangle(0, 0, _width, _height);
			
			Key._initialize(stage);
			Mouse._initialize(stage);
			
			Pinata.width = _width;
			Pinata.height = _height;
			Pinata.camera = new Camera();
			
			_entities = new Vector.<Entity>();
		}
		
		/**
		* Context retrieval callback
		*/
		private function _onGotContext(ev:Event):void
		{
			//We get the Stage3D that's going to give our Context3D
			var stage3d:Stage3D=Stage3D(ev.currentTarget);
			//We got our Context3D- YES!!!
			context3d = stage3d.context3D;
			
			Pinata.context = context3d;
			
			//Or did we get our Context3D???
			//Not sure how this could happen but
			//it seems the standard to check for this
			//If we didn't get a context we of course
			//dont want to do anything else so we just
			//quit this function
			if(context3d==null)
			 return;
			
			 
			//This will make it so that we get errors if
			//something screws up. When you publish your
			//final export swf you should put this as false
			//because apparently this will increase performance
			context3d.enableErrorChecking=true;
			
			//Think of this as almost as the same thing as
			//new BitmapData(980, 570)… We are basically saying
			//we want this much data to render to
			//the 4 is the level of anti-aliasing we want to do
			//possible values for Anti-Aliasing are:
			//0 no antialiasing
			//2 some antialiasing
			//4 high quality antialiasing
			//16 very high antialising
			//but when I put in 16 i got an error so maybe 16 doesnt work
			context3d.configureBackBuffer(_width, _height, antialias, true);
			
			//here we are basically saying if a triangle isn't facing us
			//dont draw it out (culling==I DONT CARE ABOUT YOU)
			context3d.setCulling(Context3DTriangleFace.NONE);
			
			
			
			//Add our render loop
			addEventListener(Event.ENTER_FRAME, _onRenderLoop);
			
			init();
			
		}
		
		/**
		* Rendering callback
		*/
		private function _onRenderLoop(event:Event):void
		{
			
			//clear the frame and screen
			context3d.clear(0.5, 0.5, 0.5, 1);
			
			update();
			
			Pinata.camera._precalc();
			
			for each (var entity:Entity in _entities) entity.render();
			
			//Show those triangles on screen
			context3d.present();
		}
		
		/**
		* Adds entity to the scene
		*/
		public function add(entity:Entity):void
		{
			_entities.push(entity);
		}
		
		/**
		* overrride to call on init
		*/
		public function init():void
		{
			
		}
		
		/**
		* overrride to call on render
		*/
		public function update():void
		{
			
		}
	}
}