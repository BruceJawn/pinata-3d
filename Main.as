////////////////////////////////
// Pinata3d - www.pinata3d.com
////////////////////////////////

////////////////////////////////
// Example Game
// by Sos and Mcfunkypants
////////////////////////////////
// This example is meant to be a
// good starting point for the
// creation of your own games.
// The Pinata3d engine resides
// in the /com/pinata3d/ folder.
////////////////////////////////

package
{
	import com.pinata3d.Engine;
	import com.pinata3d.Pinata;
	import com.pinata3d.Key;
	import com.pinata3d.Mouse;
	import com.pinata3d.Mesh;
	import com.pinata3d.Entity;
	import com.pinata3d.Game_timer;
	import flash.geom.Vector3D;

	public class Main extends Engine
	{
		
		public var time:Number = 6000; // so we see it right away
		//private var triangle:Entity;
		private var timer:Game_timer;
		
		[Embed(source = 'gfx/tree.png')]
		private const TREE:Class;
		
		[Embed(source = 'gfx/terrain.obj', 
		mimeType = 'application/octet-stream')]
		private const TERRAINDATA:Class;

		public function Main()
		{
			super(800, 600, 0);
		}
		
		// only run once per second
		public function heartbeat():void
		{
			trace(timer.game_elapsed_time+'ms');
		}
		
		override public function init():void
		{
			// add a new entity to the world
			// creates all geometry from an image
			add(new Entity(Mesh.create1(TREE)));
			
			// add another entity to the world
			// creates all geometry from an .OBJ file
			add(new Entity(Mesh.createOBJ(TERRAINDATA)));
			
			// create a timer that measures 
			// elapsed time between frames
			timer = new Game_timer(heartbeat);
			
			// set up the camera projection matrix
			Pinata.camera.projection(.1,4096,40);
			
		}
		
		override public function update():void
		{
			timer.tick();
			time += timer.frame_ms;
			
			Pinata.camera.position = new Vector3D(Math.cos(time/2000) * 20, -10, Math.sin(time/2000) * 20);
		
		}
	}
}