package com.elle.bleaf;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;

public class BLeafDbHelper extends SQLiteOpenHelper {
	private static String DB_PATH = "/data/data/com.elle.bleaf/databases/";
	private static final String DATABASE_NAME = "appdata.db";
	private static final int DATABASE_VERSION = 7;
	private static final String DEFAULT_FEED = "http://elleconnect.com/andrewdo/bleaf/sample13.html";
		
	public static final String TABLE_EVIDENCE = "evidence";
	public static final String TABLE_EVIDENCE_CATS = "evidence_categories";
	public static final String TABLE_EVIDENCE_COMP = "evidence_companies";
	public static final String TABLE_SOURCE = "sources";
	public static final String TABLE_GROUPINFO = "group_info";
	public static final String TABLE_COMPANYINFO = "company_info";
	public static final String TABLE_GROUPS = "groups";
	public static final String TABLE_RATINGINFO = "rating_schemes";
	public static final String TABLE_RATING = "ratings";
	public static final String TABLE_CATEGORY = "categories";
	public static final String TABLE_RULES = "rules";
	public static final String TABLE_ACTIONS = "actions";
	public static final String TABLE_GCP = "gcp";
	public static final String TABLE_HISTORY = "history";
	public static final String TABLE_LINKS = "links";
	public static final String TABLE_FEEDS = "feeds";
	public static final String TABLE_XML = "xml";
	
	public static final String COL_ID = "_id";
	public static final String COL_TITLE = "title";
	public static final String COL_DESCRIPTION = "description";
	public static final String COL_SOURCE = "source";
	public static final String COL_LINK = "link";
	public static final String COL_EVIDENCE_ID = "evidence_id";
	public static final String COL_COMPANY_ID = "company_id";
	public static final String COL_CATEGORY_ID = "category_id";
	public static final String COL_NAME = "name";
	public static final String COL_RATING = "rating";
	public static final String COL_GCP = "gcp";
	public static final String COL_TIME = "time";
	public static final String COL_SCORE = "score";
	public static final String COL_URL = "url";
	public static final String COL_MD5 = "md5";
	
	private static final String CREATE_TABLE_EVIDENCE =
			"CREATE TABLE " + TABLE_EVIDENCE + " (" +
					COL_ID + " integer primary key autoincrement," +
					COL_TITLE + " text not null," +
					COL_DESCRIPTION + " text," +
					COL_SOURCE + " text not null," +
					COL_LINK + " text);";
	private static final String CREATE_TABLE_COMPANYINFO =
			"CREATE TABLE " + TABLE_COMPANYINFO + " (" +
					COL_ID + " integer primary key autoincrement," +
					COL_NAME + " text not null);";
	private static final String CREATE_TABLE_EVIDENCE_COMP =
			"CREATE TABLE " + TABLE_EVIDENCE_COMP + " (" +
					COL_EVIDENCE_ID + " integer," +
					COL_COMPANY_ID + " integer, " +
					COL_SCORE + " integer);";
	private static final String CREATE_TABLE_CATEGORY =
			"CREATE TABLE " + TABLE_CATEGORY + " (" +
					COL_ID + " integer primary key autoincrement," +
					COL_NAME + " text not null, " +
					COL_RATING + " real not null);";
	private static final String CREATE_TABLE_EVIDENCE_CATS =
			"CREATE TABLE " + TABLE_EVIDENCE_CATS + " (" +
					COL_EVIDENCE_ID + " integer," +
					COL_CATEGORY_ID + " integer);";
	private static final String CREATE_TABLE_GCP =
			"CREATE TABLE " + TABLE_GCP + " (" +
					COL_ID + " integer primary key autoincrement, " +
					COL_GCP + " string not null, " +
					COL_COMPANY_ID + " int not null);";
	private static final String CREATE_TABLE_HISTORY =
			"CREATE TABLE " + TABLE_HISTORY + " (" +
					COL_ID + " integer primary key autoincrement, " +
					COL_NAME + " string not null, " +
					COL_GCP + " string, " +
					COL_TIME + " string not null);";
	private static final String CREATE_TABLE_LINKS = 
			"CREATE TABLE " + TABLE_LINKS + " (" +
					COL_EVIDENCE_ID + " integer, " +
					COL_NAME + " string, " +
					COL_URL + " string not null);";
	private static final String CREATE_TABLE_FEEDS =
			"CREATE TABLE " + TABLE_FEEDS + " (" +
					COL_ID + " integer primary key autoincrement, " +
					COL_NAME + " string, " +
					COL_URL + " string not null, " +
					COL_MD5 + " string);";
	private static final String CREATE_TABLE_XML =
			"CREATE TABLE " + TABLE_XML + " (" +
					COL_ID + " integer primary key autoincrement, " +
					COL_NAME + " string, " +
					COL_URL + " string not null, " +
					COL_MD5 + " string);";
	
