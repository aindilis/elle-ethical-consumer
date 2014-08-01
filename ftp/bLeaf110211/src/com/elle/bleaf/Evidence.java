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
	public int score;
	public HashMap<String, Integer> scores;
	public int id;
	public ArrayList<Link> links;
	
	public Evidence(){
		categories = new ArrayList<String>();
		ratings = new ArrayList<String>();
		companies = new ArrayList<String>();
		gcps = new HashMap<String, ArrayList<String>>();
		scores = new HashMap<String, Integer>();
		links = new ArrayList<Link>();
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
	
	public void addScore(String pCompany, String pScore){
		int s = 0;
		try{
			s = Integer.parseInt(pScore);
		} catch(Exception e){
			
		}
		scores.put(pCompany, s);
	}
	
	public int getScore(String pCompany){
		return scores.get(pCompany);
	}
	
	public void addLink(String pName, String pUrl){
		links.add(new Link(pName, pUrl));
	}
	
	public ArrayList<Link> getLinks(){
		return links;
	}
	
	class Link{
		public String name, url;
		public Link(String pName, String pUrl){
			name = pName;
			url = pUrl;
		}
	}
}
