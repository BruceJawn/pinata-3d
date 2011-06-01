// Molehill game timer routines version 1.0
// 
package com.pinata3d
{

import flash.utils.*;

public class Game_timer
{
	// when the game started
	public var game_start_time:Number = 0.0; 
	// timestamp: previous frame
	public var last_frame_time:Number = 0.0; 
	// timestamp: right now
	public var current_frame_time:Number = 0.0; 
	// how many ms elapsed last frame
	public var frame_ms:Number = 0.0; 
	// number of frames this game
	public var frame_count:uint = 0; 
	// when to fire this next
	public var next_heartbeat_time:uint = 0; 
	// how many ms so far?
	public var game_elapsed_time:uint = 0; 
	// how often in ms does the heartbeat occur?
	public var heartbeat_interval_ms:uint = 1000; 
	// function to run each heartbeat
	public var heartbeat_function:Function; 
	
	// class constructor
	public function Game_timer(
		heartbeat_func:Function = null, 
		heartbeat_ms:uint = 1000)
	{
		if (heartbeat_func != null) 
			heartbeat_function = heartbeat_func;

		heartbeat_interval_ms = heartbeat_ms;
	}

	public function tick():void
	{
		current_frame_time = getTimer();
		if (frame_count == 0) // first frame?
		{
			game_start_time	= current_frame_time;
			trace("First frame happened after " 
				+ game_start_time + "ms");
			frame_ms = 0;
			game_elapsed_time = 0;
		}
		else
		{
			// how much time has passed since the last frame?
			frame_ms = current_frame_time - last_frame_time;
			game_elapsed_time += frame_ms;
		}

		if (heartbeat_function != null)
		{
			if (current_frame_time >= next_heartbeat_time)
			{
				heartbeat_function();
				next_heartbeat_time = current_frame_time 
					+ heartbeat_interval_ms;
			}
		}

		last_frame_time = current_frame_time;
		frame_count++;
		
	}	

}

}
