/*
 * Copyright (c) 2010 the original author or authors.
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package stealth.graphics.paint
{
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	public interface IPaint extends IEventDispatcher
	{
		function update(graphicsPath:GraphicsPath, pathBounds:Rectangle):void;
		
		function paint(graphicsData:Vector.<IGraphicsData>):void;
	}
}