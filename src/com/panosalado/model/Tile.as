/*Copyright 2010 Zephyr Renner.This file is part of PanoSalado.PanoSalado is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any later version.PanoSalado is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty ofMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See theGNU General Public License for more details.You should have received a copy of the GNU General Public Licensealong with PanoSalado. If not, see <http://www.gnu.org/licenses/>.*/package com.panosalado.model{		import com.panosalado.events.ReadyEvent;	import com.panosalado.loading.IOErrorEventHandler;	import com.panosalado.model.TilePyramid;	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.GraphicsBitmapFill;	import flash.display.GraphicsTrianglePath;	import flash.display.Loader;	import flash.display.LoaderInfo;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IOErrorEvent;	import flash.events.TimerEvent;	import flash.geom.Vector3D;	import flash.net.URLRequest;	import flash.utils.Timer;		public class Tile extends EventDispatcher {				public var ready:Boolean;		public var bitmapLoading:Boolean;		public var bitmapLoaded:Boolean;		public var displaying:Boolean;				public var tilePyramid:TilePyramid;				public var next:Tile;		public var prev:Tile;				public var nextDisplayingTile:Tile;				public var url:String;				public var bitmapData:BitmapData;		public var graphicsBitmapFill:GraphicsBitmapFill;		public var graphicsTrianglePath:GraphicsTrianglePath;				public var n:Tile;      //next tile		public var tl:Tile;     //top left child tile		public var tr:Tile;     //top right child tile		public var bl:Tile;     //bottom left child tile		public var br:Tile;     //bottom right child tile		public var p:Tile;      //parent tile		public var vertex:Tile; //vertex tile (tip of pyramid)				public var t:int; //tier #		public var r:int  //row #		public var c:int; //c #				public var ppd:Number; //pixels per degree				public var tlIn:Boolean;		public var trIn:Boolean;		public var blIn:Boolean;		public var brIn:Boolean;		public var numIn:int;		public var clipStatus:int;				public var rawVertices:Vector.<Vector3D>;		public var vertices:Vector.<Number>;		public var indices:Vector.<int>;		public var clippedIndices:Vector.<int>;		public var transformedVertices:Vector.<Number>;		public var clippedUvtData:Vector.<Number>;		public var previewUvtData:Vector.<Number>;		public var uvtData:Vector.<Number>;				public var expirationTimer:Timer;				public function Tile(){			ready                       = false;			bitmapLoading               = false;			bitmapLoaded                = false;			displaying                  = false;			rawVertices                 = new Vector.<Vector3D>();			vertices                    = new Vector.<Number>();			transformedVertices         = new Vector.<Number>();			indices                     = new Vector.<int>();			clippedIndices              = new Vector.<int>();			clippedUvtData              = new Vector.<Number>();			previewUvtData              = new Vector.<Number>();			uvtData                     = new Vector.<Number>();			graphicsTrianglePath        = new GraphicsTrianglePath(				new Vector.<Number>(),  //vertices				null,                   //indices				null                    //uvtData			);			graphicsBitmapFill = new GraphicsBitmapFill(				null,   //bitmapData				null,   //matrix 				false,  //repeat				true    //smooth			);		}			static public function init( vertex:Tile, tilePyramid:TilePyramid, v:Vector.<Vector3D>, colAxis:String, rowAxis:String, constAxis:String):void {			t = 0;			r = 0;			c = 0;			vertex.tilePyramid = tilePyramid;			vertex.vertex = vertex;			vertex.url = tilePyramid.getTileURL(t, c, r);			//ppd = Math.sqrt(tilePyramid.widths[0] * tilePyramid.widths[0] + tilePyramid.heights[0] * tilePyramid.heights[0]) / f;						var ts:int = (tilePyramid.tileSize == 0) ? tilePyramid.width : tilePyramid.tileSize;			var width:int = tilePyramid.width;			var height:int = tilePyramid.height;			var overlap:int = tilePyramid.overlap;			var numTiles:int = tilePyramid.numTiles;						var onePixelC:Number = overlap;			var onePixelR:Number = overlap;						var p_tl:Vector3D = new Vector3D();			p_tl[colAxis] = v[0][colAxis] - onePixelC;			p_tl[rowAxis] = v[0][rowAxis] - onePixelR;			p_tl[constAxis] = v[0][constAxis];			var p_tr:Vector3D = new Vector3D();			p_tr[colAxis] = v[1][colAxis] + onePixelC;			p_tr[rowAxis] = v[1][rowAxis] - onePixelR			p_tr[constAxis] = v[1][constAxis];			var p_br:Vector3D = new Vector3D();			p_br[colAxis] = v[3][colAxis] + onePixelC;			p_br[rowAxis] = v[3][rowAxis] + onePixelR;			p_br[constAxis] = v[3][constAxis];			var p_bl:Vector3D = new Vector3D();			p_bl[colAxis] = v[2][colAxis] - onePixelC;			p_bl[rowAxis] = v[2][rowAxis] + onePixelR;			p_bl[constAxis] = v[2][constAxis];						var scalar:Number = tilePyramid.accurateWidths[0] / width;			var rootDiagonalFOV:Number = (Vector3D.angleBetween(p_tl, p_br) * __toDegrees)			vertex.ppd = (Vector3D.distance(p_tl, p_br) * scalar) / rootDiagonalFOV;						vertex.rawVertices.push(p_tl, p_tr, p_br, p_bl);			Tile.prepopulateDrawingData(vertex);						// load root parent bitmapdata so that all child tiles have preview data.			var urlRequest:URLRequest = new URLRequest(vertex.url);			var loader:Loader = new Loader();			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, vertex.rootParentLoadCompleteHandler);			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorEventHandler, false, 0, true);			loader.load(urlRequest);					// end of root parent tile.			if (numTiles <= 1) return;						// create all the tiles			var ct:Tile = new Tile();			var next:Tile = ct; 			for (var i:int = 2; i < numTiles; i++){				ct.n = new Tile();				ct = ct.n;			} 			var attemptChildren:Vector.<Tile> = new Vector.<Tile>();			attemptChildren.push(vertex);			var tile:Tile;			var distC:Number;			var distR:Number;			var splitCa:Number;			var splitCb:Number;			var splitCc:Number;			var splitRa:Number;			var splitRb:Number;			var splitRc:Number;						distC = v[1][colAxis] - v[0][colAxis]; // order is important for signs			distR = v[2][rowAxis] - v[0][rowAxis];						var v_0_colAxis:Number = v[0][colAxis];			var v_0_rowAxis:Number = v[0][rowAxis];			var v_0_constAxis:Number = v[0][constAxis];						while(tile = attemptChildren.shift()){				if (!next || !next.n) return;								var t:int = tile.t + 1;				var r:int = tile.r * 2;				var c:int = tile.c * 2;				scalar = tilePyramid.accurateWidths[t] / width;								splitCa = ts * c / tilePyramid.accurateWidths[t];				splitCb = ts * (c + 1)/tilePyramid.accurateWidths[t]; if (splitCb > 1) splitCb = 1;				splitCc = ts * (c + 2)/tilePyramid.accurateWidths[t]; if (splitCc > 1) splitCc = 1;				splitRa = ts * r / tilePyramid.accurateHeights[t];				splitRb = ts * (r + 1)/tilePyramid.accurateHeights[t]; if (splitRb > 1) splitRb = 1;				splitRc = ts * (r + 2)/tilePyramid.accurateHeights[t]; if (splitRc > 1) splitRc = 1;								onePixelC = overlap / tilePyramid.widths[t] * distC;				onePixelR = overlap / tilePyramid.heights[t] * distR;								next.tilePyramid = tilePyramid;				next.t = t;				next.r = r;				next.c = c;				next.p = tile;				next.vertex = vertex;				next.url = tilePyramid.getTileURL(t, next.c, next.r);				p_tl = new Vector3D();				p_tl[colAxis] = (v_0_colAxis + distC * splitCa) - onePixelC;				p_tl[rowAxis] = (v_0_rowAxis + distR * splitRa) - onePixelR;				p_tl[constAxis] = v_0_constAxis;				p_tr = new Vector3D();				p_tr[colAxis] = (v_0_colAxis + distC * splitCb) + onePixelC;				p_tr[rowAxis] = (v_0_rowAxis + distR * splitRa) - onePixelR;				p_tr[constAxis] = v_0_constAxis;				p_br = new Vector3D();				p_br[colAxis] = (v_0_colAxis + distC * splitCb) + onePixelC;				p_br[rowAxis] = (v_0_rowAxis + distR * splitRb) + onePixelR;				p_br[constAxis] = v_0_constAxis;				p_bl = new Vector3D();				p_bl[colAxis] = (v_0_colAxis + distC * splitCa) - onePixelC;				p_bl[rowAxis] = (v_0_rowAxis + distR * splitRb) + onePixelR;				p_bl[constAxis] = v_0_constAxis;				next.rawVertices.push(p_tl, p_tr, p_br, p_bl);				Tile.prepopulateDrawingData(next);				// this is accurate but causes cracks				next.ppd = (Vector3D.distance(p_tl, p_br) * scalar) / (Vector3D.angleBetween(p_tl, p_br) * __toDegrees);				//next.ppd = ts * (1 << t) / rootDiagonalFOV;								attemptChildren.push(next);				tile.tl = next;				next = next.n;								// tr				if ((c + 1) * ts <= tilePyramid.widths[t]){					next.tilePyramid = tilePyramid;					next.t = t;					next.r = r;					next.c = c + 1;					next.p = tile;					next.vertex = vertex;					next.url = tilePyramid.getTileURL(t, next.c, next.r);					p_tl = new Vector3D();					p_tl[colAxis] = (v_0_colAxis + distC * splitCb) - onePixelC;					p_tl[rowAxis] = (v_0_rowAxis + distR * splitRa) - onePixelR;					p_tl[constAxis] = v_0_constAxis;					p_tr = new Vector3D();					p_tr[colAxis] = (v_0_colAxis + distC * splitCc) + onePixelC;					p_tr[rowAxis] = (v_0_rowAxis + distR * splitRa) - onePixelR;					p_tr[constAxis] = v_0_constAxis;					p_br = new Vector3D();					p_br[colAxis] = (v_0_colAxis + distC * splitCc) + onePixelC;					p_br[rowAxis] = (v_0_rowAxis + distR * splitRb) + onePixelR;					p_br[constAxis] = v_0_constAxis;					p_bl = new Vector3D();					p_bl[colAxis] = (v_0_colAxis + distC * splitCb) - onePixelC;					p_bl[rowAxis] = (v_0_rowAxis + distR * splitRb) + onePixelR;					p_bl[constAxis] = v_0_constAxis;					next.rawVertices.push(p_tl, p_tr, p_br, p_bl);					prepopulateDrawingData(next);					// this is accurate but causes cracks					next.ppd = (Vector3D.distance(p_tl, p_br) * scalar) / (Vector3D.angleBetween(p_tl, p_br) * __toDegrees);					//next.ppd = ts * (1 << t) / rootDiagonalFOV;					attemptChildren.push(next);					tile.tr = next;					next = next.n;				}								// bl				if ((r + 1) * ts <= tilePyramid.heights[t]) {					next.tilePyramid = tilePyramid;					next.t = t;					next.r = r + 1;					next.c = c;					next.p = tile;					next.vertex = vertex;					next.url = tilePyramid.getTileURL(t, next.c, next.r);					p_tl = new Vector3D();					p_tl[colAxis] = (v_0_colAxis + distC * splitCa) - onePixelC;					p_tl[rowAxis] = (v_0_rowAxis + distR * splitRb) - onePixelR;					p_tl[constAxis] = v_0_constAxis;					p_tr = new Vector3D();					p_tr[colAxis] = (v_0_colAxis + distC * splitCb) + onePixelC;					p_tr[rowAxis] = (v_0_rowAxis + distR * splitRb) - onePixelR;					p_tr[constAxis] = v_0_constAxis;					p_br = new Vector3D();					p_br[colAxis] = (v_0_colAxis + distC * splitCb) + onePixelC;					p_br[rowAxis] = (v_0_rowAxis + distR * splitRc) + onePixelR;					p_br[constAxis] = v_0_constAxis;					p_bl = new Vector3D();					p_bl[colAxis] = (v_0_colAxis + distC * splitCa) - onePixelC;					p_bl[rowAxis] = (v_0_rowAxis + distR * splitRc) + onePixelR;					p_bl[constAxis] = v_0_constAxis;					next.rawVertices.push(p_tl, p_tr, p_br, p_bl);					Tile.prepopulateDrawingData(next);					// this is accurate but causes cracks					next.ppd = (Vector3D.distance(p_tl, p_br) * scalar) / (Vector3D.angleBetween(p_tl, p_br) * __toDegrees);					//next.ppd = ts * (1 << t) / rootDiagonalFOV;					attemptChildren.push(next);					tile.bl = next;					next = next.n;				}								// br				if (((r + 1) * ts <= tilePyramid.heights[t]) && ((c + 1) * ts <= tilePyramid.widths[t])){					next.tilePyramid = tilePyramid;					next.t = t;					next.r = r + 1;					next.c = c + 1;					next.p = tile;					next.vertex = vertex;					next.url = tilePyramid.getTileURL(t, next.c, next.r);					p_tl = new Vector3D();					p_tl[colAxis] = (v_0_colAxis + distC * splitCb) - onePixelC;					p_tl[rowAxis] = (v_0_rowAxis + distR * splitRb) - onePixelR;					p_tl[constAxis] = v_0_constAxis;					p_tr = new Vector3D();					p_tr[colAxis] = (v_0_colAxis + distC * splitCc) + onePixelC;					p_tr[rowAxis] = (v_0_rowAxis + distR * splitRb) - onePixelR;					p_tr[constAxis] = v_0_constAxis;					p_br = new Vector3D();					p_br[colAxis] = (v_0_colAxis + distC * splitCc) + onePixelC;					p_br[rowAxis] = (v_0_rowAxis + distR * splitRc) + onePixelR;					p_br[constAxis] = v_0_constAxis;					p_bl = new Vector3D();					p_bl[colAxis] = (v_0_colAxis + distC * splitCb) - onePixelC;					p_bl[rowAxis] = (v_0_rowAxis + distR * splitRc) + onePixelR;					p_bl[constAxis] = v_0_constAxis;					next.rawVertices.push(p_tl, p_tr, p_br, p_bl);					Tile.prepopulateDrawingData(next);					// this is accurate but causes cracks (without overlap, and shimmer)					next.ppd = (Vector3D.distance(p_tl, p_br) * scalar) / (Vector3D.angleBetween(p_tl, p_br) * __toDegrees);					//next.ppd = ts * (1 << t) / rootDiagonalFOV;					attemptChildren.push(next);					tile.br = next;					next = next.n;				}				// nullify n of the last tile in the child set.				if (tile.br) tile.br.n = null;				else if (tile.bl) tile.bl.n = null;				else if (tile.tr) tile.tr.n = null;				else tile.tl.n = null;			}			//Tile.vertices = {};		}						static private function prepopulateDrawingData(tile:Tile):void{			var vertex:Vector3D;			/*			A_________B			| .       |			|    .    |			|       . |			D_________C			*/			// first triangle			// A			vertex = tile.rawVertices[0];				tile.vertices.push(vertex.x, vertex.y, vertex.z);				tile.indices.push(0);				tile.uvtData.push(0, 0, -1);						// B			vertex = tile.rawVertices[1];				tile.vertices.push(vertex.x, vertex.y, vertex.z);				tile.indices.push(1);				tile.uvtData.push(1, 0, -1);						// C			vertex = tile.rawVertices[2];				tile.vertices.push(vertex.x, vertex.y, vertex.z);				tile.indices.push(2);				tile.uvtData.push(1, 1, -1);						// second triangle			// C 				tile.indices.push(2);						// D			vertex = tile.rawVertices[3];				tile.vertices.push(vertex.x, vertex.y, vertex.z);				tile.indices.push(3);				tile.uvtData.push(0, 1, -1);						// A			tile.indices.push(0);		}				final public function expirationHandler(e:TimerEvent):void{			// restart the timer since tile is still displaying			if (displaying) {				expirationTimer.start()			}else {				bitmapLoaded = false;				bitmapData.dispose();				bitmapData = graphicsBitmapFill.bitmapData = null;				expirationTimer.removeEventListener(TimerEvent.TIMER, expirationHandler);			}		}				protected function rootParentLoadCompleteHandler(event:Event):void {			bitmapLoading = false;			bitmapLoaded = true;			previewUvtData.length = 0;			try{				bitmapData = graphicsBitmapFill.bitmapData = Bitmap(LoaderInfo(event.target).content).bitmapData;			}catch(e:Error){}			graphicsTrianglePath.uvtData = uvtData;			LoaderInfo(event.target).removeEventListener(Event.COMPLETE, rootParentLoadCompleteHandler);			LoaderInfo(event.target).removeEventListener(IOErrorEvent.IO_ERROR, rootParentLoadCompleteHandler);			dispatchEvent(new ReadyEvent(ReadyEvent.READY, tilePyramid));		}				override public function toString():String{			return "[Tile] " +url;		}				private const __toDegrees:Number = 180 / Math.PI;		private static const __toDegrees:Number = 180 / Math.PI;	}}