package com.elle.bleaf;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.ContentValues;
import android.content.Context;
import android.database.SQLException;
import android.util.Xml;

public class BLeafParser {
	public static final String TAG_EVIDENCES = "evidences";
	public static final String TAG_EVIDENCE = "evidence";
	public static final String TAG_TITLE = "title";
	public static final String TAG_DESCRIPTION = "description";
	public static final String TAG_CATEGORIES = "categories";
	public static final String TAG_CATEGORY = "category";
	public static final String TAG_CATNAME = "name";
	public static final String TAG_CATRATING = "rating";
	public static final String TAG_SOURCE = "source";
	public static final String TAG_LINK = "link";
	public static final String TAG_COMPANIES = "companies";
	public static final String TAG_COMPANY = "company";
	public static final String TAG_COMP_NORM = "norm";
	public static final String TAG_COMP_TAG = "tagged";
	public static final String TAG_GCPS = "gcps";
	public static final String TAG_GCP = "gcp";
	
	
	
	
	static final String PUB_DATE = "pubDate";
	static final String DESCRIPTION = "description";
	static final String LINK = "link";
	static final String TITLE = "title";
	static final String ITEM = "item";
	static final String CHANNEL = "channel";
	
	static ArrayList<Message> messages = null;
	static ArrayList<Item> items = null;
	public static ArrayList<String> history;
	public static ArrayList<String> myCauses;
	static{
		myCauses = new ArrayList<String>();
		myCauses.add("123");
		myCauses.add("789");
	}
	public static void getFeeds(Context context){
		String link = "http://elleconnect.com/andrewdo/bleaf/sample4.rss";
		System.out.println("getting feed...");
		try {
			URL url = new URL(link);                	    
			try {
				InputStream stream = url.openConnection().getInputStream();
				try {
					// FIXME: need to do validation of the XML against the DTD of RSS
					XmlPullParser parser = Xml.newPullParser();
					try {
						// auto-detect the encoding from the stream
						parser.setInput(stream, null);
						int eventType = parser.getEventType();
						Message currentMessage = null;
						boolean done = false;
						while (eventType != XmlPullParser.END_DOCUMENT && !done){
							String name = null;
							switch (eventType){
							case XmlPullParser.START_DOCUMENT:
								messages = new ArrayList<Message>();
								break;
							case XmlPullParser.START_TAG:
								name = parser.getName();
								if (name.equalsIgnoreCase(ITEM)){
									currentMessage = new Message();
								} else if (currentMessage != null){
									if (name.equalsIgnoreCase(LINK)){
										currentMessage.setLink(parser.nextText());
									} else if (name.equalsIgnoreCase(DESCRIPTION)){
										currentMessage.setDescription(parser.nextText());
									} else if (name.equalsIgnoreCase(PUB_DATE)){
										currentMessage.setDate(parser.nextText());
									} else if (name.equalsIgnoreCase(TITLE)){
										currentMessage.setTitle(parser.nextText());
									}    
								}
								break;
							case XmlPullParser.END_TAG:
								name = parser.getName();
								if (name.equalsIgnoreCase(ITEM) && 
										currentMessage != null){
									messages.add(currentMessage);
								} else if (name.equalsIgnoreCase(CHANNEL)){
									done = true;
								}
								break;
							}
							eventType = parser.next();
						}
					} catch (Exception e) {
						throw new RuntimeException(e);
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				} 
			} catch (IOException e) {
				System.out.println("Could not access file " + url.toString());
			}
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}
		if (messages != null) {
			System.out.println("checking messages...");
			Iterator<Message> itr = messages.iterator();
			while (itr.hasNext()) {
				Message mesg = itr.next();
				// text.setText(text.getText()+"\n"+mesg.getDescription());
				// find a match of the URL information for the XML File
				Pattern p = Pattern.compile("StartBLeaf (.+?) EndBLeaf",Pattern.DOTALL);
				Matcher m = p.matcher(mesg.getDescription());						
				boolean matchFound = m.find();
				if (matchFound) {
				    // Get all groups for this match
				    for (int i=0; i<=m.groupCount(); i++) {
				        if (i == 1) {
				        	String link2 = m.group(i);						        
				        	System.out.println("Extracted Announcement Link "+link2);
				        	try {
								URL url2 = new URL(link2);
//								processAnnouncement(url2);
								readAnnouncement(url2, context);
				    		} catch (MalformedURLException e) {
								throw new RuntimeException(e);
							}
				        }
				    }
				}
			}
		}
	}
	
	private static String nextText(XmlPullParser parser){
		try {
			return parser.nextText().replace('\'', ' ');
		} catch (XmlPullParserException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
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
			System.out.println(total);
			
			InputStream is = url.openConnection().getInputStream();
			XmlPullParser parser = Xml.newPullParser();
			parser.setInput(is, null);
			int eventType = parser.getEventType();
			
			ArrayList<Evidence> items = null;
			Evidence e = null;
			Boolean done = false;
			String company = "";
			
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
						
					} else if(name.equalsIgnoreCase(TAG_CATEGORY)){
						
					} else if(name.equalsIgnoreCase(TAG_CATNAME)){
						e.categories.add(nextText(parser));
					} else if(name.equalsIgnoreCase(TAG_CATRATING)){
						e.ratings.add(nextText(parser));
					} else if(name.equalsIgnoreCase(TAG_SOURCE)){
						e.source = nextText(parser);
					} else if(name.equalsIgnoreCase(TAG_LINK)){
						e.link = nextText(parser);
					} else if(name.equalsIgnoreCase(TAG_COMPANIES)){
						
					} else if(name.equalsIgnoreCase(TAG_COMPANY)){
						
					} else if(name.equalsIgnoreCase(TAG_COMP_NORM)){
						company = nextText(parser);
						e.addCompany(company);
					} else if(name.equalsIgnoreCase(TAG_COMP_TAG)){
						
					} else if(name.equalsIgnoreCase(TAG_GCPS)){
						
					} else if(name.equalsIgnoreCase(TAG_GCP)){
						e.addGcp(company, nextText(parser));
					}
					break;
				case XmlPullParser.END_TAG:
					name = parser.getName();
					if(name.equalsIgnoreCase(TAG_EVIDENCE)){
						items.add(e);
					} else if(name.equalsIgnoreCase(TAG_EVIDENCES)){
						done = true;
					}
					break;
				case XmlPullParser.END_DOCUMENT:
					
					break;
				}
				eventType = parser.next();
				
			}
			
