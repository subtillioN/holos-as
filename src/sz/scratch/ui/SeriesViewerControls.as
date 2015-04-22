package sz.scratch.ui
{
	import com.core.easing.Strong;
	import com.core.events.BooleanEvent;
	import com.core.events.NumberEvent;
	import sz.events.FrameEvent;
	import sz.scratch.utils.Transitions;
	import sz.holos.vo.SeriesViewerVO;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * SeriesViewerControls is used in SeriesViewer to display
	 * the navigation elements (e.g. arrows) and
	 * dispatches a FrameEvent on update to determine the frame
	 * in the SeriesViewer.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 12.1.2009
	 */

	public class SeriesViewerControls extends Sprite
	{
		private var _initFlag : Boolean = false;
		private var _xDistance : Number = 0;
		private var _xDistanceTemp : Number = 0;
		private var _XCenter : Number;

		private static const FADE_DURATION : Number = .5;
		private static var _arrowDistance : Number = 10;
		private static const ARROW_OVER : Number = 1.1; // arrow scale on mouse over
		public static const SCRUB_EVENT : String = "scrub_event";
		public static const DATA_SET : String = "data_set";

		public static var currentFrame : int = 0;
		public static var currentSpeed : Number = 0;
		public static var scrubbing : Boolean = false;
		private var _loop : Boolean = true;
		private var _scrubSpeed : Number = 1;
		public var fadeSpeed : Number = .25;
		public var imageExtension : String = '.jpg';

		public var arrowLeft : MovieClip;
		public var arrowRight : MovieClip;

		private var _YCenter : Number;
		private var _hit : Sprite;
		private var _numImages : int;
		private var _numImagesMult : Number;
		public static const IMAGES_SET : String = "images_set";
		private var _transform : Rectangle;
		private var _active : Boolean;
		private var _isInternal : Boolean;
		private var _controlsOffsetY : Number = 0;
		private var _controlsOffsetX : Number = 0;
		private var _arrowScaleOrig : Number;
		private var _incrementForward : Boolean = true;
		private var _over : Boolean = false;
		private var _data : SeriesViewerVO;
		public var forwardOver : Function;
		public var prevOver : Function;
		private var _mouseOverZone : String;

		public function SeriesViewerControls($transform : Rectangle = null, $arrowleft : MovieClip = null, $arrowright : MovieClip = null) : void
		{
			if($transform)_transform = $transform;
			alpha = 0;
			addEventListener(Event.ADDED_TO_STAGE, _onStage, false, 0, true);
			setArrows($arrowleft, $arrowright);
			if(arrowLeft) _arrowScaleOrig = arrowLeft.scaleX;
		}

		public function setArrows($left : MovieClip = null, $right : MovieClip = null) : void
		{
			if($left) arrowLeft = $left;
			if($right) arrowRight = $right;
			addChild(arrowLeft);
			addChild(arrowRight);

			if(arrowLeft) arrowLeft.x = -_arrowDistance;
			if(arrowRight) arrowRight.x = _arrowDistance;
		}

		internal function setOffsets($xOffset : Number, $yOffset : Number) : void
		{
			_controlsOffsetX = $xOffset;
			_controlsOffsetY = $yOffset;
			x += _controlsOffsetX;
			y += _controlsOffsetY;

		}

		private function _onStage(event : Event) : void
		{
			if(!_transform)
			{
				var _stage : Stage = this.stage;
				_transform = new Rectangle(0, 0, _stage.stageWidth, _stage.stageHeight);
				_XCenter = _transform.width / 2;
				_YCenter = _transform.height / 2;
				x = _XCenter;
				y = _YCenter;
			}
		}

		internal function setTransform($transform : Rectangle = null, $center : Point = null) : void
		{
			_transform = $transform;
			if(_transform)
			{
				if($center)
				{
					_XCenter = _transform.width / 2;
					_YCenter = _transform.height / 2;
					x = _XCenter + _transform.x + _controlsOffsetX;
					y = _YCenter + _transform.y + _controlsOffsetY;
				}
				else
				{
					x = $center.x;
					y = $center.y;
				}
			}
		}

		public function setData($data : SeriesViewerVO) : void
		{
			_data = $data;
			_scrubSpeed = Math.round(100 / $data.scrubSpeed);
			fadeSpeed = $data.fadeSpeed;
			imageExtension = $data.imageExtension;
			if($data.numImages) numImages = $data.numImages;
			dispatchEvent(new Event(DATA_SET));
		}


		private function _setUp() : void
		{
			_hit = new Sprite();
			_hit.mouseEnabled = true;
			_hit.buttonMode = true;
			_hit.graphics.beginFill(0x00FF00);
			_hit.graphics.drawRect(0, 0, _transform.width, _transform.height);
			_hit.x = -_XCenter;
			_hit.y = -_YCenter;
			addChild(_hit);
			_hit.alpha = 0;
			_initFlag = true;
		}

		public function activate() : void
		{
			_active = true;
			if(_hit)
			{
				// HIT LISTENERS
				_hit.buttonMode = true;
				_hit.mouseEnabled = true;
				_hit.mouseChildren = false;
				_hit.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true);
				_hit.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut, false, 0, true);
				_hit.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown, false, 0, true);
				_hit.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp, false, 0, true);
				_hit.addEventListener(MouseEvent.ROLL_OUT, _onMouseUp, false, 0, true);
			}
		}

		public function deactivate() : void
		{
			_active = false;
			if(_hit)
			{
				// HIT LISTENERS
				_hit.buttonMode = false;
				_hit.mouseEnabled = false;
				_hit.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
				_hit.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
				_hit.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
				_hit.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
				_hit.removeEventListener(MouseEvent.ROLL_OUT, _onMouseUp);
			}
		}

		// --- HANDLERS --- //

		// HIT DRAG LISTENERS

		private function _scrubOff() : void
		{
			if(Math.abs(_xDistance) < 0.0015)
			{
				if(mouseX > 0)
				{
					if(_incrementForward)nextFrame();
					else prevFrame();
				}
				else
				{
					if(_incrementForward)prevFrame();
					else nextFrame();
				}
			}
			_reset();
			_hit.stopDrag();
			scrub(false);
			_xDistance = 0;
			setFrame(getCurrentFrame());
			dispatchEvent(new FrameEvent(FrameEvent.FRAME_END, getCurrentFrame()));
		}

		private function _scrubOn() : void
		{
			_reset();
			_hit.startDrag();
			scrub();
			dispatchEvent(new FrameEvent(FrameEvent.FRAME_BEGIN, getCurrentFrame()));
		}

		private function _reset() : void
		{
			_hit.x = -_XCenter;
			_hit.y = -_YCenter;
		}


		private function _onMouseUp($e : MouseEvent) : void
		{
			if(scrubbing)_scrubOff();
		}

		private function _onMouseDown(event : MouseEvent) : void
		{
			_scrubOn();
		}

		private function _onMove($e : MouseEvent) : void
		{
			if(scrubbing)
			{
				_xDistanceTemp = _hit.x - -_XCenter;
				if(_xDistanceTemp >= _xDistance + _scrubSpeed)
				{
					// forward
					nextFrame();
					_xDistance = _xDistanceTemp;
				}
				else if(_xDistanceTemp <= _xDistance - _scrubSpeed)
				{
					// reverse
					prevFrame();
					_xDistance = _xDistanceTemp;
				}
			}
			if(mouseX > 0)_forwardOver();
			else _prevOver();
		}


		private function _onMouseOver($e : MouseEvent) : void
		{
			_over = true;
			addEventListener(MouseEvent.MOUSE_MOVE, _onMove, false, 0, true);
			fadeIn(.2);
		}

		private function _onMouseOut($e : MouseEvent) : void
		{
			_over = false;
			removeEventListener(MouseEvent.MOUSE_MOVE, _onMove);
			fadeOut(.3);
		}

		public function scrub($dragOn : Boolean = true) : void
		{
			scrubbing = $dragOn;
			dispatchEvent(new BooleanEvent(SCRUB_EVENT, $dragOn));
		}


		/**
		 * clamps the _frame to loop in the viable frame ranges for the number of images
		 */
		private function _frameCheck($n : Number) : Number
		{
			if(loop)
			{
				if($n > _numImages) $n = 0;
				if($n < 0) $n = _numImages;
			}
			else
			{
				if($n > _numImages) $n = _numImages;
				if($n < 0) $n = 0;
			}
			return $n;
		}


		public function nextFrame() : void
		{
			setFrame(_frameCheck(getCurrentFrame() + 1));
			dispatchFrameEvent(FrameEvent.FRAME_END);
		}

		public function prevFrame() : void
		{
			setFrame(_frameCheck(getCurrentFrame() - 1));
			dispatchFrameEvent(FrameEvent.FRAME_END);
		}

		public function setFrame($n : Number) : void
		{
			setCurrentFrame($n);
			dispatchFrameEvent(FrameEvent.FRAME_EVENT);
		}

		private function dispatchFrameEvent($eventType : String) : void
		{
			dispatchEvent(new FrameEvent($eventType, getCurrentFrame()));
		}

		public function getCurrentFrame() : int
		{
			return SeriesViewerControls.currentFrame;
		}

		private function setCurrentFrame($f : int) : void
		{
			SeriesViewerControls.currentFrame = $f;
		}

		private function _forwardOver() : void
		{
			if(_mouseOverZone != "forward")
			{
				_mouseOverZone = "forward";
				if(forwardOver != null) forwardOver();
				else
				{
					arrowRight.scaleX = arrowRight.scaleY = _arrowScaleOrig * ARROW_OVER;
					arrowLeft.scaleX = arrowLeft.scaleY = _arrowScaleOrig;
				}
			}
		}


		private function _prevOver() : void
		{
			if(_mouseOverZone != "prev")
			{
				_mouseOverZone = "prev";
				if(prevOver != null) prevOver();
				else
				{
					arrowLeft.scaleX = arrowLeft.scaleY = _arrowScaleOrig * ARROW_OVER;
					arrowRight.scaleX = arrowRight.scaleY = _arrowScaleOrig;
				}
			}
		}

		public function fadeIn($duration : Number = NaN) : void
		{
			if(isNaN($duration)) $duration = FADE_DURATION;
			Transitions.instance.fadein([this], $duration, Strong.easeIn);
		}

		public function fadeOut($duration : Number = NaN) : void
		{
			if(isNaN($duration)) $duration = FADE_DURATION;
			Transitions.instance.fadeout([this], $duration, Strong.easeOut);
		}

		public function destroy() : void
		{
			this.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this.removeEventListener(MouseEvent.CLICK, _onMouseDown);
		}

		public function set numImages($numImages : int) : void
		{
			_numImages = $numImages - 1;
			_numImagesMult = Math.round(_numImages * .1);
			dispatchEvent(new NumberEvent(IMAGES_SET, $numImages));
			if(!_initFlag)_setUp();
			//activate();
		}

		public function get isInternal() : Boolean
		{
			return _isInternal;
		}

		public function set isInternal(isInternal : Boolean) : void
		{
			_isInternal = isInternal;
			if(_isInternal)
			{
				arrowLeft.visible = false;
				arrowRight.visible = false;
			}
			else
			{
				arrowLeft.visible = true;
				arrowRight.visible = true;
			}
		}

		public function get loop() : Boolean
		{
			return _loop;
		}

		public function set loop(loop : Boolean) : void
		{
			_loop = loop;
		}

		public function set arrowDistance($arrowDistance : Number) : void
		{
			_arrowDistance = $arrowDistance;
			arrowLeft.x = -_arrowDistance;
			arrowRight.x = _arrowDistance;
		}

		public function set incrementForward($value : Boolean) : void
		{
			_incrementForward = $value;
		}

		public function get over() : Boolean
		{
			return _over;
		}

		public function get data() : SeriesViewerVO
		{
			return _data;
		}

		override public function toString() : String
		{
			return '[SeriesViewerControls]';
		}
	}
}
