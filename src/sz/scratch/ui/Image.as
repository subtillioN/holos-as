package sz.scratch.ui {
	import sz.scratch.ui.simple.*;
	import sz.scratch.ui.*;
	import com.core.events.LoadEvent;
	import com.core.loading.calls.LoaderCall;
	import com.core.utils.FBtrace;
	import com.core.utils.FlagSet;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	/**
	 * Image is a basic image display class encapsulating loading functionality and image alignment,
	 * as well as a loading animation.
	 *
	 * @version 1.0
	 * @since Apr 13, 2010
	 *
	 */
	public class Image extends Sprite {
		private var _url : String;
		private var _loadCall : LoaderCall;
		private var _smoothing : Boolean;
		private var _bitmap : Bitmap;
		private var _alphaImage : AlphaImage;
		private var _align_v : String = TOP;
		private var _align_h : String = LEFT;
		private var _xOffset : Number = 0;
		private var _yOffset : Number = 0;

		public static const RIGHT : String = "right";
		public static const LEFT : String = "left";
		public static const CENTER : String = "center";
		public static const BOTTOM : String = "bottom";
		public static const TOP : String = "top";
		public static const LOADING_COMPLETE : String = Event.COMPLETE;
		private var _width : Number;
		private var _height : Number;
		private var _background : Shape;
		private var _stroke : Shape;
		private var _backgroundColor : uint = 0xFFFFFF;
		private var _alphaURL : String;
		private var _flagSet : FlagSet;
		private const IMAGE_LOADED : String = "image_loaded";
		private const ALPHA_LOADED : String = "alpha_loaded";
		private var _alphaBitmap : Bitmap;
		private var _loadCallAlpha : LoaderCall;
		private var _hasStroke : Boolean = false;
		private var _strokeIsInner : Boolean = false;
		private var _strokeThickness : uint;
		private var _strokeColor : uint;
		private var _strokeAlpha : uint;
		private var _backgroundAlpha : Number;
		private var _loadingColor : uint = 0xFFFFFF;
		private var _transitionIN : Function;


		public function Image($url : String = null, $smoothing : Boolean = false, $align_h : String = null,
		                      $align_v : String = null, $width : Number = NaN, $height : Number = NaN,
		                      $loadImmediately : Boolean = true, $alphaURL : String = null) : void {
			_flagSet = new FlagSet([IMAGE_LOADED,ALPHA_LOADED], _onImageReady);
			_url = $url;
			_smoothing = $smoothing;
			_align_h = $align_h;
			_align_v = $align_v;
			_width = $width;
			_height = $height;
			if(!_url)return;
			if($loadImmediately) {
				load($url, $align_h, $align_v, $width, $height, $alphaURL);
			}
			else {
				setAlignProperties($align_h, $align_v);
				_setDimensions();
			}
		}

		/**
		 * Loads the image
		 */
		public function load($url : String = null, $align_h : String = null, $align_v : String = null,
		                     $width : Number = NaN, $height : Number = NaN, $alphaURL : String = null) : void {
			if($url) {
				_url = $url;
			}
			else {
				if(!_url) {
					FBtrace(this + ' FAILED TO LOAD IMAGE BECAUSE THE URL WAS NOT SPECIFIED');
					return;
				}
			}
			if($alphaURL) _alphaURL = $alphaURL;
			_flagSet.setFlag(ALPHA_LOADED, _alphaURL == null);
			_flagSet.setFlag(IMAGE_LOADED, false);
			if(!isNaN($width)) _width = $width;
			if(!isNaN($height)) _height = $height;
			setAlignProperties($align_h, $align_v);
			_setDimensions();
			if(_bitmap)_bitmap.bitmapData.dispose();
			_bitmap = null;
			if(_loadCall) _loadCall.cancel();
			_loadCall = new LoaderCall(_url);
			_loadCall.addEventListener(Event.COMPLETE, _onLoadBitmapComplete);
			_loadCall.addEventListener(LoadEvent.FAIL, _onLoadBitmapFail);
//			if(_loading) _loading.loadCall = _loadCall;
//			if(_loading) _loading.color = _loadingColor;
			_loadCall.load();

			// if available, progress alpha
			if(!_alphaURL)return;
			if(_alphaBitmap)_alphaBitmap.bitmapData.dispose();
			_alphaBitmap = null;
			if(_loadCallAlpha) _loadCallAlpha.cancel();
			_loadCallAlpha = new LoaderCall(_alphaURL);
			_loadCallAlpha.addEventListener(Event.COMPLETE, _onLoadAlphaComplete);
			_loadCallAlpha.addEventListener(LoadEvent.FAIL, _onLoadAlphaFail);
			_loadCallAlpha.load();
		}

		private function _transitionInImage() : void {
			if(_transitionIN != null) {
				_transitionIN(_bitmap);
			}
			else {
				_bitmap.alpha = 1;
				_bitmap.visible = true;
			}
		}

		public function hideImage():void{if(_bitmap)unload();}

		public function showImage():void{if(_bitmap)_transitionInImage();}

		public function set loadingColor($color : uint) : void {
			_loadingColor = $color;
		}

		private function _setDimensions() : void {
			if(!_width || !_height)return;
			setBackgroundColor(_backgroundColor, _backgroundAlpha);
			if(_stroke) addChild(_stroke);
		}

		private function _onImageReady() : void {
			if(!_alphaURL) {
				addChild(_bitmap);
				if(_stroke)addChild(_stroke);
				_align(_bitmap);
				if(_width)_bitmap.width = _width;
				if(_height)_bitmap.height = _height;
				_transitionInImage();
			}
			else {
				_alphaImage = new AlphaImage(_bitmap, _alphaBitmap);
				addChild(_alphaImage);
				_align(_alphaImage);
				if(_width)_alphaImage.width = _width;
				if(_height)_alphaImage.height = _height;
			}

			dispatchEvent(new Event(LOADING_COMPLETE));
		}


		public function setAlignProperties($align_h : String = null, $align_v : String = null) : void {
			if($align_h) _align_h = $align_h;
			if($align_v) {
				_align_v = $align_v;
			}
			else {
				if($align_h == CENTER)_align_v = CENTER;
			}
		}

		/**
		 * Handler for the <code>Event.COMPLETE</code> event on the image loader.
		 * Positions the image and adds it to the display list.
		 */
		private function _onLoadBitmapComplete($e : Event = null) : void {
			_loadCall.removeEventListener(Event.COMPLETE, _onLoadBitmapComplete);
			_loadCall.removeEventListener(LoadEvent.FAIL, _onLoadBitmapFail);
			_bitmap = _loadCall.content as Bitmap;
			_bitmap.alpha = 0;
			_loadCall.cancel();
			_loadCall = null;
			_bitmap.smoothing = _smoothing;
			_flagSet.setFlag(IMAGE_LOADED, true);
		}

		private function _onLoadAlphaComplete($e : Event = null) : void {
			_loadCallAlpha.removeEventListener(Event.COMPLETE, _onLoadAlphaComplete);
			_loadCallAlpha.removeEventListener(LoadEvent.FAIL, _onLoadAlphaFail);
			_alphaBitmap = _loadCallAlpha.content as Bitmap;
			_loadCallAlpha.cancel();
			_alphaBitmap.smoothing = _smoothing;
			_flagSet.setFlag(ALPHA_LOADED, true);
		}


		private function _align($DO : DisplayObject) : void {
			$DO.x = $DO.y = 0;
			switch(_align_h) {
				case "center":
					$DO.x = -Math.round($DO.width * 0.5);
					break;
				case "right":
					$DO.x = -$DO.width;
					break;
			}
			switch(_align_v) {
				case "center":
					$DO.y = -Math.round($DO.height * 0.5);
					break;
				case "bottom":
					$DO.y = -$DO.height;
					break;
			}
			$DO.x += _xOffset;
			$DO.y += _yOffset;
		}

		private function _onLoadBitmapFail($e : LoadEvent = null) : void {
			FBtrace(this + '_onLoadBitmapFail : Bitmap failed to progress, likely wrong path at ' + _url);
			_loadCall.removeEventListener(Event.COMPLETE, _onLoadBitmapComplete);
			_loadCall.removeEventListener(LoadEvent.FAIL, _onLoadBitmapFail);
		}

		private function _onLoadAlphaFail($e : LoadEvent = null) : void {
			FBtrace(this + '_onLoadAlphaFail : Alpha failed to progress, likely wrong path at ' + _alphaURL);
			_loadCall.removeEventListener(Event.COMPLETE, _onLoadAlphaComplete);
			_loadCall.removeEventListener(LoadEvent.FAIL, _onLoadAlphaFail);
		}


		public function unload() : void {
			if(_loadCall) _loadCall.cancel();
			if(_bitmap && _bitmap.bitmapData) {
				_bitmap.bitmapData.fillRect(getBounds(_bitmap),0x00000000);
				_bitmap.bitmapData.dispose();
				_bitmap = null;
			}
		}


		public function get smoothing() : Boolean {
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void {
			_smoothing = value;
		}

		public function get xOffset() : Number {
			return _xOffset;
		}

		public function set xOffset(value : Number) : void {
			_xOffset = value;
		}

		public function get yOffset() : Number {
			return _yOffset;
		}

		public function set yOffset(value : Number) : void {
			_yOffset = value;
		}

		public function get bitmapWidth() : Number {
			return _bitmap.width;
		}

		public function get bitmapHeight() : Number {
			return _bitmap.height;
		}

		public function get backgroundColor() : uint {
			return _backgroundColor;
		}

		public function setBackgroundColor($color : uint, $alpha : Number = .15, $width : Number = NaN,
		                                   $height : Number = NaN) : void {
			_backgroundColor = $color;
			_backgroundAlpha = $alpha;
			if(!isNaN($width))_width = $width;
			if(!isNaN($height))_height = $height;
			if(_width && _height) {
				if(!_background) {
					_background = new Shape();
				}
				else {
					_background.graphics.clear();
				}
				_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
				_background.graphics.drawRect(0, 0, _width, _height);
				_background.graphics.endFill();
			}
			addChild(_background);
			_align(_background);
			if(_hasStroke)_drawStroke()
		}

		private function _drawStroke() : void {
			if(!_stroke) {
				_stroke = new Shape();
			}
			else {
				_stroke.graphics.clear();
			}
			var innerA : Number;
			var innerOffset : Number;
			var outerA : Number;
			var outerOffset : Number;


			if(_strokeIsInner) {
				outerA = 0;
				outerOffset = 0;
				innerA = _strokeThickness;
				innerOffset = -_strokeThickness;
			}
			else {
				outerA = -_strokeThickness;
				outerOffset = _strokeThickness;
				innerA = 0;
				innerOffset = 0;
			}
			_stroke.graphics.beginFill(_strokeColor, _strokeAlpha);
			_stroke.graphics.moveTo(outerA, outerA);
			_stroke.graphics.lineTo(_width + outerOffset, outerA);
			_stroke.graphics.lineTo(_width + outerOffset, _height + outerOffset);
			_stroke.graphics.lineTo(outerA, _height + outerOffset);
			_stroke.graphics.lineTo(outerA, outerA);
			//inner
			_stroke.graphics.lineTo(innerA, innerA);
			_stroke.graphics.lineTo(_width + innerOffset, innerA);
			_stroke.graphics.lineTo(_width + innerOffset, _height + innerOffset);
			_stroke.graphics.lineTo(innerA, _height + innerOffset);
			_stroke.graphics.lineTo(innerA, innerA);
			_stroke.graphics.endFill();


			addChild(_stroke);
			if(_background) {
				_stroke.x = _background.x;
				_stroke.y = _background.y;
			}
		}

		public function setStroke($thickness : uint, $color : uint, $alpha : Number = 1, $isInner : Boolean = false, $width : Number = NaN, $height : Number = NaN) : void {
			_strokeThickness = $thickness;
			_hasStroke = _strokeThickness > 0;
			_strokeColor = $color;
			_strokeAlpha = $alpha;
			_strokeIsInner = $isInner;
			if(!isNaN($width))_width = $width;
			if(!isNaN($height))_height = $height;
			if(!isNaN(_width) || !isNaN(_height))return;
			_drawStroke();
		}

		public function set transitionIN(value : Function) : void {
			_transitionIN = value;
		}

		override public function toString() : String {
			return "[" + getQualifiedClassName(this) + "] ";
		}
	}
}