# Java Homework 2 火柴棒游戏

**姓名：臧可           学号：3180102095             专业：计算机科学与技术**

## 一、实验要求

1. 用户从命令行输入最大数字的位数（如1位数、2位数、3位数）；

2. 用户从命令行输入提示数（2或3），表示等号左式数字的个数；

3. 用户从命令行输入题目类型编号（移动、移除、添加），以及火柴棒根数；

   系统随机自动生成火柴棒游戏，并展示（直接用数字展示）；

4. 用户输入答案，系统验证是否正确；若正确，则提示正确；若错误，则让用户继续输入；

5. 若用户直接回车，则显示正确答案。

## 二、实验思路

### 1 根据用户要求随机生成正确的等式

根据输入的最大数字位数，用random函数随机生成等式中数字中的最大数。分情况讨论。

**当等式左边的数字有两个的时候**

- 加法和减法都可以转换成最大数max等于两个较小数min1，min2之和；

**当等式左边的数字有三个的时候**，分两种情况讨论。

- ++，--：可以转换成最大数等于三个较小数之和，分裂min2为min2和min3

- 通过移项把等式转换为A+B=C+D,保持原有的两个较小数不变，原来的最大数分裂成两个数相加即可。

  即：max1+max2=min1+min2（max1+max2=原max）

用random函数随机确定加法和减法

```java
public static void question(int digit, int digitNum, int type, int matchNum) {
		int max, min1, min2;// 等式中三个数字
		max = (int) (Math.random() * Math.pow(10, digit));
		min1 = (int) (Math.random() * max);
		min2 = max - min1;
		// 获得原始的正确等式
		if (digitNum == 2) {
			if (Math.random() > 0.5)
				correctAnswer = min1 + "+" + min2 + "=" + max;// min1+min2=max
			else
				correctAnswer = max + "-" + min1 + "=" + min2;// max-min1=min2
		} else if (digitNum == 3) {
			if (Math.random() > 0.5) {
				int min3 = (int) (Math.random() * min2);
				min2 = min2 - min3;
				if (Math.random() > 0.5)
					correctAnswer = min1 + "+" + min2 + "+" + min3 + "=" + max;// min1+min2+min3=max
				else
					correctAnswer = max + "-" + min2 + "-" + min3 + "=" + min1;// max-min2-min3=min1
			} else {
				int max1 = (int) (Math.random() * max);
				int max2 = max - max1;
				if (Math.random() > 0.5)
					correctAnswer = max1 + "+" + max2 + "-" + min1 + "=" + min2;// max1+max2-min1=min2
				else
					correctAnswer = max1 + "-" + min1 + "+" + max2 + "=" + min2;// max1-min1+max2=min2
			}
		}
		equation = correctAnswer;
	}
```

### 2 根据题目类型编号和火柴棒根数修改成题目

#### 2.1 不同数字和符号用火柴棒组成时的修改方案

用二维数组ArrayList存储每一个数字或火柴棒加、减相应火柴棍数目后可以得到的结果。如果没有结果存储‘*’。已知表示数字至少需要2根火柴棍（1），最多需要7根火柴棍（8），可以加减的最大火柴棍数目应在{1,2,3,4,5}之间。+号减1得到-号，-号加1得到+号，10个数字和两个符号一共12个数组，每个数组存5个加/减火柴棍数目。用addMatchstick和subMatchstick这两个大数组分别存储所有数字和符号的加火柴棍结果和减火柴棍结果。

![image-20201023105439465](Java Homework 2 火柴棒游戏.assets/image-20201023105439465.png)

**数据结构**

```java
public static ArrayList<ArrayList<String>> addMatchstick = new ArrayList<ArrayList<String>>();
public static ArrayList<ArrayList<String>> subMatchstick = new ArrayList<ArrayList<String>>();
public static ArrayList<String> addMatchstickZero = new ArrayList<String>();
public static ArrayList<String> addMatchstickOne = new ArrayList<String>();
public static ArrayList<String> addMatchstickTwo = new ArrayList<String>();
public static ArrayList<String> addMatchstickThree = new ArrayList<String>();
public static ArrayList<String> addMatchstickFour = new ArrayList<String>();
public static ArrayList<String> addMatchstickFive = new ArrayList<String>();
public static ArrayList<String> addMatchstickSix = new ArrayList<String>();
public static ArrayList<String> addMatchstickSeven = new ArrayList<String>();
public static ArrayList<String> addMatchstickEight = new ArrayList<String>();
public static ArrayList<String> addMatchstickNine = new ArrayList<String>();
public static ArrayList<String> addMatchstickAdd = new ArrayList<String>();
public static ArrayList<String> addMatchstickSub = new ArrayList<String>();



public static ArrayList<String> subMatchstickZero = new ArrayList<String>();
public static ArrayList<String> subMatchstickOne = new ArrayList<String>();
public static ArrayList<String> subMatchstickTwo = new ArrayList<String>();
public static ArrayList<String> subMatchstickThree = new ArrayList<String>();
public static ArrayList<String> subMatchstickFour = new ArrayList<String>();
public static ArrayList<String> subMatchstickFive = new ArrayList<String>();
public static ArrayList<String> subMatchstickSix = new ArrayList<String>();
public static ArrayList<String> subMatchstickSeven = new ArrayList<String>();
public static ArrayList<String> subMatchstickEight = new ArrayList<String>();
public static ArrayList<String> subMatchstickNine = new ArrayList<String>();
public static ArrayList<String> subMatchstickAdd = new ArrayList<String>();
public static ArrayList<String> subMatchstickSub = new ArrayList<String>();
```

