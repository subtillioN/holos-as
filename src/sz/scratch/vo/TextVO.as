package sz.scratch.vo
{
	public class TextVO
	{
		public var bold : Boolean;
		public var variant : String;
		public var font : String;
		public var content : String;
		public var size : Number;
		public var width : Number;
		public var id : String;
		public var align : String;
		public var color : Number;
		public var colorID : Number;
		public var colorHex : String;
		public var alpha : Number;
		public var letterSpacing : Number;
		public var upperCase : Boolean;
		public var kerning : Boolean;
		public var leading : Number;
		public var thickness : Number;
		public var underline : Boolean;
		public var x : Number = NaN;
		public var y : Number = NaN;
		public var antiAliasTypeAdvanced : Boolean = false ;
		public var pixelSnap : Boolean = true;


		public function toString() : String
		{
			return "[TextVO]";

		}
	}
}
