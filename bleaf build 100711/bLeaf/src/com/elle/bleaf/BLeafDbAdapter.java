package com.elle.bleaf;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class BLeafDbAdapter {
	public static String COL_ID = "_id";
	public static String COL_COMPANY = "company";
	public static String COL_BELIEF = "belief";
	public static String COL_DESCRIPTION = "description";
	
	public static String TABLE_NAME = "evidence";
	
	
	
	Context context;
	BLeafDatabaseHelper dbHelper;
	SQLiteDatabase database;
	
	public BLeafDbAdapter(Context pContext){
		context = pContext;
	}
	
	public BLeafDbAdapter open(){
		dbHelper = new BLeafDatabaseHelper(context);
		database = dbHelper.getWritableDatabase();
		return this;
	}
	
	public void close(){
		dbHelper.close();
	}
	
	public long addEvidence(String pCompany, String pBelief, String pText){
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
	
	private ContentValues createValues(String pCompany, String pBelief, String pText){
		ContentValues values = new ContentValues();
		values.put(COL_COMPANY, pCompany);
		values.put(COL_BELIEF, pBelief);
		values.put(COL_DESCRIPTION, pText);
		return values;
	}
}
