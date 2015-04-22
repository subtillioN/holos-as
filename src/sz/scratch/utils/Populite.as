package sz.scratch.utils {
	import com.core.loaders.FontLoadCall;
	import com.core.mvc.AModel;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	import sz.scratch.data.PopuliteParser;
	import sz.scratch.vo.PopulateVO;
	import sz.scratch.vo.TextVO;

	//TODO :: BUG :: Adobe CS5 :: fix issue with new font system.
	/**
	 * Populite is a singleton that centralizes and facilitates
	 * the use of XML-derived text formatting throughout an application.
	 * It takes TextField formatting data from the xml,
	 * generates and applies <code>TextFormat</code>s, and
	 * manages the use and sharing of text formats and colors.
	 * It can also process and return <code>StyleSheet</code>
	 * objects from the config xml.
	 *
	 * <p>Populite is a light version of the Populate class, stripped of its
	 * dynamic font loading capabilities, and is meant for use with fonts embedded in the
	 * FLA.</p>
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 11.17.2009
	 */
	public class Populite extends EventDispatcher {
		private static var __instance : Populite;
		private var _model : AModel;
		private var _modelData : String;
		private var _variants : Dictionary;
		private var _lexicon : Dictionary;
		private var _formats : Dictionary;
		private var _colors : Dictionary;
		private var _styles : Dictionary;
		private var _txtSetQueue : Array;
		private var _fontSetQueue : Array;
		private var _pvo : PopulateVO;
		private var _initialized : Boolean = false;
		private var _defaultCSS : String = "main";
		public static const FORMATS_PARSED : String = "formats_parsed";

		public function Populite() {
			_txtSetQueue = new Array();
			_fontSetQueue = new Array();
			_variants = new Dictionary();
			_formats = new Dictionary();
			_colors = new Dictionary();
			_styles = new Dictionary();
		}

		/**
		 * Loads fonts once config has loaded
		 */
		public function init($pvo : PopulateVO, $model : AModel = null, $modelData : String = null) : PopulateVO {
			_initialized = true;
			_model = $model;
			_modelData = $modelData;
			_pvo = $pvo;
			if($pvo.lexicon)_lexicon = $pvo.lexicon;
			if($pvo.colors)_colors = $pvo.colors;
			if($pvo.styles)_styles = $pvo.styles;
//			_setupStyles();
			for each(var ta : Array in _txtSetQueue) {
				text.apply(this, ta);
			}
			for each(var fa : Array in _fontSetQueue) {
				font.apply(this, fa);
			}

			dispatchEvent(new Event(FORMATS_PARSED));
			return _pvo;
		}

		public static function get instance() : Populite {
			if(!__instance)__instance = new Populite();
			return __instance;
		}

		/**
		 * Populates, formats and returns the input TextField (or a new one) with the string
		 * and formatting data in the xml.  Has text replace functionality, as well
		 * as autosizing for single and multiline TextFields.
		 *
		 * @param	$txt			 TextField - the TextField to be formatted.
		 *							 It will create a new TextField if null is passed in.
		 * @param	$id			 String - the formatting ID in the xml,
		 *							 used for indexing and retrieval.
		 * @param	 $replace		 String - a substring in the xml text string to
		 *							 replace with the <code>$with</code> param.
		 * @param	 $with			 String - a substring to replace the
		 *							 <code>$replace</code> string value.
		 * @param	 $expand			Boolean - will set autosize to "left" if
		 *							 <code>true</code> and expand the TextField to fit
		 *							 the text string.
		 * @param	 $multiline		Boolean - works with <code>$expand</code> set to
		 *							 <code>true</code>.
		 *							 Expands a multiline TextField while retaining the
		 *							 original width using word wrapping
		 * @param	 $autosize		String - sets the autosize direction. Defaults to "left".
		 * @param	 $useHTMLColor	Boolean - true, allows the setting of color through html tags. Defaults to false.
		 * @return	TextField -	 the TextField in the first argument, or otherwise a
		 *							 new TextField if the first argument is null.
		 */
		public function text($txt : TextField, $id : String, $replace : String = null, $with : String = null, $expand : Boolean = false, $multiline : Boolean = false, $autosize : String = null, $useHTMLColor : Boolean = false, $html : Boolean = true) : TextField {
			if(!$txt)$txt = new TextField();
			if(!_initialized) {
				_txtSetQueue.push([$txt,$id,$replace,$with,$expand, $multiline, $autosize, $useHTMLColor, $html]);
			}
			else {
				if(!_checkLexiconID($id))return null;
				var tvo : TextVO = _lexicon[$id];
				$with = PopuliteParser.replaceContent($with, tvo.font);
				if(tvo.upperCase) {
					if(tvo.content)tvo.content = tvo.content.toUpperCase();
					if($with)$with = $with.toUpperCase();
				}
				if(tvo.width)$txt.width = tvo.width;
				if(tvo.alpha)$txt.alpha = tvo.alpha;
				if(tvo.thickness)$txt.thickness = tvo.thickness;
				$txt.antiAliasType = tvo.antiAliasTypeAdvanced ? AntiAliasType.ADVANCED : AntiAliasType.NORMAL;
				if(!tvo.align && !$autosize)$autosize = "left";
				else if(tvo.align) {
					$autosize = tvo.align;
				}
				var tf : TextFormat = _convertToTF(tvo, $id, $useHTMLColor);
				if(tf.size > 10) {
					$txt.antiAliasType = AntiAliasType.ADVANCED;
				}
				if($expand && !$multiline) {
					$txt.autoSize = $autosize;
					$txt.wordWrap = false;

				} else if($expand && $multiline) {
					$txt.autoSize = $autosize;
					$txt.wordWrap = true;
					$txt.multiline = true;
					$txt.height += 0;
				}
				if($html) {
					if(getStyleSheet(_defaultCSS)) {
						$txt.styleSheet = getStyleSheet("main");
						trace(this + '\r\r\rSET STYLESHEET');
//			content_txt.embedFonts = true;
//			content_txt.styleSheet = style;
					}
					if(!$replace)$txt.htmlText = tvo.content;
					else if(!$with)$txt.htmlText = "";
					else $txt.htmlText = tvo.content.split($replace).join($with);
				}
				else {
					if(!$replace)$txt.text = tvo.content;
					else if(!$with)$txt.text = "";
					else $txt.text = tvo.content.split($replace).join($with);
				}

				$txt.setTextFormat(tf);
				if(!isNaN(tvo.x))$txt.x = tvo.x;
				if(!isNaN(tvo.y))$txt.y = tvo.y;

			}
			return $txt;
		}

		/**
		 * Formats and returns the input TextField (or a new one) with the string
		 * and formatting data in the xml.  Has text replace functionality, as well
		 * as autosizing for single and multiline TextFields.
		 *
		 * @param	$txt		 TextField - the TextField to be formatted.
		 *						 It will create a new TextField if null is passed in.
		 * @param	$id		 String - the formatting ID in the xml,
		 *						 used for indexing and retrieval.
		 * @param	 $text		 String - a string to populate the TextField
		 *						 <code>htmlText</code> property
		 * @param	 $expand		Boolean - will set autosize to "left" if
		 *						 <code>true</code> and expand the TextField to fit
		 *						 the text string.
		 * @param	 $multiline	Boolean - works with <code>$expand</code> set to
		 *						 <code>true</code>.
		 *						 Expands a multiline TextField while retaining the
		 *						 original width using word wrapping
		 * @return	TextField - the TextField in the first argument, or otherwise a
		 *						 new TextField if the first argument is null.
		 */
		public function font($txt : TextField, $id : String, $text : String = null, $expand : Boolean = false, $multiline : Boolean = false, $autosize : String = null, $html : Boolean = true) : TextField {
			if(!$txt)$txt = new TextField();
			if(!_initialized) {
				_fontSetQueue.push([$txt,$id,$text,$expand, $multiline, $autosize, $html]);
			}
			else {
				if(!_checkLexiconID($id))return null;
				var tvo : TextVO = _lexicon[$id];
				$text = PopuliteParser.replaceContent($text, tvo.font);
				if(tvo.upperCase) {
					if($text)$text = $text.toUpperCase();
				}
				if(tvo.width)$txt.width = tvo.width;
				if(tvo.thickness)$txt.thickness = tvo.thickness;
				if(tvo.alpha)$txt.alpha = tvo.alpha;
				if(tvo.font)$txt.embedFonts = true;
				$txt.antiAliasType = tvo.antiAliasTypeAdvanced ? AntiAliasType.ADVANCED : AntiAliasType.NORMAL;
				if(!tvo.align && !$autosize)$autosize = "left";
				else if(tvo.align) {
					$autosize = tvo.align;
				}
				var tf : TextFormat = _convertToTF(tvo, $id);
				$txt.defaultTextFormat = tf;
				if($expand && !$multiline) {
					$txt.autoSize = $autosize;
					$txt.wordWrap = false;
				} else if($expand && $multiline) {
					$txt.autoSize = $autosize;
					$txt.wordWrap = true;
					$txt.multiline = true;
					$txt.height += 0;
				}
				if($text && $html) {

					$txt.htmlText = $text;
				}
				else if($text && !$html)$txt.text = $text;

				$txt.setTextFormat(tf);
				if(!isNaN(tvo.x))$txt.x = tvo.x;
				if(!isNaN(tvo.y))$txt.y = tvo.y;

			}
			return $txt;
		}

		private function _convertToTF(tvo : TextVO, $id : String, $useHTMLColor : Boolean = false) : TextFormat {
			if(!_formats[$id]) {
				var tf : TextFormat = new TextFormat();
				tf.bold = tvo.bold;
				if(tvo.size)tf.size = tvo.size;
				tf.letterSpacing = tvo.letterSpacing;
				tf.leading = tvo.leading;
				tf.kerning = tvo.kerning;
				tf.underline = tvo.underline;
				tf.align = tvo.align;
				if(tvo.font)tf.font = tvo.font;
				if(!$useHTMLColor)tf.color = tvo.color;
				_formats[$id] = tf;
				return tf;
			}
			else return _formats[$id];
		}


		/**
		 * Returns a textFormat from the _formats Dictionary based on id
		 */
		public function getTextFormat($id : String) : TextFormat {
			if(_formats[$id])return _formats[$id];
			else {
				var tvo : TextVO = getTextVO($id);
				if(tvo) {
					return _convertToTF(tvo, $id);
				}
			}
			trace(this + 'ERROR: NEITHER FORMAT NOR ID FOUND FOR : ' + $id);
			return null;
		}

		/**
		 * Returns a color from the _colors Dictionary based on id.
		 * For use in e.g. tweening between colors, etc. rather than setting a new format
		 */
		public function getColor($id : String) : Number {
			if(_colors[$id])return _colors[$id];
			trace(this + 'COLOR NOT FOUND FOR ' + $id);
			return NaN;
		}

		public function getColorHex($id : String) : String {
			return TextVO(getTextVO($id)).colorHex;
		}

		public function getStyleSheet($id : String) : StyleSheet {
			return _styles[$id];
		}

		private function _getFont(variant : String) : String {
			if(_pvo.embedded) return variant;
			var flc : FontLoadCall = _variants[variant];
			if(!flc)flc = _variants['all'];
			if(!flc)return '_sans';
			return flc.fontName;
		}

		private function _checkLexiconID($id : String) : Boolean {
			if(_lexicon) {
				if(!_lexicon[$id]) {
					trace(this + ' ERROR: text id not found for "' + $id + '".  Please update the XML');
					return false;
				}
			}
			else {
				trace(this + ' ERROR: lexicon not initialized/loaded before use');
				return false;
			}
			return true;
		}

		public function getTextVO($id : String) : TextVO {
			if(_lexicon && TextVO(_lexicon[$id])) return TextVO(_lexicon[$id]);
			else return null;
		}

		public function getString($id : String) : String {
			var s : String;
			if(getTextVO($id)) s = TextVO(getTextVO($id)).content;
			else s = "";
			return s;
		}

		public function parse($x : XML, $model : AModel = null, $modelData : String = null) : PopulateVO {
			return init(PopuliteParser.parse($x), $model, $modelData);
		}

		public static function parse($x : XML) : void {
			Populite.instance.parse($x);
		}

		override public function toString() : String {
			return '[Populite]';
		}

		public function set defaultCSS(value : String) : void {
			_defaultCSS = value;
		}
	}
}