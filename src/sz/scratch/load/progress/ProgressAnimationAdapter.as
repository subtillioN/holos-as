package sz.scratch.load.progress {
	/**
	 * Handles loading logic for ILoaderAnimation assets, adapting from multiple progress streams.
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 3/3/11
	 *
	 */
	public class ProgressAnimationAdapter {
		private var _amtLoaded : Number = 0;
		private var _amtTotal : Number = 0;
		private var _animation : IProgressAnimation;
		private var _multiAmtLoaded : Array;
		private var _multiAmtTotal : Array;
		private var _percent : Number;
		private var _completeHandler : Function;
		private var _currentLoaderNum : int = 0;
		public static const AMT_DEFAULT : Number = 100;


		public function ProgressAnimationAdapter() {
			_multiAmtLoaded = [];
			_multiAmtTotal = [];
		}

		public function setAmtLoaded($value : Number, $index : int = 0) : void {
			_checkAmounts($index);
			_multiAmtLoaded[$index] = $value;
			_calcMultiPercent();
		}

		public function setMultiPercent($value : Number, $index : int = 0) : void {
			_checkAmounts($index);
			trace('_multiAmtTotal = ' + _multiAmtTotal);
			_multiAmtLoaded[$index] = _multiAmtTotal[$index] * $value;
		}

		public function setTotalPercent($p : Number) : void {
			for(var i : int = 0; i < _currentLoaderNum; i++) {
				setMultiPercent($p, i);
			}
		}

		private function _checkAmounts($index : int) : void {
			_currentLoaderNum = Math.max(_currentLoaderNum, $index);
			if(_multiAmtLoaded.length != _currentLoaderNum || _multiAmtTotal.length != _currentLoaderNum) {
				while(_multiAmtLoaded.length < _currentLoaderNum) {
					_multiAmtLoaded.push(0);
				}
				while(_multiAmtTotal.length < _currentLoaderNum) {
					_multiAmtTotal.push(AMT_DEFAULT);
				}
			}
		}

		private function _calcPercent() : void {
			_setPercent(_amtLoaded / _amtTotal);
		}

		public function set multiAmtTotal($value : Array) : void {
			_multiAmtTotal = $value;
			_multiAmtLoaded = [];
			_amtTotal = 0;
			for each (var v : Number in _multiAmtTotal) {
				_amtTotal += v;
				_multiAmtLoaded.push(0);
			}
			_currentLoaderNum = _multiAmtTotal.length;
		}

		private function _setPercent($value : Number) : void {
			_percent = $value;
			trace('_percent = ' + _percent);
			if(!_animation)return;
			_animation.percent = $value;
			if($value >= 1)_loadingComplete();
		}

		public function get amtTotal() : Number {
			return _amtTotal;
		}

		public function set amtTotal($value : Number) : void {
			_amtTotal = $value;
			_calcPercent();
		}

		public function set animation($do : IProgressAnimation) : void {
			_animation = $do;
		}

		private function _loadingComplete() : void {
			_animation.hide();
			if(_completeHandler != null)_completeHandler();
		}

		public function get animation() : IProgressAnimation {
			return _animation;
		}

		public function set indeterminate($value : Boolean) : void {
			if(_animation)_animation.indeterminate = $value;
		}

		public function get multiAmtLoaded() : Array {
			return _multiAmtLoaded;
		}

		private function _calcMultiPercent() : void {
			_amtLoaded = 0;
			for each (var v : Number in _multiAmtLoaded) {
				_amtLoaded += v;
			}
			_calcPercent();
		}

		public function get multiAmtTotal() : Array {
			return _multiAmtTotal;
		}

		public function get percent() : Number {return _percent;}

		public function get indeterminate() : Boolean {return _animation.indeterminate;}

		public function set completeHandler(value : Function) : void {
			_completeHandler = value;
		}

		public function get currentLoaderNum() : int {
			return _currentLoaderNum;
		}
	}
}