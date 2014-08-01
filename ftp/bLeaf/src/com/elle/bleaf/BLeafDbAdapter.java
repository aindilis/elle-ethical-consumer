package com.elle.bleaf;

import java.util.HashMap;

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
	public final static String GCP_LOOKUP = "gcplookup";
	public final static String NAME_LOOKUP = "namelookup";
	
	public final static Uri CONTENT_URI = Uri.parse("content://" + BLeafProvider.AUTHORITY);
	public final static Uri CONTENT_URI_OLD = Uri.parse("content://" + BLeafProvider.AUTHORITY
            + "/" + TABLE_NAME);
	public final static Uri CONTENT_URI_GCP_LOOKUP = Uri.parse("content://" + BLeafProvider.AUTHORITY
            + "/" + GCP_LOOKUP);
	public final static Uri CONTENT_URI_NAME_LOOKUP = Uri.parse("content://" + BLeafProvider.AUTHORITY
            + "/" + NAME_LOOKUP);
	
	
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
	
	public int deleteStuff(String pTable, String selection, String[] selectionArgs){
		return context.getContentResolver().delete(Uri.withAppendedPath(CONTENT_URI, pTable), selection, selectionArgs);
	}
	
	public Cursor queryStuff(String pTable, String[] projection, String selection, String[] selectionArgs, String sortOrder){
		return context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, pTable), projection, selection, selectionArgs, sortOrder);
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
	
	HashMap<String, Integer> gcpMap;
	public boolean gcpMapExists(String pGcp){
		if(gcpMap == null){
			gcpMap = new HashMap<String, Integer>();
			Cursor c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_GCP), null, null, null, null);
			c.moveToFirst();
			while(!c.isAfterLast()){
				gcpMap.put(c.getString(c.getColumnIndex(BLeafDbHelper.COL_GCP)), c.getInt(c.getColumnIndex(BLeafDbHelper.COL_ID)));
				c.moveToNext();
			}
			c.close();
		}
		
		
		return gcpMap.containsKey(pGcp);
	}
	
	public Uri insertGcp(ContentValues pValues){
		Uri u = context.getContentResolver().insert(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_GCP), pValues);
		if(gcpMap != null){
			gcpMap.put((String) pValues.get(BLeafDbHelper.COL_GCP), Integer.parseInt(u.getLastPathSegment()));
		}
		
		return u;
	}
	
	HashMap<String, Integer> companyMap;
	public int getCompanyMapId(String pCompany){
		if(companyMap == null){
			System.out.println("Building company map");
			companyMap = new HashMap<String, Integer>();
			Cursor c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_COMPANYINFO), null, null, null, null);
			c.moveToFirst();
			while(!c.isAfterLast()){
				companyMap.put(c.getString(c.getColumnIndex(BLeafDbHelper.COL_NAME)), c.getInt(c.getColumnIndex(BLeafDbHelper.COL_ID)));
				c.moveToNext();
			}
			c.close();
		}
		
		return (companyMap.containsKey(pCompany) ? companyMap.get(pCompany) : -1);
	}
	
	public Uri insertCompany(ContentValues pValues){
		Uri u = context.getContentResolver().insert(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_COMPANYINFO), pValues);
		if(companyMap != null){
			companyMap.put((String) pValues.get(BLeafDbHelper.COL_NAME), Integer.parseInt(u.getLastPathSegment()));
		}
		
		return u;
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
	
	public String getCompany(String pGcp){
		Cursor c;
		String where = "gcp.gcp=? AND gcp.company_id = company_info._id";
		String[] arg = new String[]{pGcp};
		c = context.getContentResolver().query(CONTENT_URI_GCP_LOOKUP, new String[]{"company_info.name"}, where, arg, "company_info.name LIMIT 1");
		String comp;
		if(c.getCount() > 0){
			c.moveToFirst();
			comp = c.getString(c.getColumnIndex("company_info.name"));
		} else
			comp = "";
		c.close();
		return comp;
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
	
	public Cursor searchCompanies(String pCompany){
		Cursor c;
		String[] arg = new String[]{pCompany + "%"};
		String where = "name LIKE ?";
		
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_COMPANYINFO), null, where, arg, "name");
		return c;
	}
	
	public Cursor searchHistory(String pCompany){
		Cursor c;
		String[] arg = new String[]{pCompany + "%"};
		String where = "name LIKE ?";
		
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_HISTORY), null, where, arg, "time DESC");
		return c;
	}
	
	public Cursor getFeeds(){
		Cursor c;
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_FEEDS), null, null, null, null);
		return c;
	}
	
	public boolean hasScanned(String pUpc){
		Cursor c;
		String[] arg = new String[]{pUpc};
		String where = "gcp=?";
		
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_HISTORY), null, where, arg, "time DESC LIMIT 1");
		Boolean b;
		if(c.getCount() > 0)
			b = true;
		else
			b = false;
		return b;
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
	
	public Cursor getLinks(int pEid){
		Cursor c;
		String[] arg = new String[]{Integer.toString(pEid)};
		String where = BLeafDbHelper.COL_EVIDENCE_ID + "=?";
		c = context.getContentResolver().query(Uri.withAppendedPath(CONTENT_URI, BLeafDbHelper.TABLE_LINKS), new String[]{BLeafDbHelper.COL_NAME, BLeafDbHelper.COL_URL}, where, arg, null);
		
		return c;
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
