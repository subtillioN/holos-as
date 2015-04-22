package sz.scratch.ui {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	import sz.scratch.drawing.CircleOutlined;
	import sz.scratch.drawing.Wedge;
	import sz.scratch.load.progress.IProgressAnimation;

	/**
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class CircleProgressAnimation extends Sprite implements IProgressAnimation {
		public var progressAnimation : Sprite;
		public var animMask : Sprite;
		public var bkg : Sprite;
		private var _radius : Number;
		private var _thickness : Number;
		private var _bkgColor : uint;
		private var _percentColor : uint;
		private var _percent : Number;
		private var _arc : Number;
		private var _percentAlpha : Number;
		private var _bkgAlpha : Number;
		private var _indeterminateSpeed : Number = 20;
		private var _indeterminateArc : Number = 90;
		private var _indeterminate : Boolean;
		private var _hideTransition : Function;
		private var _stage : Stage;
		private var _bkgThicknesOffset : Number = 0;

		public function CircleProgressAnimation($radius : Number = 40, $thickness : Number = 10, $percentColor : uint = 0xFFFFFF, $percentAlpha : Number = 1, $bkgColor : uint = 0xFFFFFF, $bkgAlpha : Number = 0.5) {
			_radius = $radius;
			_thickness = $thickness;
			_percentColor = $percentColor;
			_percentAlpha = $percentAlpha;
			_bkgColor = $bkgColor;
			_bkgAlpha = $bkgAlpha;
			mouseChildren = false;
			progressAnimation = new Sprite();
			animMask = new Sprite();
			bkg = new Sprite();
			_drawInit();
		}

		private function _drawInit() : void {
			_drawCircle(animMask);
			_drawCircle(bkg, _bkgThicknesOffset);
			progressAnimation.rotation = -90;
			addChild(bkg);
			addChild(progressAnimation);
			addChild(animMask);
			progressAnimation.mask = animMask;
			_draw();
		}

		private function _draw($degrees : Number = 360) : void {
			if(!_indeterminate) _arc = _percent * $degrees;
			else _arc = $degrees;
			progressAnimation.graphics.clear();
			progressAnimation.graphics.beginFill(_percentColor, _percentAlpha);
			Wedge.draw(progressAnimation, 0, 0, _radius + _thickness, _arc, 0);
			progressAnimation.graphics.endFill();
		}

		private function _drawCircle($target : Sprite, $offset : Number = 0) : void {
//			var circle : Sprite = new Sprite();
			$target.graphics.clear();
			$target.graphics.beginFill(_bkgColor, _bkgAlpha);
			CircleOutlined.draw($target, 0, 0, _radius - (_thickness * 0.5) - $offset, _radius + (_thickness * 0.5) + $offset);
			$target.graphics.endFill();
		}

		public function get percent() : Number {
			return _percent;
		}

		public function set percent($p : Number) : void {
			indeterminate = false;
			if(_percent == $p)return;
			_percent = $p;
			_draw();
		}


		public function get indeterminate() : Boolean {
			return _indeterminate;
		}

		public function set indeterminate($value : Boolean) : void {
			if($value == _indeterminate)return;
			_indeterminate = $value;
			if(_indeterminate) {
				_draw(_indeterminateArc);
				if(stage) {
					_onStage();
				}
				else this.addEventListener(Event.ADDED_TO_STAGE, _onStage)
			}
			else {
				if(_stage)_removeListeners();
				progressAnimation.rotation = -90;
			}
		}

		private function _onStage(event : Event = null) : void {
			if(!indeterminate)return;
			_stage = stage;
			_stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			_stage.addEventListener(Event.REMOVED_FROM_STAGE, _removeListeners);
		}

		private function _removeListeners(event : Event = null) : void {
			_stage.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			_stage.removeEventListener(Event.REMOVED_FROM_STAGE, _removeListeners);
		}

		private function _onEnterFrame(event : Event) : void {
			progressAnimation.rotation += _indeterminateSpeed;
		}

		public function hide() : void {
			if(_hideTransition != null)_hideTransition();
			else visible = false;
			indeterminate = false;
		}

		public function set hideTransition(value : Function) : void {
			_hideTransition = value;
		}

		public function set radius(value : Number) : void {
			_radius = value;
			_drawInit();
		}

		public function set thickness(value : Number) : void {
			_thickness = value;
			_drawInit();
		}

		public function set bkgThicknessOffset(value : Number) : void {
			_bkgThicknesOffset = value;
			_drawInit();
		}

		override public function toString() : String {
			return "[sz.scratch.ui.CircleLoader] ";
		}
	}

}