﻿/*
Copyright 2011 Marek Standio.

This file is part of SaladoPlayer.

SaladoPlayer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

SaladoPlayer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SaladoPlayer. If not, see <http://www.gnu.org/licenses/>.
*/
package com.panozona.modules.imagemap.events {
	
	import flash.events.Event;
	
	public class ViewerEvent extends Event{
		
		public static const CHANGED_MOVE:String = "changedMove";
		public static const CHANGED_ZOOM:String = "changedZoom";
		
		public static const CHANGED_MOUSE_OVER:String = "changedmOver";
		public static const CHANGED_MOUSE_DRAG:String = "changedmDrag";
		
		public static const CHANGED_FOCUS_POINT:String = "changedfPoint";
		
		public static const CHANGED_SIZE:String = "changedSize";
		
		public static const FOCUS_LOST:String = "focusLost";
		
		public function ViewerEvent(type:String){
			super(type);
		}
	}
}