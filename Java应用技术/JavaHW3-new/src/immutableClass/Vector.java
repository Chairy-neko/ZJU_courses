package immutableClass;

public class Vector {
	private int length;
	private double[] V;

	public Vector(double[] v) {//构造函数
		// TODO Auto-generated constructor stub
		this.length = v.length;
		this.V = v.clone();
	}

	public static Vector Plus(Vector a, Vector b) {//向量加法
		if (a.length != b.length)
			return null;
		Vector c = new Vector(a.V);
		for (int i = 0; i < c.length; ++i) {
			c.V[i] = a.V[i] + b.V[i];
		}
		return c;
	}

	public static Vector Minus(Vector a, Vector b) {//向量减法
		if (a.length != b.length)
			return null;
		Vector c = new Vector(a.V);
		for (int i = 0; i < c.length; ++i) {
			c.V[i] = a.V[i] - b.V[i];
		}
		return c;
	}

	public static double Dot(Vector a, Vector b) {//向量点乘
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

	public Vector set(int k, double setTo) {//设置向量指定位置的值并返回修改后的向量
		V[k] = setTo;
		return this;
	}
	
	public double get(int k)
	{
		return V[k];
	}
	
	public int length() {//获得当前向量长度
		return this.length;
	}

	public String toString() {//向量转换为相应的String（方便测试观察）
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