			if(items != null){
				BLeafDbAdapter db = new BLeafDbAdapter(context);
				Iterator<Evidence> i = items.iterator();
				while(i.hasNext()){
					Evidence ev = i.next();
					System.out.println("searching for: " + ev.title);
					if(!db.evidenceExists(ev)){
						System.out.println("Adding to DB: " + ev.title);
						ContentValues v;
						int eid = Integer.parseInt((db.insertStuff(BLeafDbHelper.TABLE_EVIDENCE, ev.getEvidenceValues())).getLastPathSegment());
						Iterator<String> j = ev.companies.iterator();
						while(j.hasNext()){
							String comp = j.next();
							int cid = db.getCompanyId(comp);
							if(cid < 0){
								v = new ContentValues();
								v.put(BLeafDbHelper.COL_NAME, comp);
								cid = Integer.parseInt((db.insertStuff(BLeafDbHelper.TABLE_COMPANYINFO, v)).getLastPathSegment());
							}
							v = new ContentValues();
							v.put(BLeafDbHelper.COL_EVIDENCE_ID, eid);
							v.put(BLeafDbHelper.COL_COMPANY_ID, cid);
							db.insertStuff(BLeafDbHelper.TABLE_EVIDENCE_COMP, v);
							Iterator<String> g = ev.getGcps(comp).iterator();
							while(g.hasNext()){
								String gcp = g.next();
								if(!db.gcpExists(gcp)){
									v = new ContentValues();
									v.put(BLeafDbHelper.COL_GCP, gcp);
									v.put(BLeafDbHelper.COL_COMPANY_ID, cid);
									db.insertStuff(BLeafDbHelper.TABLE_GCP, v);
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
		} catch(IOException e){
			System.out.println("unable to access file: " + url.toString());
		} catch(SQLException e){
			System.out.println("error inserting into database!");
			e.printStackTrace();
		} catch(Exception e){
			System.out.println("xml parsing error!");
			e.printStackTrace();
		}
		
	}
	
	public static void processAnnouncement(URL url) {
		System.out.println("processing announcements...");
		// need to create an object representing the Boycott
//		final TextView text = (TextView) findViewById(R.id.textView4);
		try {
			InputStream stream = url.openConnection().getInputStream();
			try {
				// FIXME: need to do validation of the XML against the DTD
				XmlPullParser parser = Xml.newPullParser();
				try {
					// auto-detect the encoding from the stream
					parser.setInput(stream, null);
					int eventType = parser.getEventType();
					Item currentItem = null;
					boolean done = false;
					boolean inside = false;
					boolean insidereasons = false;
					String source = null;
					String reasons_source = null;
					String reasons_content = null;
					Assertion assertion = null;
					while (eventType != XmlPullParser.END_DOCUMENT && !done){
						String name = null;
						switch (eventType){
						case XmlPullParser.START_DOCUMENT:
							items = new ArrayList<Item>();
							break;
						case XmlPullParser.START_TAG:
							name = parser.getName();
							if (name.equalsIgnoreCase("source") && ! inside) {
								source = parser.nextText();
							} else if (name.equalsIgnoreCase("item")){
								inside = true;
								currentItem = new Item();
							} else if (currentItem != null){
								if (name.equalsIgnoreCase("title")){
									currentItem.setTitle(parser.nextText());
									currentItem.setSource(source);
									System.out.println(currentItem.getTitle());
								} else if (name.equalsIgnoreCase("category")){
									currentItem.setCategory(parser.nextText());
								} else if (name.equalsIgnoreCase("assert")){
									assertion = new Assertion(currentItem,Assertion.Action.ASSERT);							
								} else if (name.equalsIgnoreCase("retract")){
									assertion = new Assertion(currentItem,Assertion.Action.RETRACT);
								} else if (name.equalsIgnoreCase("cause")){
									assertion.setCause(parser.nextText());									
								} else if (name.equalsIgnoreCase("manufacturer")){
									assertion.addManufacturer(parser.nextText());
								} else if (name.equalsIgnoreCase("reasons")){									
									// currentItem.setTitle(parser.nextText());
									insidereasons = true;
								} else if (name.equalsIgnoreCase("source") && insidereasons == true) {
									reasons_source = parser.nextText();
								} else if (name.equalsIgnoreCase("content") && insidereasons == true) {
									reasons_content = parser.nextText();
								}
							}
							break;
						case XmlPullParser.END_TAG:
							name = parser.getName();
							if (name.equalsIgnoreCase("item")) {
								inside = false;
								if (currentItem != null){
									items.add(currentItem);
								}
							} else if (name.equalsIgnoreCase("announcements")){
								done = true;
							} else if (currentItem != null) {
								if (name.equalsIgnoreCase("reasons")) {
									insidereasons = false;
									currentItem.addReason(new Reason(reasons_source,reasons_content));
								} else if (name.equalsIgnoreCase("assert") || name.equalsIgnoreCase("retract"))	{
									currentItem.addLogic(assertion);
								}
							}
							break;
						}
						eventType = parser.next();
					}
				} catch (Exception e) {
					throw new RuntimeException(e);
				}
			} catch (Exception e) {
				throw new RuntimeException(e);
			} 
		} catch (IOException e) {
			// throw new RuntimeException(e);
			System.out.println("Could not access file " + url.toString());
		}
		if (items != null) {
			Iterator<Item> itr = items.iterator();
			while (itr.hasNext()) {
				Item item = itr.next();
				System.out.println("Added item " + item.printLogic());
			}
		}
	}
	
	
	public static ArrayList<Assertion> scan (String manufacturer) {
		// look at every item
		ArrayList<Assertion> results = new ArrayList<Assertion>();
		if (items != null) {
			// iterate over it
			Iterator<Item> itr = items.iterator();
			while (itr.hasNext()) {
				Item item = itr.next();
				Iterator<Assertion> itr2 = item.getLogic().iterator();
				while (itr2.hasNext()) {
					Assertion assertion = itr2.next();
					if (myCauses.contains(assertion.getCause())) {
						if (assertion.getManufacturers().contains(manufacturer)) {
							// add the assertion to the results
							results.add(assertion);
						}
					}
				}
				
			}
		} else {
			System.out.println("First populate your items\n");
		}
		return results;
	}
}
