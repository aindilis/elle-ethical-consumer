package com.elle.bleaf;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.util.Xml;

import com.elle.bleaf.Evidence.Link;

public class BLeafParser {
	public static final String TAG_EVIDENCES = "evidences";
	public static final String TAG_EVIDENCE = "evidence";
	public static final String TAG_TITLE = "title";
	public static final String TAG_DESCRIPTION = "description";
	public static final String TAG_CATEGORIES = "categories";
	public static final String TAG_CATEGORY = "category";
	public static final String TAG_CATNAME = "category-name";
	public static final String TAG_CATRATING = "rating";
	public static final String TAG_SOURCE = "source";
	public static final String TAG_LINKS = "links";
	public static final String TAG_LINKTEXT = "link-text";
	public static final String TAG_LINKURL = "url";
	public static final String TAG_LINKDATE = "date";
	public static final String TAG_COMPANIES = "companies";
	public static final String TAG_COMPANY = "company";
	public static final String TAG_COMP_NORM = "normalized";
	public static final String TAG_COMP_TAG = "tagged";
	public static final String TAG_GCPS = "gcps";
	public static final String TAG_GCP = "gcp";
	public static final String TAG_SCORE = "score";
	
	public static void getFeed(Context context, String pUrl){
		try{
			System.out.println("Getting feed: " + pUrl);
			URL url = new URL(pUrl);
			URLConnection con = url.openConnection();
			InputStream inputStream = con.getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(inputStream));
			StringBuilder total = new StringBuilder();
			String line;
			while ((line = r.readLine()) != null) {
			    total.append(line);
			    total.append("\n");
			}
			
			
			
			
			
			
			Pattern p = Pattern.compile("StartbLeaf (.+?) EndbLeaf",Pattern.DOTALL);
			Matcher m = p.matcher(total);						
			boolean matchFound = m.find();
			boolean read = true;
			if (matchFound) {
			    // Get all groups for this match
			    for (int i=0; i<=m.groupCount(); i++) {
			        if (i == 1) {
			        	String link2 = m.group(i);						        
			        	System.out.println("Extracted Announcement Link "+link2);
			        	try {
							URL url2 = new URL(link2);
							readAnnouncement(url2, context);
			    		} catch (Exception e) {
							read = false;
							e.printStackTrace();
						}
			        }
			    }
			}
			if(read){
				BLeafDbAdapter db = new BLeafDbAdapter(context);
				ContentValues v = new ContentValues();
				v.put(BLeafDbHelper.COL_MD5, MD5_Hash(getHeaderStuff(con)));
				String where = "url=?";
				String[] arg = new String[]{pUrl};
				db.updateStuff(BLeafDbHelper.TABLE_FEEDS, v, where, arg);
			}
		} catch(IOException e){
			e.printStackTrace();
		}
	}
	
	private static String nextText(XmlPullParser parser){
		try {
			return parser.nextText().replace('\'', ' ');
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static void readAnnouncement(URL url, Context context){
		try{

			InputStream inputStream = url.openConnection().getInputStream();
			BufferedReader r = new BufferedReader(new InputStreamReader(inputStream));
			StringBuilder total = new StringBuilder();
			String line;
			while ((line = r.readLine()) != null) {
			    total.append(line);
			    total.append("\n");
			}
//			System.out.println(total);
			
			BLeafDbAdapter db = new BLeafDbAdapter(context);
			
//			URL u = new URL("http://elleconnect.com/andrewdo/bleaf/sample12.xml");
			URLConnection connection = url.openConnection();
			InputStream is = connection.getInputStream();
			
			
//			Map<String, List<String>> responseMap = connection.getHeaderFields();
//			for (Iterator<String> iterator = responseMap.keySet().iterator(); iterator.hasNext();) {
//			    String key = (String) iterator.next();
//			    System.out.print(key + " = ");
//
//			    List<String> values = responseMap.get(key);
//			    for (int i = 0; i < values.size(); i++) {
//			        Object o = values.get(i);
//			        System.out.println(o + ", ");
//			    }
//			    System.out.println("");
//			}
			
			Boolean exists;
			Boolean loaded = false;
			String md5 = MD5_Hash(total.toString());
			Cursor c;
			String where = "url=?";
			String[] arg = new String[]{url.toString()};
			c = db.queryStuff(BLeafDbHelper.TABLE_XML, null, where, arg, null);
			c.moveToFirst();
			if(c.getCount() == 0){
				loaded = false;
				exists = false;
			} else {
				String stored = c.getString(c.getColumnIndex(BLeafDbHelper.COL_MD5));
//			    System.out.println("Comparing XML MD5s");
//			    System.out.println("calculated: " + md5);
//			    System.out.println("stored:     " + stored);
			    exists = true;
				if(md5.equalsIgnoreCase(stored))
					loaded = true;
			}
			if(loaded)
				return;
			
//			System.out.println("Starting XML validation...");
//			URL schemaurl = new URL("http://www.elleconnect.com/andrewdo/bleaf/xsds/sample11.xsd");
//						
//			SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_INSTANCE_NS_URI);
//			Schema schema = factory.newSchema(schemaurl);
//			Validator validator = schema.newValidator();
//			Source source = new SAXSource(new InputSource(is));
//			validator.validate(source);
//			System.out.println("XML validated!");
			
			
//			System.out.println("Opening Parser...");
			XmlPullParser parser = Xml.newPullParser();
			parser.setInput(is, null);
			int eventType = parser.getEventType();
			
			ArrayList<Evidence> items = null;
			Evidence e = null;
			boolean done = false;
			boolean insource = false;
			boolean inlinks = false;
			boolean incats = false;
			boolean incomps = false;
			String company = "";
			String linkname = "";
			
//			System.out.println("Starting parsing...");
			while(eventType != XmlPullParser.END_DOCUMENT && !done){
				String name = null;
				switch(eventType){
				case XmlPullParser.START_DOCUMENT:
					items = new ArrayList<Evidence>();
					break;
				case XmlPullParser.START_TAG:
					name = parser.getName();
					if(name.equalsIgnoreCase(TAG_EVIDENCES)){
						
					} else if(name.equalsIgnoreCase(TAG_EVIDENCE)){
						e = new Evidence();
					} else if(name.equalsIgnoreCase(TAG_TITLE)){
						e.title = nextText(parser);
					} else if(name.equalsIgnoreCase(TAG_DESCRIPTION)){
						e.description = nextText(parser);
					} else if(name.equalsIgnoreCase(TAG_CATEGORIES)){
						incats = true;
					} else if(name.equalsIgnoreCase(TAG_CATEGORY)){
						
					} else if(name.equalsIgnoreCase(TAG_CATNAME) && incats){
						e.categories.add(nextText(parser));
					} else if(name.equalsIgnoreCase(TAG_CATRATING) && incats){
						e.ratings.add(nextText(parser));
					} else if(name.equalsIgnoreCase(TAG_SOURCE)){
						insource = true;
					} else if(name.equalsIgnoreCase(TAG_LINKS)){
						inlinks = true;
					} else if(name.equalsIgnoreCase(TAG_LINKTEXT)){
						if(insource)
							e.source = nextText(parser);
						else if(inlinks)
							linkname = nextText(parser);
					} else if(name.equalsIgnoreCase(TAG_LINKURL)){
						if(insource)
							e.link = nextText(parser);
						else if(inlinks)
							e.addLink(linkname, nextText(parser));
					} else if(name.equalsIgnoreCase(TAG_COMPANIES)){
						incomps = true;
					} else if(name.equalsIgnoreCase(TAG_COMPANY)){
						
					} else if(name.equalsIgnoreCase(TAG_COMP_NORM) && incomps){
						company = nextText(parser);
						e.addCompany(company);
					} else if(name.equalsIgnoreCase(TAG_COMP_TAG)){
						
					} else if(name.equalsIgnoreCase(TAG_GCPS)){
						
					} else if(name.equalsIgnoreCase(TAG_GCP) && incomps){
						String gcp = nextText(parser);
						if(gcp != null && !gcp.equalsIgnoreCase("") && company != null && !company.equalsIgnoreCase(""))
							e.addGcp(company, gcp);
					} else if(name.equalsIgnoreCase(TAG_SCORE) && incomps){
						e.addScore(company, nextText(parser));
					} 
					break;
				case XmlPullParser.END_TAG:
					name = parser.getName();
					if(name.equalsIgnoreCase(TAG_EVIDENCE)){
						items.add(e);
					} else if(name.equalsIgnoreCase(TAG_EVIDENCES)){
						done = true;
					} else if(name.equalsIgnoreCase(TAG_SOURCE)){
						insource = false;
					} else if(name.equalsIgnoreCase(TAG_LINKS)){
						inlinks = false;
					} else if(name.equalsIgnoreCase(TAG_COMPANIES)){
						incomps = false;
					} else if(name.equalsIgnoreCase(TAG_CATEGORIES)){
						incats = false;
					} 
					break;
				case XmlPullParser.END_DOCUMENT:
					
					break;
				}
				eventType = parser.next();
				
			}

			ContentValues v;
			if(items != null){
				Iterator<Evidence> i = items.iterator();
				while(i.hasNext()){
					Evidence ev = i.next();
//					System.out.println("searching for: " + ev.title);
					if(!db.evidenceExists(ev)){
						System.out.println("Adding to DB: " + ev.title);
						int eid = Integer.parseInt((db.insertStuff(BLeafDbHelper.TABLE_EVIDENCE, ev.getEvidenceValues())).getLastPathSegment());
						Iterator<String> j = ev.companies.iterator();
						while(j.hasNext()){
							String comp = j.next();
							if(comp != null && !comp.equalsIgnoreCase("") && !comp.equalsIgnoreCase(" ")){
//								System.out.println("searching for: " + comp);
								int cid = db.getCompanyMapId(comp);
								if(cid < 0){
									v = new ContentValues();
									v.put(BLeafDbHelper.COL_NAME, comp);
//									System.out.println("Adding to DB: " + comp);
									cid = Integer.parseInt(db.insertCompany(v).getLastPathSegment());
								}
								v = new ContentValues();
								v.put(BLeafDbHelper.COL_EVIDENCE_ID, eid);
								v.put(BLeafDbHelper.COL_COMPANY_ID, cid);
								v.put(BLeafDbHelper.COL_SCORE, ev.getScore(comp));
								db.insertStuff(BLeafDbHelper.TABLE_EVIDENCE_COMP, v);
								Iterator<String> g = ev.getGcps(comp).iterator();
								while(g.hasNext()){
									String gcp = g.next();
									if(!db.gcpMapExists(gcp)){
										v = new ContentValues();
										v.put(BLeafDbHelper.COL_GCP, gcp);
										v.put(BLeafDbHelper.COL_COMPANY_ID, cid);
										db.insertGcp(v);
	//									db.insertStuff(BLeafDbHelper.TABLE_GCP, v);
									}
								}
								Iterator<Link> l = ev.getLinks().iterator();
								while(l.hasNext()){
									Link link = l.next();
									v = new ContentValues();
									v.put(BLeafDbHelper.COL_EVIDENCE_ID, eid);
									v.put(BLeafDbHelper.COL_NAME, link.name);
									v.put(BLeafDbHelper.COL_URL, link.url);
									db.insertStuff(BLeafDbHelper.TABLE_LINKS, v);
								}
							}
						}
						
						Iterator<String> k = ev.categories.iterator();
						while(k.hasNext()){
							String cat = k.next();
							int catid = db.getCategoryId(cat);
							v = new ContentValues();
							v.put(BLeafDbHelper.COL_EVIDENCE_ID, eid);
							v.put(BLeafDbHelper.COL_CATEGORY_ID, catid);
							db.insertStuff(BLeafDbHelper.TABLE_EVIDENCE_CATS, v);
						}
					}
				}
			}
			
			v = new ContentValues();
			v.put(BLeafDbHelper.COL_URL, url.toString());
			v.put(BLeafDbHelper.COL_MD5, md5);
			if(exists)
				db.updateStuff(BLeafDbHelper.TABLE_XML, v, where, arg);
			else
				db.insertStuff(BLeafDbHelper.TABLE_XML, v);
		} catch(IOException e){
			System.out.println("unable to access file: " + url.toString());
		} catch(SQLException e){
			System.out.println("error inserting into database!");
			e.printStackTrace();
		} catch (XmlPullParserException e) {
			System.out.println("Error parsing XML!");
			e.printStackTrace();
		} 
//		catch (SAXException e) {
//			System.out.println("XML validation error: " + e.getMessage());
//			e.printStackTrace();
//		} 
	}
	
	public static boolean checkFeed(String pUrl, String pMD5) throws MalformedURLException{
//		URL url = new URL(pUrl);
//		HttpURLConnection con;
//		try {
//			con = (HttpURLConnection) url.openConnection();
//			con.setRequestMethod("HEAD");
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
		
		
		
		
        try {
            URL url = new URL(pUrl);
            URLConnection connection = url.openConnection();

//            Map<String, List<String>> responseMap = connection.getHeaderFields();
//            for (Iterator<String> iterator = responseMap.keySet().iterator(); iterator.hasNext();) {
//                String key = (String) iterator.next();
//                System.out.print(key + " = ");
//
//                List<String> values = responseMap.get(key);
//                for (int i = 0; i < values.size(); i++) {
//                    Object o = values.get(i);
//                    System.out.println(o + ", ");
//                }
//                System.out.println("");
//            }
            
            
            
            String md5 = MD5_Hash(getHeaderStuff(connection));
            System.out.println("Comparing MD5s");
            System.out.println("calculated: " + md5);
            System.out.println("stored:     " + pMD5);
            return md5.equalsIgnoreCase(pMD5);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

		
		
		
		
		
		
		return false;
	}
	
	private static String getHeaderStuff(URLConnection con){
        Map<String, List<String>> responseMap = con.getHeaderFields();
		String mod = responseMap.get("last-modified").get(0);
        String length = responseMap.get("content-length").get(0);
        return mod + length;
	}
	
	public static String MD5_Hash(String s) {
		MessageDigest m = null;

		try {
            m = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
		}

		m.update(s.getBytes(),0,s.length());
		String hash = new BigInteger(1, m.digest()).toString(16);
		return hash;
	}
}
