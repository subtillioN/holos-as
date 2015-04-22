package sz.scratch.ui
{
	import com.mazda.mazda5.common.ui.*;

	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;


	/**
	 * Image is a basic image display class encapsulating loading functionality and image alignment,
	 * as well as a loading animation.
	 *
	 * @version 1.0
	 * @since Apr 13, 2010
	 *
	 */
	public class TextDisplay extends Sprite
	{

		private var _textA : Text;
		private var _textB : Text;
		private var _inText : Text;
		private var _outText : Text;
		private var _textToggle : Boolean = true;

		private var _transitionIN : Function;
		private var _transitionOUT : Function;
		private var _populateID : String;
		public static const ALIGN_BOTTOM : String = "align_top";
		private var _alignY : String;
		private var _yInOffset : Number = 0;
		private var _xOffset : Number;

		public function TextDisplay($populateID : String = null) : void
		{
			if($populateID) _populateID = $populateID;
			_textA = new Text();
			_textB = new Text();
			_textA.visible = _textB.visible = false;
			_textA.alpha = _textB.alpha = 0;
			addChild(_textA);
			addChild(_textB);
		}

		/**
		 * Loads the image
		 */
		public function setText($string : String = null, $populateID : String = null, $multiline : Boolean = false, $align : String = null, $useHTMLColor : Boolean = false, $replace : String = null, $with : String = null) : void
		{
			this.visible = true;
			if($populateID) _populateID = $populateID;

			if(_textToggle)
			{
				_inText = _textA;
				_outText = _textB;
			}
			else
			{
				_inText = _textB;
				_outText = _textA;
			}
			_textToggle = !_textToggle;


			_inText.setText(
					$string,
					_populateID,
					$multiline,
					$align,
					$useHTMLColor,
					$replace,
					$with);
		}

		private function _align() : void
		{
			if(_alignY)
			{
				switch(_alignY)
				{
					case ALIGN_BOTTOM:
						_inText.y = -_inText.height + _yInOffset;
						break;
					//TODO: flesh out the other cases
					default:
				}
			}
			else _inText.y = _yInOffset;
		}

		public function start() : void
		{
			_align();
			_transitionInText();
			_transitionOutText();
		}

		private function _transitionInText() : void
		{
			_inText.visible = true;
			addChild(_inText);
			if(_transitionIN != null)
			{
				_transitionIN(_inText);
			}
			else
			{
				_inText.alpha = 1;
			}
		}

		private function _transitionOutText() : void
		{
			if(_transitionOUT != null)
			{
				_transitionOUT(_outText);
			}
			else
			{
				_outText.alpha = 0;
				_outText.visible = false;
			}
		}


		public function destroy() : void
		{
			_textA = null;
			_textB = null;
		}


		public function hide() : void
		{
			this.visible = false;
			this.alpha = 0;
		}


		override public function toString() : String
		{
			return "[" + getQualifiedClassName(this) + "] ";
		}

		public function set transitionIN(value : Function) : void
		{
			_transitionIN = value;
		}

		public function set transitionOUT(value : Function) : void
		{
			_transitionOUT = value;
		}

		public function set alignY(alignY : String) : void {_alignY = alignY;}

		public function set yInOffset($value : Number) : void
		{
			_yInOffset = $value;
		}

		public function get textHeight() : Number
		{
			return _inText.field.textHeight;
		}

		public function set xOffset(xOffset : Number) : void {_xOffset = xOffset;}
	}
}