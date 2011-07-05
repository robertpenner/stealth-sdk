package stealth.containers
{
	import flight.data.DataChange;

	public class Graphic extends Group
	{
		public function Graphic()
		{
		}
		
		[Bindable(event="versionChange", style="noEvent")]
		public function get version():Number { return _version; }
		public function set version(value:Number):void
		{
			DataChange.change(this, "version", _version, _version = value);
		}
		private var _version:Number = 1;
		
		public function get viewWidth():Number { return width; }
		public function set viewWidth(value:Number):void { width = value; }
		
		public function get viewHeight():Number { return height; }
		public function set viewHeight(value:Number):void { height = value; }
	}
}
