/*
 * Copyright (c) 2010 the original author or authors.
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package stealth.layouts
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	import flight.layouts.Bounds;
	import flight.layouts.IBounds;

	public class DockLayout extends BasicLayout
	{
		protected var dockMeasured:Bounds = new Bounds();
		protected var dockMargin:Box = new Box();
		protected var tileRect:Rectangle = new Rectangle();
		protected var lastDock:String = null;
		protected var tiling:Boolean;
		
		protected var tileWidth:Number;
		protected var tileHeight:Number;
		protected var measuredWidth:Number;
		protected var measuredHeight:Number;
		
		private var validDockValues:Array = [Align.LEFT, Align.TOP, Align.RIGHT, Align.BOTTOM, Align.JUSTIFY];
		
		public function DockLayout()
		{
			watchContent("dock");
			watchContent("tile");
		}
		
		override public function measure():void
		{
			dockMeasured.width = dockMeasured.minWidth = padding.left + padding.right;
			dockMeasured.height = dockMeasured.minHeight = padding.top + padding.bottom;
			dockMeasured.maxWidth = dockMeasured.maxHeight = 0xFFFFFF;
			measuredWidth = measuredHeight = 0;
			
			super.measure();
			
			var measured:IBounds = target.measured;
			measured.minWidth = dockMeasured.constrainWidth(measured.minWidth);
			measured.minHeight = dockMeasured.constrainHeight(measured.minHeight);
			measured.maxWidth = dockMeasured.constrainWidth(measured.maxWidth);
			measured.maxHeight = dockMeasured.constrainHeight(measured.maxHeight);
			dockMeasured.width = measuredWidth;
			dockMeasured.height = measuredHeight;
			if (measured.width < dockMeasured.width) {
				measured.width = dockMeasured.width;
			}
			if (measured.height < dockMeasured.height) {
				measured.height = dockMeasured.height;
			}
		}
		
		override protected function measureChild(child:DisplayObject, last:Boolean = false):void
		{
//			if (!(child is IStyleable)) {
//				return;
//			}
			
			var style:Object = {};//IStyleable(child).style;
			var dock:String = style.dock;
			var tile:String = style.tile;
			if (tile) {
				if (tile == Align.LEFT || tile == Align.RIGHT) {
					if (dock != Align.BOTTOM) {
						dock = Align.TOP;
					}
				} else if (tile == Align.TOP || tile == Align.BOTTOM) {
					if (dock != Align.RIGHT) {
						dock = Align.LEFT;
					}
				} else {
					tile = null;
				}
			}
			if (!dock || validDockValues.indexOf(dock) == -1) {
				super.measureChild(child, last);
				return;
			}
			
			var space:Number;
			var m:String;
			if (!tile) {
				if (tiling) {
					if (lastDock == Align.LEFT || lastDock == Align.RIGHT) {
						measuredWidth += tileWidth;
						dockMeasured.minHeight -= padding.vertical;
					} else {
						measuredHeight += tileHeight;
						dockMeasured.minWidth -= padding.horizontal;
					}
					childMargin.merge(dockMargin.clone(contentMargin));
					tiling = false;
				}
			} else if (!tiling || dock != lastDock) {
				contentMargin.clone(dockMargin);
				tileWidth = tileHeight = 0;
				tiling = true;
			}
			
			if (dock == Align.LEFT || dock == Align.RIGHT) {
				m = dock == Align.LEFT ? Align.RIGHT : Align.LEFT;
				if (tile) {
					if (tile == Align.TOP) {
						contentMargin.top = childMargin.bottom;
						space = childMargin.top;
					} else {
						contentMargin.bottom = childMargin.top;
						space = childMargin.bottom;
					}
					tileHeight += space + childBounds.height + padding.vertical;
					space = childBounds.width + childMargin[dock] + padding.horizontal;
					if (tileWidth + dockMargin[dock] < space + childMargin[m]) {
						tileWidth = space;
						dockMargin[dock] = childMargin[m];
					}
					dockMeasured.minWidth = dockMeasured.constrainWidth(measuredWidth + tileWidth);
					dockMeasured.minHeight = dockMeasured.constrainHeight(measuredHeight + tileHeight);
				} else {
					if (dock == Align.LEFT) {
						contentMargin.left = childMargin.right;
						space = childMargin.left;
					} else {
						contentMargin.right = childMargin.left;
						space = childMargin.right;
					}
					measuredWidth += childBounds.width + space + padding.horizontal;
					space = measuredHeight + childMargin.top + childMargin.bottom;
					dockMeasured.minWidth = dockMeasured.constrainWidth(measuredWidth);
					dockMeasured.minHeight = dockMeasured.constrainHeight(space + childBounds.minHeight);
					dockMeasured.maxHeight = dockMeasured.constrainHeight(space + childBounds.maxHeight);
				}
			} else if (dock == Align.TOP || dock == Align.BOTTOM) {
				m = dock == Align.TOP ? Align.BOTTOM : Align.TOP;
				if (tile) {
					if (tile == Align.LEFT) {
						contentMargin.left = childMargin.right;
						space = childMargin.left;
					} else {
						contentMargin.right = childMargin.left;
						space = childMargin.right;
					}
					tileWidth += childBounds.width + space + padding.horizontal;
					space = childBounds.height + childMargin[dock] + padding.vertical;
					if (tileHeight + dockMargin[dock] < space + childMargin[m]) {
						tileHeight = space;
						dockMargin[dock] = childMargin[m];
					}
					dockMeasured.minWidth = dockMeasured.constrainWidth(measuredWidth + tileWidth);
					dockMeasured.minHeight = dockMeasured.constrainHeight(measuredHeight + tileHeight);
				} else {
					if (dock == Align.TOP) {
						contentMargin.top = childMargin.bottom;
						space = childMargin.top;
					} else {
						contentMargin.bottom = childMargin.top;
						space = childMargin.bottom;
					}
					measuredHeight += childBounds.height + space + padding.vertical;
					space = measuredWidth + childMargin.left + childMargin.right;
					dockMeasured.minHeight = dockMeasured.constrainHeight(measuredHeight);
					dockMeasured.minWidth = dockMeasured.constrainWidth(space + childBounds.minWidth);
					dockMeasured.maxWidth = dockMeasured.constrainWidth(space + childBounds.maxWidth);
				}
			} else {	// if (dock == JUSTIFY) {
				space = measuredWidth + childMargin.left + childMargin.right + padding.horizontal;
				dockMeasured.minWidth = dockMeasured.constrainWidth(space + childBounds.minWidth);
				dockMeasured.maxWidth = dockMeasured.constrainWidth(space + childBounds.maxWidth);
				
				space = measuredHeight + childMargin.top + childMargin.bottom + padding.vertical;
				dockMeasured.minHeight = dockMeasured.constrainHeight(space + childBounds.minHeight);
				dockMeasured.maxHeight = dockMeasured.constrainHeight(space + childBounds.maxHeight);
			}
			
			if (last) {
				// remove the last pad and add the last margin
				switch (lastDock) {
					case Align.LEFT: dockMeasured.minWidth += childMargin.right - padding.horizontal; break;
					case Align.TOP: dockMeasured.minHeight += childMargin.bottom - padding.vertical; break;
					case Align.RIGHT: dockMeasured.minWidth += childMargin.left - padding.horizontal; break;
					case Align.BOTTOM: dockMeasured.minHeight += childMargin.top - padding.vertical; break;
				}
				lastDock = null;
				tiling = false;
			} else {
				lastDock = dock;
			}
		}
		
		override protected function updateChild(child:DisplayObject, last:Boolean = false):void
		{
//			if (!(child is IStyleable)) {
//				return;
//			}
			
			var style:Object = {};//IStyleable(child).style;
			var dock:String = style.dock;
			var tile:String = style.tile;
			if (tile) {
				if (tile == Align.LEFT || tile == Align.RIGHT) {
					if (dock != Align.BOTTOM) {
						dock = Align.TOP;
					}
				} else if (tile == Align.TOP || tile == Align.BOTTOM) {
					if (dock != Align.RIGHT) {
						dock = Align.LEFT;
					}
				} else {
					tile = null;
				}
			}
			if (!dock || validDockValues.indexOf(dock) == -1) {
				super.updateChild(child, last);
				return;
			}
			
			if (!tile) {
				if (tiling) {
					childMargin.merge(dockMargin.clone(contentMargin));
					tiling = false;
				}
				dockChild(dock, contentRect, childMargin);
				updateArea(dock, contentRect, contentMargin);
			} else {
				if (!tiling || dock != lastDock) {
					tiling = true;
					contentMargin.clone(dockMargin);
					tileRect.x = contentRect.x;
					tileRect.y = contentRect.y;
					tileRect.width = contentRect.width;
					tileRect.height = contentRect.height;
				}
				
				tileChild(tile, dock, tileRect, childMargin);
				updateArea(tile, tileRect, contentMargin);
				updateArea(dock, contentRect, dockMargin);
			}
			
			if (last) {
				lastDock = null;
				tiling = false;
			} else {
				lastDock = dock;
			}
		}
		
		protected function dockChild(dock:String, area:Rectangle, margin:Box):void
		{
			switch (dock) {
				case Align.LEFT:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					childBounds.height = area.height - margin.top - margin.bottom;
					break;
				case Align.TOP:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					childBounds.width = area.width - margin.left - margin.right;
					break;
				case Align.RIGHT:
					childBounds.x = area.x + area.width - childBounds.width - margin.right;
					childBounds.y = area.y + margin.top;
					childBounds.height = area.height - margin.top - margin.bottom;
					break;
				case Align.BOTTOM:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + area.height - childBounds.height - margin.bottom;
					childBounds.width = area.width - margin.left - margin.right;
					break;
				case Align.JUSTIFY:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					childBounds.height = area.height - margin.top - margin.bottom;
					childBounds.width = area.width - margin.left - margin.right;
					break;
			}
		}
		
		protected function tileChild(tile:String, dock:String, area:Rectangle, margin:Box):void
		{
			switch (tile) {
				case Align.LEFT:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					if (dock == Align.BOTTOM) {
						childBounds.y = area.y + area.height - childBounds.height - margin.bottom;
					}
					break;
				case Align.TOP:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					if (dock == Align.RIGHT) {
						childBounds.x = area.x + area.width - childBounds.width - margin.right;
					}
					break;
				case Align.RIGHT:
					childBounds.x = area.x + area.width - childBounds.width - margin.right;
					childBounds.y = area.y + margin.top;
					if (dock == Align.BOTTOM) {
						childBounds.y = area.y + area.height - childBounds.height - margin.bottom;
					}
					break;
				case Align.BOTTOM:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + area.height - childBounds.height - margin.bottom;
					if (dock == Align.RIGHT) {
						childBounds.x = area.x + area.width - childBounds.width - margin.right;
					}
					break;
				case Align.JUSTIFY:
					childBounds.x = area.x + margin.left;
					childBounds.y = area.y + margin.top;
					break;
			}
		}
		
		protected function updateArea(align:String, area:Rectangle, margin:Box):void
		{
			var pos:Number;
			switch (align) {
				case Align.LEFT:
					pos = childBounds.x + childBounds.width + padding.horizontal;
					if (area.left + margin.left < pos + childMargin.right) {
						area.left = pos;
						margin.left = childMargin.right;
					}
					break;
				case Align.TOP:
					pos = childBounds.y + childBounds.height + padding.vertical;
					if (area.top + margin.top < pos + childMargin.bottom) {
						area.top = pos;
						margin.top = childMargin.bottom;
					}
					break;
				case Align.RIGHT:
					pos = childBounds.x - padding.horizontal;
					if (area.right - margin.right > pos - childMargin.left) {
						area.right = pos;
						margin.right = childMargin.left;
					}
					break;
				case Align.BOTTOM:
					pos = childBounds.y - padding.vertical;
					if (area.bottom - margin.bottom > pos - childMargin.top) {
						area.bottom = pos;
						margin.bottom = childMargin.top;
					}
					break;
			}
		}
	}
}
