package com.elle.bleaf;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class BLeafDatabaseHelper extends SQLiteOpenHelper {
	private static final String DATABASE_NAME = "appdata";
	private static final int DATABASE_VERSION = 1;
	
	private static final String DATABASE_CREATE = "CREATE TABLE " + BLeafDbAdapter.TABLE_NAME + " (" +
			BLeafDbAdapter.COL_ID + " integer primary key autoincrement," +
			BLeafDbAdapter.COL_COMPANY + " text not null," +
			BLeafDbAdapter.COL_BELIEF + " text not null," +
			BLeafDbAdapter.COL_DESCRIPTION + " text not null);";
	
	public BLeafDatabaseHelper(Context pContext){
		super(pContext, DATABASE_NAME, null, DATABASE_VERSION);
	}
	
	@Override
	public void onCreate(SQLiteDatabase arg0) {
		arg0.execSQL(DATABASE_CREATE);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		// TODO Auto-generated method stub

	}

}