**初始化**

```java
public static void initialize() {
		addMatchstickZero.add("8");
		addMatchstickZero.add("*");
		addMatchstickZero.add("*");
		addMatchstickZero.add("*");
		addMatchstickZero.add("*");
		addMatchstick.add(addMatchstickZero);
		addMatchstickOne.add("7");
		addMatchstickOne.add("4");
		addMatchstickOne.add("3");
		addMatchstickOne.add("09");
		addMatchstickOne.add("8");
		addMatchstick.add(addMatchstickOne);
		addMatchstickTwo.add("*");
		addMatchstickTwo.add("8");
		addMatchstickTwo.add("*");
		addMatchstickTwo.add("*");
		addMatchstickTwo.add("*");
		addMatchstick.add(addMatchstickTwo);
		addMatchstickThree.add("9");
		addMatchstickThree.add("8");
		addMatchstickThree.add("*");
		addMatchstickThree.add("*");
		addMatchstickThree.add("*");
		addMatchstick.add(addMatchstickThree);
		addMatchstickFour.add("*");
		addMatchstickFour.add("9");
		addMatchstickFour.add("8");
		addMatchstickFour.add("*");
		addMatchstickFour.add("*");
		addMatchstick.add(addMatchstickFour);
		addMatchstickFive.add("69");
		addMatchstickFive.add("8");
		addMatchstickFive.add("*");
		addMatchstickFive.add("*");
		addMatchstickFive.add("*");
		addMatchstick.add(addMatchstickFive);
		addMatchstickSix.add("8");
		addMatchstickSix.add("*");
		addMatchstickSix.add("*");
		addMatchstickSix.add("*");
		addMatchstickSix.add("*");
		addMatchstick.add(addMatchstickSix);
		addMatchstickSeven.add("*");
		addMatchstickSeven.add("3");
		addMatchstickSeven.add("09");
		addMatchstickSeven.add("8");
		addMatchstickSeven.add("*");
		addMatchstick.add(addMatchstickSeven);
		addMatchstickEight.add("*");
		addMatchstickEight.add("*");
		addMatchstickEight.add("*");
		addMatchstickEight.add("*");
		addMatchstickEight.add("*");
		addMatchstick.add(addMatchstickEight);
		addMatchstickNine.add("8");
		addMatchstickNine.add("*");
		addMatchstickNine.add("*");
		addMatchstickNine.add("*");
		addMatchstickNine.add("*");
		addMatchstick.add(addMatchstickNine);
		addMatchstickAdd.add("*");
		addMatchstickAdd.add("*");
		addMatchstickAdd.add("*");
		addMatchstickAdd.add("*");
		addMatchstickAdd.add("*");
		addMatchstick.add(addMatchstickAdd);
		addMatchstickSub.add("+");
		addMatchstickSub.add("*");
		addMatchstickSub.add("*");
		addMatchstickSub.add("*");
		addMatchstickSub.add("*");
		addMatchstick.add(addMatchstickSub);

		subMatchstickZero.add("*");
		subMatchstickZero.add("*");
		subMatchstickZero.add("7");
		subMatchstickZero.add("1");
		subMatchstickZero.add("*");
		subMatchstick.add(subMatchstickZero);
		subMatchstickOne.add("*");
		subMatchstickOne.add("*");
		subMatchstickOne.add("*");
		subMatchstickOne.add("*");
		subMatchstickOne.add("*");
		subMatchstick.add(subMatchstickOne);
		subMatchstickTwo.add("*");
		subMatchstickTwo.add("*");
		subMatchstickTwo.add("*");
		subMatchstickTwo.add("*");
		subMatchstickTwo.add("*");
		subMatchstick.add(subMatchstickTwo);
		subMatchstickThree.add("*");
		subMatchstickThree.add("7");
		subMatchstickThree.add("1");
		subMatchstickThree.add("*");
		subMatchstickThree.add("*");
		subMatchstick.add(subMatchstickThree);
		subMatchstickFour.add("*");
		subMatchstickFour.add("1");
		subMatchstickFour.add("*");
		subMatchstickFour.add("*");
		subMatchstickFour.add("*");
		subMatchstick.add(subMatchstickFour);
		subMatchstickFive.add("*");
		subMatchstickFive.add("*");
		subMatchstickFive.add("*");
		subMatchstickFive.add("*");
		subMatchstickFive.add("*");
		subMatchstick.add(subMatchstickFive);
		subMatchstickSix.add("5");
		subMatchstickSix.add("*");
		subMatchstickSix.add("7");
		subMatchstickSix.add("1");
		subMatchstickSix.add("*");
		subMatchstick.add(subMatchstickSix);
		subMatchstickSeven.add("1");
		subMatchstickSeven.add("*");
		subMatchstickSeven.add("*");
		subMatchstickSeven.add("*");
		subMatchstickSeven.add("*");
		subMatchstick.add(subMatchstickSeven);
		subMatchstickEight.add("069");
		subMatchstickEight.add("235");
		subMatchstickEight.add("4");
		subMatchstickEight.add("7");
		subMatchstickEight.add("1");
		subMatchstick.add(subMatchstickEight);
		subMatchstickNine.add("35");
		subMatchstickNine.add("4");
		subMatchstickNine.add("7");
		subMatchstickNine.add("1");
		subMatchstickNine.add("*");
		subMatchstick.add(subMatchstickNine);
		subMatchstickAdd.add("-");
		subMatchstickAdd.add("*");
		subMatchstickAdd.add("*");
		subMatchstickAdd.add("*");
		subMatchstickAdd.add("*");
		subMatchstick.add(subMatchstickAdd);
		subMatchstickSub.add("*");
		subMatchstickSub.add("*");
		subMatchstickSub.add("*");
		subMatchstickSub.add("*");
		subMatchstickSub.add("*");
		subMatchstick.add(subMatchstickSub);
	}
```

