package sz.scratch.utils
{
	/**
	 * Random
	 *
	 * @author Joel Morrison
	 * @version 1.0
	 * @since Jun 18, 2010
	 *
	 */
	public class Random
	{
		public static function range(minNum : Number, maxNum : Number) : Number
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}

		public static function posNeg() : int
		{
			if(bool())
				return 1;
			else
				return -1;
		}

		public static function bool() : Boolean
		{
			return Boolean((Math.floor(Math.random() * 2)));
		}
	}
}