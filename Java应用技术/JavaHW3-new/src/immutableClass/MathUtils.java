package immutableClass;

public class MathUtils {
	public static UnmodifiableVector getUnmodifiableVector (Vector v)
	{
		double[] V = new double[v.length()];
		for(int i = 0; i < v.length(); ++i) {
			V[i] = v.get(i);
		}
		UnmodifiableVector unmodifiableVector = new UnmodifiableVector(V);//调用unmodifiableVector的构造函数实现转换
		return unmodifiableVector;
	}
	
	public static UnmodifiableMatrix getUnmodifiableMatrix (Matrix m)
	{
		double[][] M = new double[m.getRow()][m.getColumn()];
		for(int i = 0; i < m.getRow(); ++i) {
			for(int j = 0; j < m.getColumn(); ++j) {
				M[i][j] = m.get(i, j);
			}
		}
		UnmodifiableMatrix unmodifiableMatrix = new UnmodifiableMatrix(M);//调用unmodifiableMatrix的构造函数实现转换
		return unmodifiableMatrix;
	}
}