#### 2.2 根据题目要求随机修改等式

随机从等式中选择一个字符进行修改。如果选中‘=’就重新选择。选到其他数字或运算符号，存储为相应的数组中的Index。随机从{1,2,3,4,5}选择一个数字作为每一步要修改的火柴棍数目（该数字要小于当前题目要求可以修改的火柴棍数目）。根据不同的类型选择addMatchstick和subMatchstick，移动相当于先加后减。如果该数字或运算符号对应的结果为‘*’，则重新选择修改；如果对应的结果有多种，随机选择一个结果。每一步结束后把等式更新成修改过当前数字或运算符号的等式。当没有需要修改的火柴棍数目剩余的时候跳出循环。

```java
public static void changeQuestion(int type, int matchNum) {
		int equationIndex;// 等式中被选中要修改的数字或符号
		int changeNum;// 修改的火柴棍数量
		char changeNow;// 当前被修改的数字或符号
		int changeIndex;// 当前被修改的数字或符号存在ArrayList中的位置
		String changeTo;// 被修改后的数字或符号
		int max = matchNum * MAXN;

		while (matchNum > 0 && cnt < max) {
			cnt++;
			equationIndex = (int) (Math.random() * equation.length());// 随机选取等式中一个数字或符号进行修改
			changeNow = equation.charAt(equationIndex);
			if (changeNow == '=')
				continue;// 如果选取到‘=’，重新选取
			if (changeNow == '+')
				changeIndex = 10;
			else if (changeNow == '-')
				changeIndex = 11;
			else
				changeIndex = (int) changeNow - '0';
			changeNum = (int) (Math.random() * Math.min(5, matchNum));
			if (type == 1) {// 增加火柴棒
				if (addMatchstick.get(changeIndex).get(changeNum) == "*")
					continue;
				if (addMatchstick.get(changeIndex).get(changeNum).length() != 1) {// 当修改后得到的数字不唯一时
					int changeToIndex;
					changeToIndex = (int) (Math.random() * addMatchstick.get(changeIndex).get(changeNum).length());
					changeTo = addMatchstick.get(changeIndex).get(changeNum).substring(changeToIndex,
							changeToIndex + 1);
				} else
					changeTo = addMatchstick.get(changeIndex).get(changeNum);
			} else {
				if (subMatchstick.get(changeIndex).get(changeNum) == "*")
					continue;
				if (subMatchstick.get(changeIndex).get(changeNum).length() != 1) {// 当修改后得到的数字不唯一时
					int changeToIndex;
					changeToIndex = (int) (Math.random() * subMatchstick.get(changeIndex).get(changeNum).length());
					changeTo = subMatchstick.get(changeIndex).get(changeNum).substring(changeToIndex,
							changeToIndex + 1);
				} else
					changeTo = subMatchstick.get(changeIndex).get(changeNum);
			}
			equation = equation.substring(0, equationIndex) + changeTo + equation.substring(equationIndex + 1);
			matchNum -= (changeNum + 1);
		}
	}
```

