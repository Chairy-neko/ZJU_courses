package immutableClass;

public final class UnmodifiableVector {
	private final int length;
	private final double[] V;

	public UnmodifiableVector(double[] v) {//构造函数
		// TODO Auto-generated constructor stub
		this.length = v.clone().length;
		this.V = new double[length];
		for (int i = 0; i < length; ++i) {
			this.V[i] = v[i];
		}
	}

	public static UnmodifiableVector Plus(UnmodifiableVector a, UnmodifiableVector b) {//向量加法
		if (a.length != b.length)
			return null;
		double[] c = new double[a.length];
		for (int i = 0; i < c.length; ++i) {
			c[i] = a.V[i] + b.V[i];
		}
		UnmodifiableVector cVector = new UnmodifiableVector(c);
		return cVector;
	}

	public static UnmodifiableVector Minus(UnmodifiableVector a, UnmodifiableVector b) {//向量减法
		if (a.length != b.length)
			return null;
		double[] c = new double[a.length];
		for (int i = 0; i < a.length; ++i) {
			c[i] = a.V[i] - b.V[i];
		}
		UnmodifiableVector cVector = new UnmodifiableVector(c);
		return cVector;
	}

	public static double Dot(UnmodifiableVector a, UnmodifiableVector b) {//向量点乘
		if (a.length != b.length) {
			System.out.println("Cannot Dot Product!");
			return 0;
		}
		double c = 0;
		for (int i = 0; i < a.length; ++i) {
			c += a.V[i] * b.V[i];
		}
		return c;
	}

	public UnmodifiableVector set(int k, double setTo) {//修改向量中特定的值并返回新向量
		UnmodifiableVector tVector = new UnmodifiableVector(this.V.clone());
		tVector.V[k] = setTo;
		return tVector;
	}

	public double get(int k) {//获得向量中指定点的值
		return V.clone()[k];
	}

	public String toString() {//向量转换为String形式（方便测试观察）
		String string = "";
		string += "{";
		for (int i = 0; i < V.length; ++i) {
			string += V[i];
			if (i != V.length - 1)
				string += ", ";
		}
		string += "}";
		return string;
	}
}
