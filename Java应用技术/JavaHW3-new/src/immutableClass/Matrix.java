package immutableClass;

public class Matrix {
	private int row;
	private int column;
	private double[][] M;

	public Matrix(double[][] m) {//构造函数
		row = m.length;
		column = m[0].length;
		M = m.clone();
		for (int i = 0; i < row; ++i) {
			if (m[i].length != column) {
				System.out.println("The two-dimensional array is not a matrix! ");
				return;
			}
		}
	}

	public static Matrix Plus(Matrix a, Matrix b) {//矩阵加法
		if ((a.row != b.row) || (a.column != b.column))
			return null;
		double[][] c = new double[a.row][a.column];
		Matrix cMatrix = new Matrix(c);
		for (int i = 0; i < cMatrix.row; ++i) {
			for (int j = 0; j < cMatrix.column; ++j) {
				cMatrix.M[i][j] = a.M[i][j] + b.M[i][j];
			}
		}
		return cMatrix;
	}

	public static Matrix Minus(Matrix a, Matrix b) {//矩阵减法
		if ((a.row != b.row) || (a.column != b.column))
			return null;
		double[][] c = new double[a.row][a.column];
		Matrix cMatrix = new Matrix(c);
		for (int i = 0; i < cMatrix.row; ++i) {
			for (int j = 0; j < cMatrix.column; ++j) {
				cMatrix.M[i][j] = a.M[i][j] - b.M[i][j];
			}
		}
		return cMatrix;
	}

	public static Matrix Dot(Matrix a, Matrix b) {//矩阵乘法
		if ((a.column != b.row))
			return null;
		double[][] c = new double[a.row][b.column];
		Matrix cMatrix = new Matrix(c);
		for (int i = 0; i < a.row; ++i) {
			for (int j = 0; j < b.column; ++j) {
				cMatrix.M[i][j] = 0;
				for (int k = 0; k < b.row; ++k) {
					cMatrix.M[i][j] += a.M[i][k] * b.M[j][k];
				}
			}
		}
		return cMatrix;
	}

	public Matrix set(int i, int j, double setTo) {//修改矩阵指定位置的值并返回修改后的矩阵
		this.M[i][j] = setTo;
		return this;
	}

	public double get(int i, int j) {//获取矩阵指定位置的值
		return this.M[i][j];
	}
	
	public int getRow() {//获取矩阵的行数
		return this.row;
	}
	
	public int getColumn() {//获取矩阵的列数
		return this.column;
	}

	public String toString() {//矩阵转换为相应String并返回（方便测试观察）
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
