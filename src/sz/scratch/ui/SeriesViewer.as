package sz.scratch.ui
{
	import sz.scratch.ui.simple.*;
	import sz.scratch.ui.*;
	import com.core.easing.Strong;
	import com.core.events.LoadEvent;
	import com.core.events.NumberEvent;
	import com.core.events.TweenEvent;
	import com.core.loading.LoadGroup;
	import com.core.loading.LoadItem;
	import com.core.loading.LoadManager;
	import com.core.utils.FBtrace;
	import com.core.utils.FlagSet;
	import com.mazda.mazda5.common.easing.Quart;
	import sz.events.FrameEvent;
	import sz.scratch.utils.Transitions;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * @author Joel Morrison
	 *
	 * Loads and holds the images in an array, allowing Navigation to scrub through them via setImage().
	 *
	 * SeriesViewer works with SeriesViewerControls to provide a viewer for scrubbing
	 * through a looped series of images, such as a vehicle 360 view.  It can load a series of
	 * images (such as transparent PNGs) along with an optional series of grayscale alpha channels,
	 * and it will apply the alpha channels (if JPGs are preferred) to the main series.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 12.1.2009
	 *
	 */
	public class SeriesViewer extends MovieClip
	{
		private var _imagesComplete : Array;
		private var _images : Array;
		private var _alphas : Array;
		private var _loadItemsImages : Array;
		private var _loadItemsAlphas : Array;
		private var _imagePath : String;
		private var _initialized : Boolean = false;
		private var _initLoadFrame : Number = 0;
		private var _loadManager : LoadManager;
		private var _loadImageGroup : LoadGroup;
		private var _loadAlphaGroup : LoadGroup;
		private var _displayBMP : Bitmap;
		private var _transitionBufferBMP : Bitmap;
		private var _imagesNumMult : Number;
		private var _imagesNum : Number;
		private var _percentHandler : Function;

		private static const COLOR_SPEED : Number = .5;

		private var _localFrame : Number;
		private var _nav : SeriesViewerControls;
		private static const COLOR_LOADED : String = "color_loaded";
		private var _initFlags : FlagSet;

		private var _firstFrameFlags : FlagSet;
		private var _fullFrameFlags : FlagSet;

		private var _transform : Rectangle;
		public var _offsetX : Number = 0;
		public var _offsetY : Number = 0;
		private var _centerPoint : Point;

		private static const FIRST_IMAGE_LOADED : String = 'first_image_loaded';
		private static const FIRST_ALPHA_LOADED : String = 'first_alpha_loaded';
		private static const FIRST_FRAMESET_LOADED : String = 'first_frameset_loaded';
		private static const ALPHA_SET_LOADED : String = 'alpha_set_loaded';
		private static const IMAGE_SET_LOADED : String = 'image_set_loaded';

		public static const FIRST_FRAME_COMPLETE : String = "first_frame_complete";
		public static const LAST_FRAME_COMPLETE : String = "last_frame_complete";
		private var _alphaPath : String;
		private var _tempImage : Bitmap;
		private var _loadPercentTimerDelay : Number;
		private var _loadPercentTimer : Timer;
		public static const PROGRESS : String = "progress";
		private var _colorInFunction : Function = Quart.easeIn;
		private var _colorOutFunction : Function = Quart.easeOut;
		private var _smoothing : Boolean = false;

		/**
		 * Constructor
		 * @param $nav          SeriesViewerControls - The controls used to navigate the image set
		 * @param $transform    Rectangle - optional forthe function of setting the active area of the controls and the
		 *                          size and position of the image set
		 */
		public function SeriesViewer($nav : SeriesViewerControls, $transform : Rectangle = null) : void
		{
			_nav = $nav;
			_displayBMP = new Bitmap();
			addChild(_displayBMP);
			_transitionBufferBMP = new Bitmap();
			addChild(_transitionBufferBMP);
			_transitionBufferBMP.alpha = 0;
			_displayBMP.alpha = 0;

			_initFlags = new FlagSet([SeriesViewerControls.DATA_SET,
			                          SeriesViewerControls.IMAGES_SET,
			                          COLOR_LOADED], _onInitReady);
			_nav.addEventListener(SeriesViewerControls.DATA_SET, _onDataSet);
			_nav.addEventListener(SeriesViewerControls.IMAGES_SET, _onImagesSet);
			addEventListener(Event.ADDED_TO_STAGE, _onStage);
			if($transform) setTransform($transform);

			_firstFrameFlags = new FlagSet([FIRST_ALPHA_LOADED,FIRST_IMAGE_LOADED], _onFirstFrameLoaded);
			_fullFrameFlags = new FlagSet([ALPHA_SET_LOADED,IMAGE_SET_LOADED,FIRST_FRAMESET_LOADED], _onFullFramesLoaded);
		}

		private function _onFullFramesLoaded() : void
		{
			if(_alphaPath)
			{
				var aBmd : BitmapData;
				for(var i : int = 0; i < _images.length; i++)
				{
					if(i != _initLoadFrame)
					{
						aBmd = Bitmap(_alphas[i]).bitmapData;
						if(aBmd)
						{
							var bcpy : BitmapData = Bitmap(_images[i]).bitmapData;
							var r : Rectangle = bcpy.rect;
							var bmd : BitmapData = new BitmapData(r.width, r.height, true, 0x000000);
							bmd.draw(bcpy, null, null, null, null, false);
							bcpy.dispose();
							bmd.copyChannel(aBmd, bmd.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
							var b : Bitmap = new Bitmap(bmd);
							b.smoothing = _smoothing;
							_imagesComplete[i] = b;
							b = null;
						} else _trace("ABMD EMPTY");
					}
				}
			}
			_clearTempImages();
			_clearLoadItems();
			_fullFrameFlags.setFlag(IMAGE_SET_LOADED, false);
			_fullFrameFlags.setFlag(ALPHA_SET_LOADED, false);

			_activateFrameListening();
			dispatchEvent(new Event(LAST_FRAME_COMPLETE));

			_nav.activate();
		}

		private function _onFirstFrameLoaded() : void
		{
			var aBmd : BitmapData;

			aBmd = Bitmap(_alphas[_initLoadFrame]).bitmapData;

			if(aBmd)
			{
				var bcpy : BitmapData = Bitmap(_images[_initLoadFrame]).bitmapData;
				var r : Rectangle = bcpy.rect;
				var bmd : BitmapData = new BitmapData(r.width, r.height, true, 0x000000);
				bmd.draw(bcpy, null, null, null, null, false);
				bcpy.dispose();
				bmd.copyChannel(aBmd, bmd.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
				var b : Bitmap = new Bitmap(bmd);
				b.smoothing = _smoothing;
				_imagesComplete[_initLoadFrame] = b;
				b = null;
				//				_imagesComplete[_initLoadFrame] = new Bitmap(bmd);
			} else _trace("ABMD EMPTY");
			setImage(_initLoadFrame);
			_firstFrameFlags.setFlag(FIRST_IMAGE_LOADED, false);
			_firstFrameFlags.setFlag(FIRST_ALPHA_LOADED, false);
			_fullFrameFlags.setFlag(FIRST_FRAMESET_LOADED, true);

			if(!_initialized)
			{
				Transitions.instance.move([_displayBMP, _transitionBufferBMP], (_transform.width - this.width) * .5 + offsetX, (_transform.height - this.height) * .5 + offsetY, .01);
				_initialized = true;
				Transitions.instance.fadein([_displayBMP], COLOR_SPEED, Strong.easeIn);
			}
			dispatchEvent(new Event(FIRST_FRAME_COMPLETE));
		}

		private function _activateFrameListening() : void
		{
			_nav.addEventListener(FrameEvent.FRAME_EVENT, _onFrameEvent);
		}

		private function _deactivateFrameListening() : void
		{
			_nav.removeEventListener(FrameEvent.FRAME_EVENT, _onFrameEvent);
		}

		public function setOffsets($x : Number, $y : Number) : void
		{
			_nav.setOffsets($x, $y);
		}


		private function _onStage(event : Event) : void
		{
			if(!_transform)
			{
				var _stage : Stage = this.stage;
				_transform = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
				_center();
			}
		}

		private function _center() : Point
		{
			_centerPoint = new Point(_transform.width / 2 + offsetX, _transform.height / 2 + offsetX);
			return _centerPoint;
		}

		public function setTransform($transform : Rectangle = null) : void
		{
			_transform = $transform;

			x = _transform.x;
			y = _transform.y;
			_nav.setTransform(_transform, _center());
		}

		private function _onImagesSet(event : NumberEvent) : void
		{
			_imagesNum = event.data;
			_imagesNumMult = 1 / Math.round(_imagesNum * .1);
			if(!_initialized) _initFlags.setFlag(SeriesViewerControls.IMAGES_SET, true);
		}

		private function _onDataSet(event : Event) : void
		{
			if(!_initialized) _initFlags.setFlag(SeriesViewerControls.DATA_SET, true);
		}

		private function _onInitReady() : void
		{
			_loadImages();
		}


		public function setSeries($imagePath : String, $alphaPath : String = null) : void
		{
			_imagePath = $imagePath;
			_alphaPath = $alphaPath;
			_initLoadFrame = _nav.getCurrentFrame();

			if(!_alphaPath)
			{
				_firstFrameFlags.setFlag(FIRST_ALPHA_LOADED, true);
				_fullFrameFlags.setFlag(ALPHA_SET_LOADED, true);
			}

			_initFlags.setFlag(COLOR_LOADED, true);
			if(_initialized) _loadImages();
			_deactivateFrameListening();
		}


		private function _onFrameEvent($e : FrameEvent = null) : void
		{
			if(_localFrame != $e.frame)setImage($e.frame);
		}

		public function clear() : void
		{
			_clearLoadItems();
			if(_displayBMP.bitmapData)_displayBMP.bitmapData = _displayBMP.bitmapData.clone();
			_clearAllImages();
		}

		private function _clearAllImages() : void
		{
			if(_imagesComplete && _imagesComplete.length)
			{
				for each(var img1 : * in _imagesComplete)
				{
					if(img1 is Bitmap)
					{
						_tempImage = img1 as Bitmap;
						_tempImage.bitmapData.dispose();
					}
					img1 = null;
				}
			}
			_imagesComplete = new Array();
			_tempImage = null;
			_clearTempImages();
		}

		private function _clearTempImages() : void
		{
			if(_images && _images.length)
			{
				for each(var img2 : * in _images)
				{
					if(img2 is Bitmap)
					{
						_tempImage = img2 as Bitmap;
						_tempImage.bitmapData.dispose();
					}
					img2 = null;
				}
			}
			_images = new Array();
			if(_alphas && _alphas.length)
			{
				for each(var alph : * in _alphas)
				{
					if(alph is Bitmap)
					{
						_tempImage = alph as Bitmap;
						_tempImage.bitmapData.dispose();
					}
					alph = null;
				}
			}
			_alphas = new Array();
			_tempImage = null;
		}

		private function _clearLoadItems() : void
		{
			if(_loadItemsImages && _loadItemsImages.length)
			{
				for each(var img : * in _loadItemsImages)
				{
					if(img is LoadItem)
					{
						LoadItem(img).cancel();
						LoadItem(img).removeEventListener(Event.COMPLETE, _onFirstImageComplete);
						LoadItem(img).removeEventListener(LoadEvent.FAIL, _onLoadFail);
					}
				}
			}
			_loadItemsImages = new Array();
			// clear alphas
			if(_loadItemsAlphas && _loadItemsAlphas.length)
			{
				for each(var alph : * in _loadItemsAlphas)
				{
					if(alph is LoadItem)
					{
						LoadItem(alph).cancel();
						LoadItem(alph).removeEventListener(Event.COMPLETE, _onFirstAlphaComplete);
						LoadItem(alph).removeEventListener(LoadEvent.FAIL, _onLoadAlphaFail);
					}
				}
			}
			_loadItemsAlphas = new Array();
		}

		private function _loadImages() : void
		{
			clear();
			_loadManager = LoadManager.instance;

			// LOAD IMAGES
			_loadImageGroup = LoadManager.createGroup();
			for(var i : int = 1; i <= _imagesNum; i++)
			{
				var imageNumber : String = (String(i).length > 1) ? String(i) : '0' + String(i);
				var imagePath : String = _imagePath + '/' + imageNumber + _nav.imageExtension;
				_loadItemsImages[i - 1] = _loadImageGroup.add(imagePath);
			}
			_loadItemsImages[_initLoadFrame].addEventListener(Event.COMPLETE, _onFirstImageComplete);
			_loadItemsImages[_initLoadFrame].addEventListener(LoadEvent.FAIL, _onLoadFail);
			_loadManager.addGroup(_loadImageGroup);
			_loadImageGroup.addEventListener(Event.COMPLETE, _onImagesComplete);

			// if alpha, load alphas
			if(_alphaPath)
			{
				// LOAD ALPHAS
				_loadAlphaGroup = LoadManager.createGroup();
				for(var j : int = 1; j <= _imagesNum; j++)
				{
					var alphaNumber : String = (String(j).length > 1) ? String(j) : '0' + String(j);
					var alphaPath : String = _alphaPath + '/' + alphaNumber + _nav.imageExtension;
					_loadItemsAlphas[j - 1] = _loadAlphaGroup.add(alphaPath);
				}
				_loadItemsAlphas[_initLoadFrame].addEventListener(Event.COMPLETE, _onFirstAlphaComplete);
				_loadItemsAlphas[_initLoadFrame].addEventListener(LoadEvent.FAIL, _onLoadAlphaFail);
				_loadManager.addGroup(_loadAlphaGroup);
				_loadAlphaGroup.addEventListener(Event.COMPLETE, _onAlphasComplete);
			}

			if(_loadPercentTimerDelay)
			{
				_loadPercentTimer = new Timer(_loadPercentTimerDelay);
				_loadPercentTimer.addEventListener(TimerEvent.TIMER, _onPercentTimer);
				_loadPercentTimer.start();
			}
		}

		private function _onFirstImageComplete($e : Event = null) : void
		{
			_images[_initLoadFrame] = LoadItem(_loadItemsImages[_initLoadFrame]).content;
			_firstFrameFlags.setFlag(FIRST_IMAGE_LOADED, true);
		}

		private function _onLoadFail($e : LoadEvent = null) : void
		{
			FBtrace(this + '_onLoadFail : Image failed to load, likely wrong path in xml at ' + _imagePath);
		}

		private function _onImagesComplete($e : Event = null) : void
		{
			for(var i : int = 0; i < _imagesNum; i++)
			{
				_images[i] = LoadItem(_loadItemsImages[i]).content;
			}
			_fullFrameFlags.setFlag(IMAGE_SET_LOADED, true);
			_displayBMP.smoothing = _transitionBufferBMP.smoothing = _smoothing;
		}


		private function _onFirstAlphaComplete($e : Event = null) : void
		{
			_alphas[_initLoadFrame] = LoadItem(_loadItemsAlphas[_initLoadFrame]).content;
			_firstFrameFlags.setFlag(FIRST_ALPHA_LOADED, true);
		}

		private function _onLoadAlphaFail($e : LoadEvent = null) : void
		{
			_trace(this + '_onLoadAlphaFail : Image failed to load, likely wrong path in xml at ' + _imagePath);
		}

		private function _onAlphasComplete($e : Event = null) : void
		{
			for(var i : int = 0; i < _imagesNum; i++)
			{
				_alphas[i] = LoadItem(_loadItemsAlphas[i]).content;
			}
			_fullFrameFlags.setFlag(ALPHA_SET_LOADED, true);
		}

		/*
		 * sets the new image on response to the changing frame.
		 * Transitions between them using a buffer image to hold the current image
		 * while the new image is loaded into the display below it, and then the
		 * buffer is faded out.
		 */
		public function setImage($n : Number) : void
		{
			_localFrame = $n;
			// put the current image in the buffer
			_transitionBufferBMP.bitmapData = _displayBMP.bitmapData;
			// load the new image in the display
			_displayBMP.bitmapData = Bitmap(_imagesComplete[$n]).bitmapData;
			_displayBMP.smoothing = _smoothing;
			//if the fade speed is greater than zero, use the transitionBuffer to fade out the old image
			var speed : Number = (SeriesViewerControls.scrubbing) ? _nav.fadeSpeed : COLOR_SPEED;
			if(speed > 0)
			{
				// make it visible above the display image
				_transitionBufferBMP.visible = true;
				_transitionBufferBMP.alpha = 1;
				_displayBMP.alpha = 0;

				Transitions.instance.fadeout([_transitionBufferBMP], speed, _colorInFunction, _onTweenFinish);
				Transitions.instance.fadein([_displayBMP], speed, _colorOutFunction);
			}
			else
			{
				_transitionBufferBMP.visible = false;
			}
		}

		private function _onTweenFinish($e : TweenEvent = null) : void
		{
			_transitionBufferBMP.visible = false;
		}

		private function _onPercentTimer(e : TimerEvent) : void
		{
			if(_percentHandler != null)
			{
				try
				{
					_percentHandler(_loadManager.percent);

				} catch(error : IOErrorEvent)
				{
					_trace("IOErrorEvent catch: " + error);

				} catch(error : TypeError)
				{
					_trace("TypeError catch: " + error);

				} catch(error : Error)
				{
					_trace("Error catch: " + error);
				}
			}
			else dispatchEvent(new NumberEvent(PROGRESS, _loadManager.percent));
			if(_loadManager.percent == 1)
			{
				_loadPercentTimer.stop();
			}
		}

		public function setLoadPercentTimer($loadPercentTimerDelay : Number = 1000) : void
		{
			_loadPercentTimerDelay = $loadPercentTimerDelay;
		}


		public function get offsetX() : Number
		{
			return _offsetX;
		}

		public function set offsetX(offsetX : Number) : void
		{
			_offsetX = offsetX;
		}

		public function get offsetY() : Number
		{
			return _offsetY;
		}

		public function set offsetY(offsetY : Number) : void
		{
			_offsetY = offsetY;
		}


		public function get loadingGroup() : LoadGroup
		{
			return _loadManager.loadGroup;
		}

		public function get loadingPercent() : Number
		{
			return _loadManager.percent;
		}

		public function set percentHandler(value : Function) : void
		{
			_percentHandler = value;
		}

		public function set colorInFunction(value : Function) : void
		{
			_colorInFunction = value;
		}

		public function set colorOutFunction(value : Function) : void
		{
			_colorOutFunction = value;
		}

		public function get smoothing() : Boolean
		{
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void
		{
			_smoothing = value;
			_displayBMP.smoothing = _smoothing;
		}

		private function _trace(...rest):void
		{
			//trace(rest);
		}

		override public function toString() : String
		{
			return '[SeriesViewer]';
		}
	}
}
