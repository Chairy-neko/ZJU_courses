package BookCrawler;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.FailingHttpStatusCodeException;
import com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlPage;

public class CrawBook {
	static String[] webStrings = new String[11];
	
	public static void getBookInfo(String url){

		/* 标题、作者、分类、出版社、图书照片、编辑推荐、内容简介、作者简介、目录、价格等信息 */
		
		//创建一个webclient 
        WebClient webClient = new WebClient(BrowserVersion.CHROME);   

        //参数设置  
        // 1 启动JS  
        webClient.getOptions().setJavaScriptEnabled(true);  
        // 2 禁用Css，可避免自动二次请求CSS进行渲染  
        webClient.getOptions().setCssEnabled(false);  
        //3 启动客户端重定向  
        webClient.getOptions().setRedirectEnabled(true);  
        // 4 运行错误时，是否抛出异常  
        webClient.getOptions().setThrowExceptionOnScriptError(false);  
        // 5 设置超时  
        webClient.getOptions().setTimeout(5000);  
        //6 设置忽略证书  
        webClient.getOptions().setUseInsecureSSL(true);  
        //7 设置Ajax  
        webClient.setAjaxController(new NicelyResynchronizingAjaxController());  
        //8设置cookie  
        webClient.getCookieManager().setCookiesEnabled(true);  

        // 等待JS驱动dom完成获得还原后的网页  
        webClient.waitForBackgroundJavaScript(8000); 
        HtmlPage page = null;
		try {
			page = webClient.getPage(url);
		} catch (FailingHttpStatusCodeException | IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
        //4.将页面转成指定格式  
        webClient.waitForBackgroundJavaScript(8000);   //等侍js脚本执行完成 
		if(page == null) return ;
        String html = page.asXml();
		Document document = Jsoup.parse(html);
		
		Element titleElement = document.select("div.name_info > h1").first();
		Element authorElement = document.select("span:contains(作者)").first();
		Elements typeElement = document.select("#detail-category-path");
		Element publicElement = document.select("span:contains(出版社)").first();
		Element timeElement = document.select("span:contains(出版时间)").first();
		Elements priceElement = document.select("#dd-price");
		Elements editorElement = document.select("div#abstract.section > div.descrip");//div#abstract.section > div.descrip
		Elements abstractElement = document.select("div#content.section > div.descrip");
		Elements authorIntroElement = document.select("div#authorIntroduction.section > div.descrip");
		Elements catalogElement = document.select("div#catalog.section > div.descrip > #catalog-textarea");
		Element pictureElement = document.select("div.pic > a.img > img").first();
		
//		System.out.println(editorElement.html());//测试动态加载用
		
		webStrings[0] = (titleElement!=null)?("标题："+titleElement.text()):"";
		webStrings[1] = (authorElement!=null)?authorElement.text():"";
		webStrings[2] = (typeElement!=null)?typeElement.text():"";
		webStrings[3] = (publicElement!=null)?publicElement.text():"";
		webStrings[4] = (timeElement!=null)?timeElement.text():"";
		webStrings[5] = (priceElement!=null)?("价格："+priceElement.text()):"";
		webStrings[6] = (editorElement!=null)?("编辑推荐：\n"+editorElement.text()):"";
		webStrings[7] = (abstractElement!=null)?("内容简介：\n"+abstractElement.text()):"";
		webStrings[8] = (authorIntroElement!=null)?("作者简介：\n"+authorIntroElement.text()):"";

		String catalogString = catalogElement.text();
		String aa = "";
		Pattern p = Pattern.compile("<|>|p|/");
		Matcher m = p.matcher(catalogString);

		webStrings[9] = m.replaceAll(aa).trim();
		webStrings[10] = (pictureElement!=null)?("图片链接：\n"+pictureElement.attr("src")):"";
	}
}
