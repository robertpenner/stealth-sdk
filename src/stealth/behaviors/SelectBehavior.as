/*
 * Copyright (c) 2010 the original author or authors.
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package stealth.behaviors
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	import flight.data.DataChange;
	import flight.events.ButtonEvent;

	public class SelectBehavior extends Behavior
	{
		public function SelectBehavior()
		{
			dataBind.bind(this, "selected", this, "target.selected", true);
		}
		
		[Bindable("propertyChange")]
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void
		{
			DataChange.change(this, "selected", _selected, _selected = value);
		}
		private var _selected:Boolean;
		
		override protected function attach():void
		{
			super.attach();
			ButtonEvent.initialize(target as InteractiveObject);
			target.addEventListener(MouseEvent.CLICK, onClick, false, 10, true);
		}
		
		override protected function detach():void
		{
			super.detach();
			target.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function onClick(event:MouseEvent):void
		{
			selected = !selected;
			event.updateAfterEvent();
		}
		
	}
}
