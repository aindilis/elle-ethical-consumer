package com.elle.bleaf;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.ContentValues;
import android.view.View;

public class Evidence {
	public String title, description;
	public ArrayList<String> categories, ratings;
	public String source, link;
	public ArrayList<String> companies;
	public int visibility = View.GONE;
	public String category;
	public float catrating;
	public HashMap<String, ArrayList<String>> gcps;
	
	public Evidence(){
		categories = new ArrayList<String>();
		ratings = new ArrayList<String>();
		companies = new ArrayList<String>();
		gcps = new HashMap<String, ArrayList<String>>();
	}
	
	public ContentValues getEvidenceValues(){
		ContentValues values = new ContentValues();
		values.put(BLeafDbHelper.COL_TITLE, title);
		values.put(BLeafDbHelper.COL_DESCRIPTION, description);
		values.put(BLeafDbHelper.COL_SOURCE, source);
		values.put(BLeafDbHelper.COL_LINK, link);
		
		return values;
	}

	public int getVisibility() {
		return visibility;
	}
	
	public void setVisibility(int pVisibility){
		visibility = pVisibility;
	}
	
	public void addCompany(String pCompany){
		companies.add(pCompany);
		gcps.put(pCompany, new ArrayList<String>());
	}
	
	public void addGcp(String pCompany, String pGcp){
		gcps.get(pCompany).add("gcp" + pGcp.substring(1));
	}
	
	public ArrayList<String> getGcps(String pCompany){
		return gcps.get(pCompany);
	}
}
