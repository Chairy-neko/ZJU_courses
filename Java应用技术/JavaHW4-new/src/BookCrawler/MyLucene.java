package BookCrawler;

import java.io.File;
import java.io.IOException;
import java.util.Scanner;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;
import org.wltea.analyzer.lucene.IKAnalyzer;

public class MyLucene {
	
	private static int bookid = 1;
	
	public static void main(String[] args){
		MyLucene w = new MyLucene();
		String filePath = "c:/JAVA/index";// 创建索引的存储目录
		w.createIndex(filePath);// 创建索引
	}

	public void createIndex(String filePath){
		File f = new File(filePath);
		IndexWriter iwr = null;
		try {
			Directory dir = FSDirectory.open(f);
			Analyzer analyzer = new IKAnalyzer();
			IndexWriterConfig conf = new IndexWriterConfig(Version.LUCENE_4_10_0, analyzer);
			iwr = new IndexWriter(dir, conf);// 建立IndexWriter。固定套路
//			int i = 29131096;//测试用
			Scanner scanner = new Scanner(System.in);
			int begin, end;
			System.out.println("输入你想要爬取的当当网图书号范围：");
			begin = scanner.nextInt();
			end = scanner.nextInt();
			for (int i = begin; i <= end; ++i) {
				bookid = i;
				System.out.println("正在爬取编号"+i+"的图书信息");
				CrawBook.getBookInfo("http://product.dangdang.com/"+i+".html");
				Document doc = getDocument();
				iwr.addDocument(doc);// 添加doc，Lucene的检索是以document为基本单位
				System.out.println("编号"+i+"的图书信息存储完毕！");
			}
			System.out.println("图书信息存储完毕！");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			iwr.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public Document getDocument(){
		// doc中内容由field构成，在检索过程中，Lucene会按照指定的Field依次搜索每个document的该项field是否符合要求。
		Document doc = new Document();
		String[] webStrings = CrawBook.webStrings;
		if(webStrings[0]== null || webStrings[0].equals("")) return doc;
		String str0 = String.format("%8d", bookid).replace(" ", "0");
		Field f0 = new TextField("bookid", str0, Field.Store.YES);
		Field f1 = new TextField("title", webStrings[0], Field.Store.YES);
		Field f2 = new TextField("author", webStrings[1], Field.Store.YES);
		Field f3 = new TextField("type", webStrings[2], Field.Store.YES);
		Field f4 = new TextField("public", webStrings[3], Field.Store.YES);
		Field f5 = new TextField("time", webStrings[4], Field.Store.YES);
		Field f6 = new TextField("price", webStrings[5], Field.Store.YES);
		Field f7 = new TextField("editor", webStrings[6], Field.Store.YES);
		Field f8 = new TextField("abstract", webStrings[7], Field.Store.YES);
		Field f9 = new TextField("authorIntro", webStrings[8], Field.Store.YES);
		Field f10 = new TextField("catalog", webStrings[9], Field.Store.YES);
		Field f11 = new TextField("picture", webStrings[10],Field.Store.YES);

		doc.add(f0);
		doc.add(f1);
		doc.add(f2);
		doc.add(f3);
		doc.add(f4);
		doc.add(f5);
		doc.add(f6);
		doc.add(f7);
		doc.add(f8);
		doc.add(f9);
		doc.add(f10);
		doc.add(f11);

		return doc;
	}

	public static void searrh(String filePath) {
		Scanner scanner = new Scanner(System.in);
		File f = new File(filePath);
		try {
			IndexSearcher searcher = new IndexSearcher(DirectoryReader.open(FSDirectory.open(f)));
			System.out.println("请输入你想检索的类型（a-书号，b-标题，c-作者，d-分类，e-出版社）：");
			String searchType = scanner.nextLine();
			Analyzer analyzer = new IKAnalyzer();
			String queryType = null;
			switch (searchType) {
			case "a":
				queryType = "bookid";
				break;
			case "b":
				queryType = "title";
				break;
			case "c":
				queryType = "author";
				break;
			case "d":
				queryType = "type";
				break;
			case "e":
				queryType = "public";
				break;
			default:
				break;
			}
			QueryParser parser = new QueryParser(Version.LUCENE_4_10_0, queryType, analyzer);
			System.out.println("请输入你想检索的内容：");
			String queryStr = scanner.nextLine();
			// 指定field为“name”，Lucene会按照关键词搜索每个doc中的name。

			Query query = parser.parse(queryStr);
			TopDocs hits = searcher.search(query, 1);// 前面几行代码也是固定套路，使用时直接改field和关键词即可
			for (ScoreDoc doc : hits.scoreDocs) {
				Document d = searcher.doc(doc.doc);
				System.out.println(d.get("bookid"));
				System.out.println(d.get("title"));
				System.out.println(d.get("author"));
				System.out.println(d.get("type"));
				System.out.println(d.get("public"));
				System.out.println(d.get("time"));
				System.out.println(d.get("price"));
				System.out.println(d.get("editor"));
				System.out.println(d.get("abstract"));
				System.out.println(d.get("authorIntro"));
				System.out.println("目录：\n"+d.get("catalog"));
				System.out.println(d.get("picture"));
			}
		} catch (IOException | ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