	private static final String[] LIST_OF_TABLES = new String[]{
		CREATE_TABLE_EVIDENCE,
		CREATE_TABLE_COMPANYINFO,
		CREATE_TABLE_EVIDENCE_COMP,
		CREATE_TABLE_CATEGORY,
		CREATE_TABLE_EVIDENCE_CATS,
		CREATE_TABLE_GCP,
		CREATE_TABLE_HISTORY,
		CREATE_TABLE_LINKS,
		CREATE_TABLE_FEEDS,
		CREATE_TABLE_XML
	};
	
	private static final String[] LIST_OF_CATS = new String[]{
		"Animals",
		"Business Ethics",
		"Environment",
		"Human Rights",
		"Politics",
		"Technology",
		"Other"
	};
	public static final int CAT_OTHER_ID = LIST_OF_CATS.length;
	
	
	
	Context mContext;
	public BLeafDbHelper(Context pContext){
		super(pContext, DATABASE_NAME, null, DATABASE_VERSION);
		mContext = pContext;
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		for(int i = 0; i < LIST_OF_TABLES.length; i++){
			db.execSQL(LIST_OF_TABLES[i]);
		}
		
		
		for(int i = 0; i < LIST_OF_CATS.length; i++){
			db.execSQL("INSERT INTO " + TABLE_CATEGORY + " (" + COL_NAME + "," + COL_RATING + ") VALUES ('" + LIST_OF_CATS[i] + "', 5)");
		}
		
		db.execSQL("INSERT INTO " + TABLE_FEEDS + " (" + COL_URL + ") VALUES ('" + DEFAULT_FEED + "')");
		
//		try{
//			copyDataBase();
//		} catch(Exception e){
//			e.printStackTrace();
//			createNewDb(db);
//		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		for(int i = 0; i < LIST_OF_TABLES.length; i++){
			String t = LIST_OF_TABLES[i].substring(13,LIST_OF_TABLES[i].length());
			t = t.split(" ")[0];
			db.execSQL("DROP TABLE IF EXISTS " + t);
		}
		this.onCreate(db);
	}
	
	@SuppressWarnings("unused")
	private void createNewDb(SQLiteDatabase db){
		for(int i = 0; i < LIST_OF_TABLES.length; i++){
			db.execSQL(LIST_OF_TABLES[i]);
		}
		
		
		for(int i = 0; i < LIST_OF_CATS.length; i++){
			db.execSQL("INSERT INTO " + TABLE_CATEGORY + " (" + COL_NAME + "," + COL_RATING + ") VALUES ('" + LIST_OF_CATS[i] + "', 5)");
		}
		
		db.execSQL("INSERT INTO " + TABLE_FEEDS + " (" + COL_URL + ") VALUES ('" + DEFAULT_FEED + "')");
		
	}
	 
	  /**
	     * Creates a empty database on the system and rewrites it with your own database.
	     * */
	    public void createDataBase() throws IOException{
	 
	    	boolean dbExist = checkDataBase();
	 
	    	if(dbExist){
	    		//do nothing - database already exist
	    	}else{
	 
	    		//By calling this method and empty database will be created into the default system path
	               //of your application so we are gonna be able to overwrite that database with our database.
	        	this.getReadableDatabase();
	 
	        	try {
	 
	    			copyDataBase();
	 
	    		} catch (IOException e) {
	    			
	        	}
	    	}
	 
	    }
	 
	    /**
	     * Check if the database already exist to avoid re-copying the file each time you open the application.
	     * @return true if it exists, false if it doesn't
	     */
	    private boolean checkDataBase(){
	 
	    	SQLiteDatabase checkDB = null;
	 
	    	try{
	    		String myPath = DB_PATH + DATABASE_NAME;
	    		checkDB = SQLiteDatabase.openDatabase(myPath, null, SQLiteDatabase.OPEN_READONLY);
	 
	    	}catch(SQLiteException e){
	 
	    		//database does't exist yet.
	 
	    	}
	 
	    	if(checkDB != null){
	 
	    		checkDB.close();
	 
	    	}
	 
	    	return checkDB != null ? true : false;
	    }
	 
	    /**
	     * Copies your database from your local assets-folder to the just created empty database in the
	     * system folder, from where it can be accessed and handled.
	     * This is done by transfering bytestream.
	     * */
	    private void copyDataBase() throws IOException{
	 
	    	//Open your local db as the input stream
	    	InputStream myInput = mContext.getAssets().open(DATABASE_NAME);
	 
	    	// Path to the just created empty db
	    	String outFileName = DB_PATH + DATABASE_NAME;
	 
	    	//Open the empty db as the output stream
	    	OutputStream myOutput = new FileOutputStream(outFileName);
	 
	    	//transfer bytes from the inputfile to the outputfile
	    	byte[] buffer = new byte[1024];
	    	int length;
	    	while ((length = myInput.read(buffer))>0){
	    		myOutput.write(buffer, 0, length);
	    	}
	 
	    	//Close the streams
	    	myOutput.flush();
	    	myOutput.close();
	    	myInput.close();
	 
	    }

}
