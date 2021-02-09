package immutableClass;

public final class UnmodifiableMatrix {
	private final int row;
	private final int column;
	private final double[][] M;

	public UnmodifiableMatrix(double[][] m) {//构造函数
		row = m.clone().length;
		column = m.clone()[0].length;
		this.M = new double[row][column];
		for (int i = 0; i < row; ++i) {
			if (m[i].length != column) {
				System.out.println("The two-dimensional array is not a UnmodifiableMatrix! ");
				return;
			}
		}
		for(int i = 0; i < row; ++i) {
			for (int j = 0; j < column; ++j) {
				this.M[i][j] = m[i][j];
			}
		}
	}

	public static UnmodifiableMatrix Plus(UnmodifiableMatrix a, UnmodifiableMatrix b) {//矩阵加法
		if ((a.row != b.row) || (a.column != b.column))
			return null;
		double[][] c = new double[a.row][a.column];
		UnmodifiableMatrix cUnmodifiableMatrix = new UnmodifiableMatrix(c);
		for (int i = 0; i < cUnmodifiableMatrix.row; ++i) {
			for (int j = 0; j < cUnmodifiableMatrix.column; ++j) {
				cUnmodifiableMatrix.M[i][j] = a.M[i][j] + b.M[i][j];
			}
		}
		return cUnmodifiableMatrix;
	}

	public static UnmodifiableMatrix Minus(UnmodifiableMatrix a, UnmodifiableMatrix b) {//矩阵减法
		if ((a.row != b.row) || (a.column != b.column))
			return null;
		double[][] c = new double[a.row][a.column];
		UnmodifiableMatrix cUnmodifiableMatrix = new UnmodifiableMatrix(c);
		for (int i = 0; i < cUnmodifiableMatrix.row; ++i) {
			for (int j = 0; j < cUnmodifiableMatrix.column; ++j) {
				cUnmodifiableMatrix.M[i][j] = a.M[i][j] - b.M[i][j];
			}
		}
		return cUnmodifiableMatrix;
	}

	public static UnmodifiableMatrix Dot(UnmodifiableMatrix a, UnmodifiableMatrix b) {//矩阵乘法
		if ((a.column != b.row))
			return null;
		double[][] c = new double[a.row][b.column];
		UnmodifiableMatrix cUnmodifiableMatrix = new UnmodifiableMatrix(c);
		for (int i = 0; i < a.row; ++i) {
			for (int j = 0; j < b.column; ++j) {
				cUnmodifiableMatrix.M[i][j] = 0;
				for (int k = 0; k < b.row; ++k) {
					cUnmodifiableMatrix.M[i][j] += a.M[i][k] * b.M[j][k];
				}
			}
		}
		return cUnmodifiableMatrix;
	}

	public UnmodifiableMatrix set(int i, int j, double setTo) {//修改矩阵指定位置的值并返回修改后的矩阵
		UnmodifiableMatrix matrix = new UnmodifiableMatrix(this.M.clone());
		matrix.M[i][j] = setTo;
		return matrix;
	}

	public double get(int i, int j) {//获得矩阵指定位置的值并返回
		return this.M.clone()[i][j];
	}

	public String toString() {//矩阵转换成相对应的String并返回（方便测试观察）
		String string = "";
		string += "{";
		for (int i = 0; i < this.row; ++i) {
			string += "{";
			for (int j = 0; j < this.column; ++j) {
				string += this.M[i][j];
				if (j != this.column - 1)
					string += ", ";
			}
			string += "}";
			if (i != this.row - 1)
				string += ",\n ";
		}
		string += "}";
		return string;
	}
}
