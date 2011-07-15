﻿/*
 * Copyright (c) 2010 the original author or authors.
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package stealth.graphics
{
	import flash.display.DisplayObject;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.IGraphicsData;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import flight.collections.ArrayList;
	import flight.collections.IList;
	import flight.containers.IContainer;
	import flight.data.DataChange;
	import flight.data.IPosition;
	import flight.data.Position;
	import flight.events.InvalidationEvent;
	import flight.events.LayoutEvent;
	import flight.events.ListEvent;
	import flight.layouts.ILayout;
	
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	
	import stealth.graphics.GraphicElement;
	import stealth.graphics.paint.IPaint;
	import stealth.graphics.paint.Paint;
	
	[Event(name="validate", type="flight.events.InvalidationEvent")]

	[DefaultProperty("content")]
	public class Group extends GraphicElement implements IContainer
	{
		public function Group(content:* = null)
		{
			addEventListener(Event.ADDED, onChildAdded, true, 10);
			addEventListener(Event.REMOVED, onChildRemoved, true, 10);
			
			_content = new ArrayList();
			for (var i:int = 0; i < numChildren; i++) {
				_content.add(getChildAt(i));
			}
			_content.addEventListener(ListEvent.LIST_CHANGE, onContentChange, false, 10);
			if (content) {
				this.content = content;
			}
			
			layoutElement.snapToPixel = true;
		}
		
		// ====== background implementation ====== //
		
		private static var graphicsPath:GraphicsPath = new GraphicsPath(
			Vector.<int>([GraphicsPathCommand.MOVE_TO,
				GraphicsPathCommand.LINE_TO,
				GraphicsPathCommand.LINE_TO,
				GraphicsPathCommand.LINE_TO]),
			Vector.<Number>([0,0, 0,0, 0,0, 0,0, 0,0]));
		private static var graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		private static var pathBounds:Rectangle = new Rectangle();
		private static var endFill:GraphicsEndFill = new GraphicsEndFill();
		
		[Bindable(event="backgroundChange", style="noEvent")]
		public function get background():IPaint { return _background; }
		public function set background(value:*):void
		{
			value = Paint.getInstance(value);
			
			if (_background != value) {
				
				if (_background && _background is IEventDispatcher) {
					IEventDispatcher(_background).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPaintChange);
				}
				DataChange.change(this, "background", _background, _background = value);
				invalidate();
				if (_background && IEventDispatcher) {
					IEventDispatcher(_background).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPaintChange);
				} else if (!_background) {
					graphics.clear();
				}
			}
		}
		private var _background:IPaint;
		
		private function onPaintChange(event:PropertyChangeEvent):void
		{
			invalidate();
		}
		
		override protected function render():void
		{
			if (_background) {
				var data:Vector.<Number> = graphicsPath.data;
				data[2] = data[4] = width;
				data[5] = data[7] = height;
				pathBounds.width = width;
				pathBounds.height = height;
				
				graphicsData.length = 0;
				_background.update(graphicsPath, pathBounds);
				_background.paint(graphicsData);
				graphicsData.push(graphicsPath, endFill);
				
				graphics.clear();
				graphics.drawGraphicsData(graphicsData);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		[ArrayElementType("flash.display.DisplayObject")]
		[Bindable(event="contentChange", style="noEvent")]
		public function get content():IList { return _content; }
		override public function set content(value:*):void
		{
			ArrayList.getInstance(value, _content);
		}
		private var _content:ArrayList;
		
		/**
		 * @inheritDoc
		 */
		[Bindable(event="layoutChange", style="noEvent")]
		public function get layout():ILayout { return _layout; }
		public function set layout(value:ILayout):void
		{
			if (_layout != value) {
				if (_layout) {
					_layout.target = null;
				}
				DataChange.queue(this, "layout", _layout, _layout = value);
				if (_layout) {
					_layout.target = this;
				}
				DataChange.change();
			}
		}
		private var _layout:ILayout;
		
		[Bindable(event="contentWidthChange", style="noEvent")]
		public function get contentWidth():Number { return layoutElement.contentWidth; }
		public function set contentWidth(value:Number):void { layoutElement.contentWidth = value; }
		
		[Bindable(event="contentHeightChange", style="noEvent")]
		public function get contentHeight():Number { return layoutElement.contentHeight; }
		public function set contentHeight(value:Number):void { layoutElement.contentHeight = value; }
		
		[Bindable(event="hPositionChange", style="noEvent")]
		public function get hPosition():IPosition { return _hPosition || (hPosition = new Position()); }
		public function set hPosition(value:IPosition):void
		{
			if (_hPosition) {
				_hPosition.removeEventListener(Event.CHANGE, onPositionChange);
			}
			DataChange.change(this, "hPosition", _hPosition, _hPosition = value);
			if (_hPosition) {
				_hPosition.addEventListener(Event.CHANGE, onPositionChange);
			}
		}
		private var _hPosition:IPosition;
		
		[Bindable(event="vPositionChange", style="noEvent")]
		public function get vPosition():IPosition { return _vPosition || (vPosition = new Position()); }
		public function set vPosition(value:IPosition):void
		{
			if (_vPosition) {
				_vPosition.removeEventListener(Event.CHANGE, onPositionChange);
			}
			DataChange.change(this, "vPosition", _vPosition, _vPosition = value);
			if (_vPosition) {
				_vPosition.addEventListener(Event.CHANGE, onPositionChange);
			}
		}
		private var _vPosition:IPosition;
		
		[Bindable(event="clippedChange", style="noEvent")]
		public function get clipped():Boolean { return _clipped; }
		public function set clipped(value:Boolean):void
		{
			if (_clipped != value) {
				if (value) {
					addEventListener(LayoutEvent.RESIZE, onClippedResize);
					invalidate(LayoutEvent.RESIZE);
					layoutElement.contained = false;
				} else {
					removeEventListener(LayoutEvent.RESIZE, onClippedResize);
					layoutElement.contained = true;
				}
				DataChange.change(this, "clipped", _clipped, _clipped = value);
			}
		}
		private var _clipped:Boolean = false;
		
		override protected function measure():void
		{
			if (!layout) {
				super.measure();
			}
			if (!layoutElement.contained) {
				scrollRectSize();
			}
		}
		
		protected function scrollRectPosition():void
		{
			if (width < contentWidth || height < contentHeight) {
				var rect:Rectangle = scrollRect || new Rectangle();
				if (_hPosition) {
					rect.x = _hPosition.value;
				}
				if (_vPosition) {
					rect.y = _vPosition.value;
				}
				scrollRect = rect;
			}
		}
		
		protected function scrollRectSize():void
		{
			if (_hPosition) {
				_hPosition.minimum = 0;
				_hPosition.maximum = contentWidth - width;
				_hPosition.pageSize = width;
			}
			if (_vPosition) {
				_vPosition.minimum = 0;
				_vPosition.maximum = contentHeight - height;
				_vPosition.pageSize = height;
			}
			
			if (width < contentWidth || height < contentHeight) {
				var rect:Rectangle = scrollRect || new Rectangle();
				rect.width = width;
				rect.height = height;
				if (_hPosition) {
					rect.x = hPosition.value;
				}
				if (_vPosition) {
					rect.y = vPosition.value;
				}
				scrollRect = rect;
			} else if (scrollRect) {
				scrollRect = null;
			}
		}
		
		private function onClippedResize(event:Event):void
		{
			scrollRectSize();
		}
		
		private function onPositionChange(event:Event):void
		{
			scrollRectPosition();
		}
		
		private function onChildAdded(event:Event):void
		{
			var child:DisplayObject = DisplayObject(event.target);
			if (child.parent == this && !contentChanging) {
				contentChanging = true;
				content.add(child, getChildIndex(child));
				contentChanging = false;
				
				invalidate(LayoutEvent.MEASURE);
				invalidate(LayoutEvent.LAYOUT);
			}
		}
		
		private function onChildRemoved(event:Event):void
		{
			var child:DisplayObject = DisplayObject(event.target);
			if (child.parent == this && !contentChanging) {
				contentChanging = true;
				content.remove(child);
				contentChanging = false;
				
				invalidate(LayoutEvent.MEASURE);
				invalidate(LayoutEvent.LAYOUT);
			}
		}
		
		private function onContentChange(event:ListEvent):void
		{
			if (!contentChanging) {
				contentChanging = true;
				var child:DisplayObject;
				for each (child in event.removed) {
					removeChild(child);
				}
				for each (child in event.items) {
					addChildAt(child, _content.getIndex(child));
				}
				contentChanging = false;
				
				invalidate(LayoutEvent.MEASURE);
				invalidate(LayoutEvent.LAYOUT);
			}
		}
		private var contentChanging:Boolean;
	}
}