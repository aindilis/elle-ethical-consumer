package com.elle.bleaf;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;

public class BLeafProvider extends ContentProvider {
	
	public static final String AUTHORITY = "com.elle.bleaf.BLeafProvider";
	private BLeafDbHelper dbHelper;
	
	
	
//	private static UriMatcher sUriMatcher = new UriMatcher(UriMatcher.NO_MATCH);

	@Override
	public int delete(Uri pUri, String pWhere, String[] pWhereargs) {
		if (!pUri.getAuthority().equals(AUTHORITY)){
			throw new IllegalArgumentException("Unknown URI " + pUri);
		}
		
		SQLiteDatabase db  = dbHelper.getWritableDatabase();
		int count;
		
		
		count = db.delete(pUri.getLastPathSegment(), pWhere, pWhereargs);
		return count;
	}

	@Override
	public String getType(Uri uri) {
		// TODO lolwut
		return null;
	}

	@Override
	public Uri insert(Uri pUri, ContentValues initialValues) {
		if (!pUri.getAuthority().equals(AUTHORITY)){
			throw new IllegalArgumentException("Unknown URI " + pUri);
		}
		
		ContentValues values;
        if (initialValues != null) {
            values = new ContentValues(initialValues);
        } else {
            values = new ContentValues();
        }
        
        SQLiteDatabase db = dbHelper.getWritableDatabase();
	    long rowId = db.insert(pUri.getLastPathSegment(), null, values);
	    if (rowId > 0) {
	        Uri resultUri = ContentUris.withAppendedId(BLeafDbAdapter.CONTENT_URI, rowId);
	        getContext().getContentResolver().notifyChange(resultUri, null);
	        return resultUri;
	    }
	    throw new SQLException("Failed to insert row into " + pUri);
	}

	@Override
	public boolean onCreate() {
		dbHelper = new BLeafDbHelper(getContext());
		return false;
	}

	@Override
	public Cursor query(Uri pUri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		if (!pUri.getAuthority().equals(AUTHORITY)){
			throw new IllegalArgumentException("Unknown URI " + pUri);
		}
		String mode = pUri.getLastPathSegment();
		Cursor c;
		SQLiteDatabase db = dbHelper.getWritableDatabase();
		
		if(mode.equalsIgnoreCase(BLeafDbAdapter.GCP_LOOKUP) || mode.equalsIgnoreCase(BLeafDbAdapter.NAME_LOOKUP)){
			SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
			if(mode.equalsIgnoreCase(BLeafDbAdapter.GCP_LOOKUP))
				qb.setTables("company_info, gcp");
			else
				qb.setTables("company_info, categories, evidence, evidence_categories, evidence_companies");
			
	//		Cursor c = db.query(true, pUri.getLastPathSegment(), projection, selection, selectionArgs, null, null, sortOrder, null);
			c = qb.query(db, projection, selection, selectionArgs, null, null, sortOrder, null);
			c.setNotificationUri(getContext().getContentResolver(), pUri);
			return c;
		}
		c = db.query(true, pUri.getLastPathSegment(), projection, selection, selectionArgs, null, null, sortOrder, null);
//		System.out.println("QUERY Table: " + mode + "   Results: " + c.getCount());
		c.setNotificationUri(getContext().getContentResolver(), pUri);
		return c;
	}

	@Override
	public int update(Uri pUri, ContentValues initialValues, String selection,
			String[] selectionArgs) {
		if (!pUri.getAuthority().equals(AUTHORITY)){
			throw new IllegalArgumentException("Unknown URI " + pUri);
		}
		
		ContentValues values;
        if (initialValues != null) {
            values = new ContentValues(initialValues);
        } else {
            values = new ContentValues();
        }
        
        SQLiteDatabase db = dbHelper.getWritableDatabase();
        int count;
        count = db.update(pUri.getLastPathSegment(), values, selection, selectionArgs);
		
		return count;
	}

}
