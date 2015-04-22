package sz.scratch.ui {
	import com.core.events.LoadEvent;
	import com.core.utils.FBtrace;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	import sz.scratch.ui.Image;

	/**
	 *
	 * @version 1.0
	 * @since Apr 13, 2010
	 *
	 */
	public class ImageDisplay extends Sprite {

		private var _imageA : Image;
		private var _imageB : Image;
		private var _inImage : Image;
		private var _outImage : Image;
		private var _imageToggle : Boolean = true;

		private var _url : String;
		private var _smoothing : Boolean;
		private var _width : Number;
		private var _height : Number;
		private var _background : Shape;
		private var _backgroundColor : uint = 0xFFFFFF;
		private var _alphaURL : String;
		private var _hasStroke : Boolean = false;
		private var _strokeIsInner : Boolean = false;
		private var _strokeThickness : uint;
		private var _strokeColor : uint;
		private var _strokeAlpha : uint;
		private var _backgroundAlpha : Number;
		private var _loadingColor : uint = 0xFFFFFF;
		private var _transitionIN : Function;

		private var _transitionOUT : Function;
		private var _stroke : Shape;
		public static const LOADING_COMPLETE : String = Event.COMPLETE;

		//TODO: Add callbacks for transition complete, for in and out to enable more complex transitions
		public function ImageDisplay($width : Number, $height : Number, $smoothing : Boolean = false, $loadingBackgroundColor : uint = 0x000000, $loadingBackgroundAlpha : Number = .5) : void {
			_smoothing = $smoothing;
			_width = $width;
			_height = $height;
			_imageA = new Image(null, $smoothing, null, null, $width, $height);
			_imageB = new Image(null, $smoothing, null, null, $width, $height);
			_imageA.visible = _imageB.visible = false;
			_imageA.alpha = _imageB.alpha = 0;
			_imageA.setBackgroundColor($loadingBackgroundColor, $loadingBackgroundAlpha, $width, $height);
			_imageB.setBackgroundColor($loadingBackgroundColor, $loadingBackgroundAlpha, $width, $height);
			_backgroundColor = $loadingBackgroundColor;
			_backgroundAlpha = $loadingBackgroundAlpha;

			addChild(_imageA);
			addChild(_imageB);
		}

		/**
		 * Loads the image
		 */
		public function load($url : String, $alphaURL : String = null) : void {
			 this.visible=true;
			if(_url == $url)return;
			_url = $url;
			_alphaURL = $alphaURL;

			if(_imageToggle) {
				_inImage = _imageA;
				_outImage = _imageB;
			}
			else {
				_inImage = _imageB;
				_outImage = _imageA;
			}
			_imageToggle = !_imageToggle;

			_setDimensions();
			_inImage.addEventListener(Event.COMPLETE, _onLoadComplete);
			_inImage.addEventListener(LoadEvent.FAIL, _onLoadFail);
			_inImage.loadingColor = _loadingColor;

			_inImage.load(_url);
			_transitionInImage();
		}

		private function _transitionInImage() : void {
			_inImage.visible = true;
			addChild(_inImage);
			if(_stroke) addChild(_stroke);
			if(_transitionIN != null) {
				_transitionIN(_inImage);
			}
			else {
				_inImage.alpha = 1;
			}
		}

		private function _transitionOutImage() : void {
			if(_transitionOUT != null) {
				_transitionOUT(_outImage);
			}
			else {
				_outImage.alpha = 0;
				_outImage.visible = false;
			}
		}

		public function set loadingColor($color : uint) : void {
			_loadingColor = $color;
			_imageA.loadingColor = _imageB.loadingColor = $color;
		}

		private function _setDimensions() : void {
			if(!_width || !_height)return;
			setBackgroundColor(_backgroundColor);
		}


		/**
		 * Handler for the <code>Event.COMPLETE</code> event on the image loader.
		 * Positions the image and adds it to the display list.
		 */
		private function _onLoadComplete($e : Event = null) : void {
			_inImage.removeEventListener(Event.COMPLETE, _onLoadComplete);
			_inImage.removeEventListener(LoadEvent.FAIL, _onLoadFail);
			_transitionOutImage();
		}


		private function _onLoadFail($e : LoadEvent = null) : void {
			FBtrace(this + '_onLoadBitmapFail : Bitmap failed to progress, likely wrong path at ' + _url);
			_inImage.removeEventListener(Event.COMPLETE, _onLoadComplete);
			_inImage.removeEventListener(LoadEvent.FAIL, _onLoadFail);
		}

		public function destroy() : void {
			if(_imageA) _imageA.unload();
			if(_imageB) _imageB.unload();
			_background.graphics.clear();
			_stroke.graphics.clear();
			_imageA = null;
			_imageB = null;
			_background = null;
			_stroke = null;
		}

		public function get smoothing() : Boolean {
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void {
			_smoothing = value;
		}

		public function setBackgroundColor($color : uint, $alpha : Number = .15, $width : Number = NaN, $height : Number = NaN) : void {
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
			addChildAt(_background, 0);
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

		public function hide() : void {
			this.visible=false;
			this.alpha=0;
			unload();
		}

		public function showImages() : void {
			this.visible=true;
			this.alpha=1;
			if(_outImage) _outImage.showImage();
			if(_inImage)   _inImage.showImage();
		}

		public function unload():void
		{
			_url=null;
		   _imageA.unload();
		   _imageB.unload();
		}

		override public function toString() : String {
			return "[" + getQualifiedClassName(this) + "] ";
		}

		public function set transitionIN(value : Function) : void {
			_transitionIN = _imageA.transitionIN = _imageB.transitionIN = value;
		}

		public function set transitionOUT(value : Function) : void {
			_transitionOUT = value;
		}
	}
}