## 三、main函数

先输出提示语句，让用户输入相应的限制条件。然后调用initialize初始化数字和运算符号的修改结果，生成相应的等式并根据题目要求修改。读入用户输入的结果与原来正确的等式相比较，如果正确则显示“正确”，反之则会显示“错误”并要求再次输入答案。直接输入回车可以得到正确答案。

每次题目做完后可以按任意键继续，如果输入“q”则结束程序。

```java
public static void main(String[] args) {
		String nextQuestion;
		do {
			cnt = 0;
			Scanner input = new Scanner(System.in);
			int digit, digitNum, type, matchNum;// 最大的数字，等号左式数字个数，题目类型，火柴棒数
			int flag;// 判断是否需要循环
			do {
				do {
					System.out.print("输入最大数字的位数（如1位数、2位数、3位数）：");
					digit = input.nextInt();
				} while (digit != 1 && digit != 2 && digit != 3);
				do {
					System.out.print("输入提示数（2或3），表示等号左式数字的个数：");
					digitNum = input.nextInt();
				} while (digitNum != 2 && digitNum != 3);
				do {
					flag = 0;
					System.out.print("输入题目类型编号（1移动、2移除、3添加），以及火柴棒根数（移动最多支持修改3根）:");
					type = input.nextInt();
					matchNum = input.nextInt();
					if (type == 1 && matchNum > 3)
						flag = 1;
				} while ((type != 1 && type != 2 && type != 3) || flag == 1);

				initialize();

				cnt = 0;
				question(digit, digitNum, type, matchNum);// 生成题目
				if (type == 1) {// 移动=先加后减
					changeQuestion(1, matchNum);
					changeQuestion(2, matchNum);
				} else if (type == 2)
					changeQuestion(1, matchNum);
				else
					changeQuestion(2, matchNum);
				if (cnt < matchNum * MAXN)
					System.out.println(equation);
				else
					System.out.println("无法生成这样的等式！请重新输入题目限制条件。");
			} while (cnt >= matchNum * MAXN);// 如果

			System.out.print("输入答案：");
			String answer;
			answer = input.nextLine();
			answer = input.nextLine();
			if (answer.equals(""))
				System.out.println(correctAnswer);
			else {
				while (!answer.equals(correctAnswer)) {
					System.out.println("错误");
					System.out.print("输入答案：");
					if (answer.equals("")) {
						System.out.println(correctAnswer);
						break;
					}
					answer = input.nextLine();
				}
				if (answer.equals(correctAnswer))
					System.out.println("正确");
			}
			System.out.println("按任意键继续，输入‘q’结束");
			nextQuestion = input.nextLine();
		} while (!nextQuestion.equals("q"));
	}
```

## 四、实验结果

此处展示部分实验结果

![image-20200925153156466](Java Homework 2 火柴棒游戏.assets/image-20200925153156466.png)

## 五、特点与不足

### 特点

1. 增加和删除可以支持任意根火柴棍的修改，如果不存在符合限制的题目则输出提示，要求重新输入要求；移动最多仅支持修改3根火柴棍。

   ![image-20201023124304102](Java Homework 2 火柴棒游戏.assets/image-20201023124304102.png)

2. 当输入的题目限制条件不符合题目要求的时候，重新输出题目要求，重新读入限制条件

3. 在修改火柴棍得到题目的代码部分用cnt限制循环次数，防止限制条件无解时陷入死循环

### 不足

1. 题目随机修改后生成的等式不一定是错误的，有可能修改后依然正确；并且题目的答案判断标准是唯一的，不支持多解。可以增加函数判断修改后的等式是否真确，如果正确则重新生成等式；关于题目的多解暂时没有想到简单的解决方案。
2. 生成的修改后显示的等式可能会存在个位数为0的二位数或三位数。可以增加判断的函数去除这种可能性。
3. 数字和运算符号的修改结果可以考虑用更加简洁的方式来存储，减少代码的冗余性并提高可读性。
4. 可以用UI界面显示火柴棍显示的等式，使用户获得更好的体验。

## 六、实验心得

debug的时候注意到equation需要在得出correctAnswer的时候就更新，如果放到changeQuestion函数中再赋值，会在移动火柴棍（先加后减）的时候两次都是修改最初的correctAnswer，导致生成的题目和移除一样。

本次实验是我第一次编写一个比较完整的java应用，在思考如何存储数字和运算符号的修改结果时查阅了很多资料，对于java的数据结构有了更加深入的理解。java和c++有一些不同的地方，比如不支持二维vector，在编写的时候要改变自己的c++编程习惯，去学习使用java的语法结构。使用random的时候要时刻牢记它的范围，防止出错。

