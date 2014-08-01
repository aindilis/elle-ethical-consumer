package com.elle.bleaf;

import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class BLeafDbHelper extends SQLiteOpenHelper {
	private static final String DATABASE_NAME = "appdata.db";
	private static final int DATABASE_VERSION = 7;
	
	private static final String DATABASE_CREATE = "CREATE TABLE " + BLeafDbAdapter.TABLE_NAME + " (" +
			BLeafDbAdapter.COL_ID + " integer primary key autoincrement," +
			BLeafDbAdapter.COL_COMPANY + " text not null," +
			BLeafDbAdapter.COL_BELIEF + " text not null," +
			BLeafDbAdapter.COL_DESCRIPTION + " text not null);";
	
	
	
	
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
					COL_TIME + " string not null);";
	private static final String CREATE_TABLE_LINKS = 
			"CREATE TABLE " + TABLE_LINKS + " (" +
					COL_EVIDENCE_ID + " integer, " +
					COL_NAME + " string, " +
					COL_URL + " string not null);";
	
	private static final String[] LIST_OF_TABLES = new String[]{
		CREATE_TABLE_EVIDENCE,
		CREATE_TABLE_COMPANYINFO,
		CREATE_TABLE_EVIDENCE_COMP,
		CREATE_TABLE_CATEGORY,
		CREATE_TABLE_EVIDENCE_CATS,
		CREATE_TABLE_GCP,
		CREATE_TABLE_HISTORY,
		CREATE_TABLE_LINKS
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

}
