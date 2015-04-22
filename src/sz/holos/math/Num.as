package sz.holos.math {
	import sz.holos.ops.safeNum;

	/**
	 *  //// UNDER CONSTRUCTION ////
	 *  playing around with the best way to handle the common issues running into the inherent ambiguities of the number system, such as the pre-integrated (proto-rational) handling of the infinity in zero in the shift to the immanent/transcendent axis and breaking of closure in mult/div (see SpinbitZ, book). Seems I'm more and more favoring the functional approach, and all these utils are ending up in the ops.num package...do I need them here to wrap them up into a package???
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since 8/18/11
	 *
	 */
	public class Num {
		// might not be thread-safe, using static vars like this, but... for now
		private static var
				r : Number = NaN,
				d : Number = NaN,
				n : Number = NaN;
		public static const
				TINY : Number = 0.000001,
				PERCENT_ZERO : Number = 0.01,
				HUGE : Number = Number.MAX_VALUE,
				NEGATIVE_HUGE : Number = -HUGE,
				PHI : Number = 1.6180339887;

		public static function safeDivide($n : Number, $d : Number) : Number {
			n = safeNum($n);
			d = safeNum($d);
			r = n / d;
			_report('safeDivide n=' + n + " : d=" + d);
			return r;
		}

		public static function percentDivide($num : Number, $denom : Number) : Number {
			r = Math.abs($num / safeNum($denom));
			_report('safeDivide');
			return r;
		}

//		private static function safe($x : Number, $inclZero : Boolean = true) : Number {
//			return safe($x,$inclZero);
//		}

		private static function _report($m : String = "") : void {
			trace('Num :: ' + $m + '--> r = ' + r);
		}
	}
}