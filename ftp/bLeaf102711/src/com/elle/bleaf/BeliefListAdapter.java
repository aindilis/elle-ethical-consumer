package com.elle.bleaf;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;

import android.app.Activity;
import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

public class BeliefListAdapter extends BaseExpandableListAdapter implements 
		LoaderManager.LoaderCallbacks<Cursor> {
	Context mContext;
	ArrayList<String> groups;
	ArrayList<ArrayList<Evidence>> children;
	HashMap<String, Float> catratings;
	
	public BeliefListAdapter(Context pContext, ArrayList<String> groups,
            ArrayList<ArrayList<Evidence>> children) {
        this.mContext = pContext;
        this.groups = groups;
        this.children = children;
        catratings = new HashMap<String, Float>();
    }


	public Object getChild(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return children.get(arg0).get(arg1);
	}

	public long getChildId(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return arg1;
	}

	public View getChildView(int groupPosition, int childPosition, boolean isLastChild,
            View convertView, ViewGroup parent) {
		final Evidence evidence = (Evidence) getChild(groupPosition, childPosition);
        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) mContext
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.child_layout, null);
        }
        TextView tv;
        tv = (TextView) convertView.findViewById(R.id.childtitle);
        tv.setText("- " + evidence.title);
        tv = (TextView) convertView.findViewById(R.id.childdescription);
        tv.setText(evidence.description);
        tv = (TextView) convertView.findViewById(R.id.childsource);
        tv.setText("Source: " + evidence.source);
        ImageView iv = (ImageView) convertView.findViewById(R.id.childscore);
        if(evidence.score > 0){
        	iv.setImageResource(R.drawable.greenlight);
        }else if(evidence.score < 0){
        	iv.setImageResource(R.drawable.redlight);
        }else{
        	iv.setImageResource(R.drawable.yellowlight);
        }
        Button b = (Button) convertView.findViewById(R.id.childsourcebutton);
        b.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
				String term = evidence.link;
				intent.putExtra(SearchManager.QUERY, term);
				mContext.startActivity(intent);
				
//				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(evidence.link));
//				mContext.startActivity(browserIntent);
				
