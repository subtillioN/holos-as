package sz.scratch.ui
{
	import sz.scratch.ui.*;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;

	import sz.scratch.ui.Text;

	/**
	 * GradientTitle DESCRIPTION
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since May 26, 2010
	 *
	 */
	public class GradientTitle extends Sprite
	{
		private var _title : Text;
		private var _gradient : Sprite;
		private var _hPad : Number = 2;
		private var _vPad : Number = 0;

		public function GradientTitle($colors : Array = null,
		                              $rotation : Number = NaN,
		                              $alphas : Array = null,
		                              $ratios : Array = null,
		                              $matrix : Matrix = null,
		                              $type : String = GradientType.LINEAR,
		                              $string : String = null,
		                              $populateID : String = null,
		                              $multiline : Boolean = false,
		                              $align : String = "left",
		                              $hPad : Number = NaN,
		                              $vPad : Number = NaN,
		                              $replace: String = null,
		                              $width: String = null
		                              
				)
		{
			_gradient = new Sprite();
			addChild(_gradient);
			_title = new Text();
			_title.addEventListener(Text.UPDATE_FORMAT, _onFormatUpdate);
			setText($string, $populateID, $multiline, $align, $hPad, $vPad,$replace,$width);
			setGradient($colors, $rotation, $alphas, $ratios, $matrix, $type);
			addChild(_title);
			super();
		}

		private function _onFormatUpdate(...rest) : void
		{
			update();
		}

		public function setGradient($colors : Array = null,
		                            $rotation : Number = NaN,
		                            $alphas : Array = null,
		                            $ratios : Array = null,
		                            $matrix : Matrix = null,
		                            $type : String = GradientType.LINEAR
				) : void
		{
			if(!$colors)$colors = [0x000000, 0xFFFFFF];
			if(isNaN($rotation)) $rotation = 90;
			if(!$alphas)
			{
				$alphas = [];
				var n:uint=$colors.length;
				while(n--)$alphas.push(1);
			}
			if($ratios)// convert 0-1 values to 0-255
			{
				var i : int = 0;
				for each (var r : Number in $ratios)
				{
					$ratios[i] = r * 255;
					i++;
				}
			} else
			{
				$ratios = [];
				var increment : Number = 255 / $colors.length;
				var j : int = 0;
				var nc : uint=$colors.length;
				while(nc--)
				{
					if(j == 0)$ratios.push(51);
					else if(j == $colors.length - 1)$ratios.push(209);
					else $ratios.push(increment * j);
					j++;
				}
			}
			if(!$matrix)
			{
				$matrix = new Matrix();
				$matrix.createGradientBox(10, 10, ($rotation * Math.PI / 180), 0, 0);
			}
			_gradient.graphics.clear();
			_gradient.graphics.beginGradientFill($type, $colors, $alphas, $ratios, $matrix);
			_gradient.graphics.drawRect(0, 0, 10, 10);

			update();
		}

		public function setText(
				$string : String = null,
				$populateID : String = null,
				$multiline : Boolean = false,
				$align : String = "left",
				$hPad : Number = NaN,
				$vPad : Number = NaN,
		        $replace : String = null,
		        $with : String = null
				) : void
		{
			if(!isNaN($hPad)) _hPad = $hPad;
			if(!isNaN($vPad)) _vPad = $vPad;
			_title.setText($string, $populateID, $multiline, $align, false, $replace, $with);
			update();
		}

		public function get textField() : TextField
		{
			return _title.field;
		}

		public function update() : void
		{
			if(_title && _gradient)
			{
				_gradient.x = _title.getBounds(this).left - _hPad;
				_gradient.y = _title.getBounds(this).top - _vPad;
				_gradient.width = _title.field.textWidth + (_hPad * 2);
				_gradient.height = _title.field.textHeight + (_vPad * 2);
				_gradient.mask = _title;
			}

		}
	}
}