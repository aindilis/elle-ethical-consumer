package com.elle.bleaf;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;

public class BLeafDbAdapter {
	public static String COL_ID = "_id";
	public static String COL_COMPANY = "company";
	public static String COL_BELIEF = "belief";
	public static String COL_DESCRIPTION = "description";
	
	public static String TABLE_NAME = "evidence";
	
//	public static String AUTHORITY = "com.elle.bleaf";
	public final static String LOOKUP = "lookup";
	
	public final static Uri CONTENT_URI = Uri.parse("content://" + BLeafProvider.AUTHORITY);
	public final static Uri CONTENT_URI_OLD = Uri.parse("content://" + BLeafProvider.AUTHORITY
            + "/" + TABLE_NAME);
	public final static Uri CONTENT_URI_LOOKUP = Uri.parse("content://" + BLeafProvider.AUTHORITY
            + "/" + LOOKUP);
	
	
	Context context;
	BLeafDbHelper dbHelper;
	SQLiteDatabase database;
	
	public BLeafDbAdapter(Context pContext){
		context = pContext;
	}
	
	public BLeafDbAdapter open(){
		dbHelper = new BLeafDbHelper(context);
		database = dbHelper.getWritableDatabase();
		return this;
	}
	
	public void close(){
		dbHelper.close();
	}
	
	public Uri insertStuff(String pTable, ContentValues pValues){
		return context.getContentResolver().insert(Uri.withAppendedPath(CONTENT_URI, pTable), pValues);
	}
	
	public int updateStuff(String pTable, ContentValues pValues, String selection, String[] selectionArgs){
		return context.getContentResolver().update(Uri.withAppendedPath(CONTENT_URI, pTable), pValues, selection, selectionArgs);
	}
	
	public Uri addEvidence(String pCompany, String pBelief, String pText){
		ContentValues values = createValues(pCompany, pBelief, pText);
		return context.getContentResolver().insert(CONTENT_URI_OLD, values);
	}
	
	public long oldaddEvidence(String pCompany, String pBelief, String pText){
		ContentValues values = createValues(pCompany, pBelief, pText);
		return database.insert(TABLE_NAME, null, values);
	}
	
	public Cursor fetchCompanyEvidence(String pCompany){
		Cursor c;
		c = database.query(true, TABLE_NAME, null, COL_COMPANY + "='" + pCompany + "'",null,null,null,null,null);
		if(c != null)
			c.moveToFirst();
		return c;
	}
	
	public boolean evidenceExists(Evidence pEvidence){
		Cursor c;
		String where = BLeafDbHelper.COL_TITLE + "='" + pEvidence.title + "' AND " +
				BLeafDbHelper.COL_DESCRIPTION + "='" + pEvidence.description + "' AND " +
				BLeafDbHelper.COL_SOURCE + "='" + pEvidence.source + "' AND " +
				BLeafDbHelper.COL_LINK + "='" + pEvidence.link + "'";
//		c = database.query(true, BLeafDbHelper.TABLE_EVIDENCE, new String[]{BLeafDbHelper.COL_ID}, where,null,null,null,null,"1");
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_EVIDENCE), new String[]{BLeafDbHelper.COL_ID}, where, null, BLeafDbHelper.COL_ID + " LIMIT 1");
		boolean b = (c.getCount() > 0);
		
		c.moveToFirst();
		c.close();
		return b;
	}
	
	public boolean gcpExists(String pGcp){
		Cursor c;
		String where = BLeafDbHelper.COL_GCP + "='" + pGcp + "'";
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_GCP), new String[]{BLeafDbHelper.COL_ID}, where, null, BLeafDbHelper.COL_ID + " LIMIT 1");
		boolean b = (c.getCount() > 0);
		
		c.moveToFirst();
		c.close();
		return b;
	}
	
	public boolean companyExists(String pCompany){
		Cursor c;
		String where = BLeafDbHelper.COL_NAME + "='" + pCompany + "'";
		c = database.query(true, BLeafDbHelper.TABLE_COMPANYINFO, new String[]{BLeafDbHelper.COL_ID}, where,null,null,null,null,"1");
		boolean b = (c.getCount() > 0);
		c.close();
		return b;
	}
	
	public int getCompanyId(String pCompany){
		Cursor c;
		String where = BLeafDbHelper.COL_NAME + "='" + pCompany + "'";
//		c = database.query(true, BLeafDbHelper.TABLE_COMPANYINFO, new String[]{BLeafDbHelper.COL_ID}, where,null,null,null,null,"1");
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_COMPANYINFO), new String[]{BLeafDbHelper.COL_ID}, where, null, BLeafDbHelper.COL_ID + " LIMIT 1");
		if(c.getCount() > 0){
			c.moveToFirst();
			return c.getInt(c.getColumnIndexOrThrow(BLeafDbHelper.COL_ID));
		}
		c.close();
		return -1;
	}
	
	public int getCategoryId(String pCategory){
		Cursor c;
		String where = BLeafDbHelper.COL_NAME + "='" + pCategory + "'";
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_CATEGORY), new String[]{BLeafDbHelper.COL_ID}, where, null, BLeafDbHelper.COL_ID + " LIMIT 1");
		if(c.getCount() > 0){
			c.moveToFirst();
			return c.getInt(c.getColumnIndexOrThrow(BLeafDbHelper.COL_ID));
		}
		c.close();
		return BLeafDbHelper.CAT_OTHER_ID;
	}
	
	private ContentValues createValues(String pCompany, String pBelief, String pText){
		ContentValues values = new ContentValues();
		values.put(COL_COMPANY, pCompany);
		values.put(COL_BELIEF, pBelief);
		values.put(COL_DESCRIPTION, pText);
		return values;
	}
	
	public void nukeDatabase(){
		dbHelper.onUpgrade(database, 0, 0);
	}
}