//				String url = "http://www.example.com";
//				Intent i = new Intent(Intent.ACTION_VIEW);
//				i.setData(Uri.parse(evidence.link));
//				mContext.startActivity(i);
			}
        });
        LinearLayout ll = (LinearLayout) convertView.findViewById(R.id.childexpandlayout);
        ll.setVisibility(evidence.getVisibility());
        return convertView;
    }

	public int getChildrenCount(int arg0) {
		// TODO Auto-generated method stub
		return children.get(arg0).size();
	}

	public Object getGroup(int arg0) {
		// TODO Auto-generated method stub
		return groups.get(arg0);
	}

	public int getGroupCount() {
		// TODO Auto-generated method stub
		return groups.size();
	}

	public long getGroupId(int arg0) {
		// TODO Auto-generated method stub
		return arg0;
	}

	public View getGroupView(int groupPosition, boolean isExpanded, View convertView,
            ViewGroup parent) {
        String belief = (String) getGroup(groupPosition);
        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) mContext
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.group_layout, null);
        }
        TextView tv = (TextView) convertView.findViewById(R.id.grouptext);
        tv.setText(belief);
        tv = (TextView) convertView.findViewById(R.id.grouprating);
        int sum = 0;
        Iterator<Evidence> i = children.get(groupPosition).iterator();
        while(i.hasNext())
        	sum += i.next().score;
        tv.setText("" + sum);
        LinearLayout iv = (LinearLayout) convertView.findViewById(R.id.groupbackground);
        if(sum > 0){
        	iv.setBackgroundResource(R.drawable.bargreennine);
        }else if(sum < 0){
        	iv.setBackgroundResource(R.drawable.barrednine);
        }else{
        	iv.setBackgroundResource(R.drawable.baryellow);
        }
        return convertView;
    }

	public boolean hasStableIds() {
		// TODO Auto-generated method stub
		return false;
	}

	public boolean isChildSelectable(int groupPosition, int childPosition) {
		// TODO Auto-generated method stub
		return true;
	}
	
	public void addItem(Evidence pEvidence) {
        if (!groups.contains(pEvidence.category)) {
            groups.add(pEvidence.category);
            catratings.put(pEvidence.category, pEvidence.catrating);
        }
        int index = groups.indexOf(pEvidence.category);
        if (children.size() < index + 1) {
            children.add(new ArrayList<Evidence>());
        }
        children.get(index).add(pEvidence);
        this.notifyDataSetChanged();
    }
	
	public void sortGroups(){
		Collections.sort(groups, new Comparator<String>(){
			@Override
			public int compare(String object1, String object2) {
				return (int) Math.signum(catratings.get(object2) - catratings.get(object1));
			}
		});
    	this.notifyDataSetChanged();
	}

	public Loader<Cursor> onCreateLoader(int arg0, Bundle arg1) {
		String company = arg1.getString("company");
		String mode = arg1.getString("mode");
		System.out.println("Result mode: " + mode);
		System.out.println("Searching for: " + company);
		String sql = "SELECT comapny_info.name, categories.name, evidence.description" +
				"FROM company_info, categories, evidence" +
				"WHERE company_info.name=? " +
				"AND company_info._id = evidence.company_id " +
				"AND categories._id = evidence.category_id";
		
		
//		"company_info.name= '" + company + "' " +
		
		String where = (mode.equalsIgnoreCase(ResultActivity.MODE_GCP) ? "gcp.gcp=? AND gcp.company_id = company_info._id " : "company_info.name=? ") +
				"AND company_info._id = evidence_companies.company_id " +
				"AND evidence._id = evidence_companies.evidence_id " +
				"AND evidence._id = evidence_categories.evidence_id " +
				"AND categories._id = evidence_categories.category_id " +
				"AND categories.rating > 0";
		System.out.println(where);
		CursorLoader loader = new CursorLoader(mContext, (mode.equalsIgnoreCase(ResultActivity.MODE_GCP) ? BLeafDbAdapter.CONTENT_URI_GCP_LOOKUP : BLeafDbAdapter.CONTENT_URI_NAME_LOOKUP),  null, 
				where, new String[]{company}, null);
//		CursorLoader loader = new CursorLoader(mContext, BLeafDbAdapter.CONTENT_URI_BASE,  null, 
//				BLeafDbAdapter.COL_COMPANY + "='" + company + "'", null, null);
		return loader;
	}


	public void onLoadFinished(Loader<Cursor> arg0, Cursor c) {
		if(c == null)
			System.out.println("aw poop.");
		c.moveToFirst();
		System.out.println("Evidence found: " + c.getCount());
    	while(!c.isAfterLast()){
    		Evidence e = new Evidence();
    		e.id = c.getInt(c.getColumnIndex("evidence._id"));
    		e.title = c.getString(c.getColumnIndex("evidence.title"));
    		e.description = c.getString(c.getColumnIndex("evidence.description"));
    		e.source = c.getString(c.getColumnIndex("evidence.source"));
    		e.link = c.getString(c.getColumnIndex("evidence.link"));
    		e.category = c.getString(c.getColumnIndex("categories.name"));
    		e.catrating = c.getFloat(c.getColumnIndex("categories.rating"));
    		e.score = c.getInt(c.getColumnIndex("evidence_companies.score"));
    		addItem(e);
    		c.moveToNext();
    	}
    	sortGroups();
    	
    	final ProgressBar p = (ProgressBar) ((Activity) mContext).findViewById(R.id.result_load);
    	((Activity) mContext).runOnUiThread(new Runnable(){

			@Override
			public void run() {
				p.setVisibility(View.GONE);
			}
    		
    	});
	}


	public void onLoaderReset(Loader<Cursor> arg0) {
		// TODO Auto-generated method stub
		
	}

}
