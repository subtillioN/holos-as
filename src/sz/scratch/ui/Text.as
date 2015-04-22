package sz.scratch.ui
{
	import sz.scratch.utils.Populite;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * Text is used to centralize font embedding and formatting of titles across the Mazda5 application.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Nov 17, 2009
	 *
	 */

	public class Text extends Sprite
	{
		public var field : TextField;
		public static const UPDATE_FORMAT : String = "update_format";

		/**
		 * Sets the text parameters for the title
		 *
		 * @param $string       String - The string to be set as the text
		 * @param $populateID   String - The ID for use with Populate or Populite functionality
		 * @param $multiline    Boolean - Determines if the title can allow wrap to multiple lines
		 * @param $align        String - Determines the alignment based on the common TextField alignment string values
		 * @param $useHTMLColor Boolean - can override the text values in the Populate tags based on the hmt tags in the string
		 */
		public function setText(
				$string : String = null,
				$populateID : String = null,
				$multiline : Boolean = false,
				$align : String = null,
				$useHTMLColor : Boolean = false,
		        $replace : String = null,
		        $with : String = null
				) : void
		{
			Populite.instance.addEventListener(Populite.FORMATS_PARSED, _onFormatting);
			if(!field)
			{
				field = new TextField();
				if($multiline)
				{
					var textFormat : TextFormat = new TextFormat();
					if($align) textFormat.align = $align;
					field.defaultTextFormat = textFormat;
					if($align) field.autoSize = $align;
				}

				field.embedFonts = true;
				field.selectable = false;
				addChild(field);
			}
			if($populateID)
			{
				if(!$string)Populite.instance.text(field, $populateID, $replace, $with, true, $multiline, $align, $useHTMLColor, true);
				else Populite.instance.font(field, $populateID, $string, true, $multiline, $align, true);
			}
		}

		private function _onFormatting(event : Event) : void
		{
			dispatchEvent(new Event(UPDATE_FORMAT));
		}
	}
}
