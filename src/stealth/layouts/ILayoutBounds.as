/*
 * Copyright (c) 2010 the original author or authors.
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package stealth.layouts
{
	import flash.geom.Rectangle;

	import flight.layouts.IBounds;
	import flight.layouts.IMeasureable;

	/**
	 * A simple box-model layout element containing size and bounds logic,
	 * including measured and explicit sizing.
	 */
	public interface ILayoutBounds extends IBounds, IMeasureable
	{
		/**
		 * Specifies whether this instance will participate in layout or will
		 * remain freeform. If false its size and position may be controlled
		 * by the layout, otherwise it determines its own size and position.
		 * 
		 * @default		false
		 */
		function get freeform():Boolean;
		function set freeform(value:Boolean):void;
		
		/**
		 * The actual x position of the bounds relative to the local coordinates
		 * of the parent. Explicitly set values may be overridden by layout.
		 * 
		 * @default		0
		 */
		function get x():Number;
		function set x(value:Number):void;
		
		/**
		 * The actual y position of the bounds relative to the local coordinates
		 * of the parent. Explicitly set values may be overridden by layout.
		 * 
		 * @default		0
		 */
		function get y():Number;
		function set y(value:Number):void;
		
		/**
		 * The width of the bounds as a percentage of the parent's total size,
		 * relative to the local coordinates of the parent. The percentWidth
		 * is a value from 0 to 100, where 100 equals 100% of the parent's
		 * total size.
		 * 
		 * @default		NaN
		 */
		function get percentWidth():Number;
		function set percentWidth(value:Number):void;
		
		/**
		 * The height of the bounds as a percentage of the parent's total size,
		 * relative to the local coordinates of the parent. The percentHeight
		 * is a value from 0 to 100, where 100 equals 100% of the parent's
		 * total size.
		 * 
		 * @default		NaN
		 */
		function get percentHeight():Number;
		function set percentHeight(value:Number):void;
		
		/**
		 * The explicitly set bounds of this bounds instance. Actual values
		 * may differ from those explicitly set based on layout adjustments.
		 */
		function get explicit():IBounds;
		
		/**
		 * The space surrounding the layout, relative to the local coordinates
		 * of the parent. The space is defined as a box with left, top, right
		 * and bottom coordinates.
		 */
		function get margin():Box;
		
		/**
		 * Calculates a bounding rectangle surrounding the bounds based on the
		 * supplied width and height, relative to the local coordinates of the
		 * parent. The width and height can be any dimensions desired, such as
		 * min or max, defaulting to the preferred width and height if no
		 * values are supplied.
		 * 
		 * @param		width		The layout width around which to calculate
		 * 							a bounding rectangle.
		 * @param		height		The layout height around which to calculate
		 * 							a bounding rectangle.
		 * @return					The bounding rectangle in the parent's
		 * 							coordinates. Note that the returned
		 * 							rectangle may be the same instance; cloning
		 * 							the result will guarantee a unique value.
		 */
		function getLayoutRect(width:Number = NaN, height:Number = NaN):Rectangle
		
		/**
		 * Allows layout position and size to be set, overriding explicit
		 * values, and is relative to the local coordinates of the parent.
		 * 
		 * @param		rect		The bounding rectangle in the parent's
		 * 							coordinates.
		 */
		function setLayoutRect(rect:Rectangle):void;
		
	}
}
