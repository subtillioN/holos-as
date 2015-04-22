package sz.scratch.animation {
	import com.core.effects.*;

	/**
	 * Joel Morrison : added percent arg --- essentially a multiplier on position --- to modify how much of an effect to tween to.
	 *
	 * Tweens the color transform properties of a MovieClip
	 * @author Todd Driscoll
	 * @version 1.0
	 * @since 10.29.2007
	 */

	public class ColorPercentTween extends Tween {

		public static const COLOR : String = "color";
		public static const RED_MULTIPLIER : String = "redMultiplier";
		public static const GREEN_MULTIPLIER : String = "greenMultiplier";
		public static const BLUE_MULTIPLIER : String = "blueMultiplier";
		public static const ALPHA_MULTIPLIER : String = "alphaMultiplier";
		public static const RED_OFFSET : String = "redOffset";
		public static const GREEN_OFFSET : String = "greenOffset";
		public static const BLUE_OFFSET : String = "blueOffset";
		public static const ALPHA_OFFSET : String = "alphaOffset";
		public static const BRIGHTNESS : String = "brightness";
		public static const TINT_COLOR : String = "tintColor";
		public static const TINT_MULTIPLIER : String = "tintMultiplier";
		public static const RED : String = "red";
		public static const GREEN : String = "green";
		public static const BLUE : String = "blue";
		public static const ALPHA : String = "alpha";
		public static const HEX : String = "hex";

		private var _method : Function;

		private var _beginColor : Color;
		private var _finishColor : Color;
		private var _percent : Number;

		public function ColorPercentTween($obj : Object, $prop : String, $func : Function = null, $begin : Number = NaN, $finish : Number = NaN, $duration : Number = 1, $useSeconds : Boolean = false, $delay : Number = 0, $units : Number = NaN, $startImmediately : Boolean = true, $percent : Number = 1) {
			_percent = $percent;
			////trace('[ColorTween] constructor ' + $obj + '[' + $prop + '] from: ' + $begin + ' to: ' + $finish + ' over ' + $duration);
			$units = $units;
			$startImmediately = $startImmediately;
			_beginColor = new Color();
			_beginColor.concat($obj['transform'].colorTransform);

			_finishColor = new Color();
			_finishColor.concat($obj['transform'].colorTransform);

			switch($prop) {
				case COLOR:
				case RED_MULTIPLIER:
				case GREEN_MULTIPLIER:
				case BLUE_MULTIPLIER:
				case ALPHA_MULTIPLIER:
				case RED_OFFSET:
				case GREEN_OFFSET:
				case BLUE_OFFSET:
				case ALPHA_OFFSET:
				case BRIGHTNESS:
				case TINT_COLOR:
				case TINT_MULTIPLIER:
					if(!$begin && $begin != 0) $begin = _beginColor[$prop];
					_beginColor[$prop] = $begin;
					if(!$finish && $finish != 0) $finish = _finishColor[$prop];
					_finishColor[$prop] = $finish;
					_method = _standardProperty;
					break;
				case RED:
				case GREEN:
				case BLUE:
				case ALPHA:
					if(!$begin && $begin != 0) $begin = _beginColor[$prop + 'Offset'];
					_beginColor[$prop + 'Multiplier'] = 0;
					_beginColor[$prop + 'Offset'] = $begin;
					if(!$finish && $finish != 0) $finish = _finishColor[$prop + 'Offset'];
					_finishColor[$prop + 'Multiplier'] = 0;
					_finishColor[$prop + 'Offset'] = $finish;
					_method = _colorChannel;
					break;
				case HEX:
					if($begin || $begin == 0) _beginColor.color = $begin;
					if($finish || $finish == 0) _finishColor.color = $finish;
					////trace('_beginColor.color: ' + _beginColor.color);
					////trace('_finishColor.color: ' + _finishColor.color);
					$begin = 0;
					$finish = 1;
					_method = _hexValue;
					break;
				default:
					_method = _throwPropError;
					break;
			}

			super($obj, $prop, $func, $begin, $finish, $duration, $useSeconds, $delay);

		}

		public function get beginColor() : Color {
			return _beginColor;
		}

		public function get finishColor() : Color {
			return _finishColor;
		}

		/*
		 public function set xxxx($xxxx:Number):void {
		 _xxxxx = $xxxx;
		 }

		 public function get xxxx():Number {
		 return _xxxxx;
		 }
		 */

		override protected function _apply() : void {
			_method();
		}

		protected function _standardProperty() : void {
			var c : Color = new Color();
			c.concat(obj['transform'].colorTransform);
			c[prop] = position * _percent;
			obj['transform'].colorTransform = c;
		}

		protected function _colorChannel() : void {
			var c : Color = new Color();
			c.concat(obj['transform'].colorTransform);
			c[prop + 'Multiplier'] = 0;
			c[prop + 'Offset'] = position * _percent;
			obj['transform'].colorTransform = c;
		}

		protected function _hexValue() : void {
			/*
			 var c:Color = new Color();
			 c.concat(obj.transform.colorTransform);
			 c.redMultiplier = 1-position // 0;
			 c.greenMultiplier = 1-position // 0;
			 c.blueMultiplier = 1-position // 0;
			 c.redOffset = _beginColor.redOffset + (position * (_finishColor.redOffset - _beginColor.redOffset));
			 c.greenOffset = _beginColor.greenOffset + (position * (_finishColor.greenOffset - _beginColor.greenOffset));
			 c.blueOffset = _beginColor.blueOffset + (position * (_finishColor.blueOffset - _beginColor.blueOffset));
			 obj.transform.colorTransform = c;
			 */
			obj['transform'].colorTransform = Color.interpolateTransform(_beginColor, _finishColor, position * _percent);
		}

		protected function _throwPropError() : void {
			throw new Error('invalid property "' + prop + '" passed to ColorTween constructor');
		}

	}

}