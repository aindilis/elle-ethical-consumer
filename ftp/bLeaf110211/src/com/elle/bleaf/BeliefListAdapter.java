package com.elle.bleaf;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Color;
import android.net.Uri;
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
	HashMap<String, Integer> catscores;
	
	public BeliefListAdapter(Context pContext, ArrayList<String> groups,
            ArrayList<ArrayList<Evidence>> children) {
        this.mContext = pContext;
        this.groups = groups;
        this.children = children;
        catratings = new HashMap<String, Float>();
        catscores = new HashMap<String, Integer>();
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
//				Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
//				String term = evidence.link;
//				intent.putExtra(SearchManager.QUERY, term);
//				mContext.startActivity(intent);

				String url = evidence.link;
				if (!url.startsWith("http://") && !url.startsWith("https://"))
					   url = "http://" + url;
				
				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
				mContext.startActivity(browserIntent);
				
//				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(evidence.link));
//				mContext.startActivity(browserIntent);
				
//				String url = "http://www.example.com";
//				Intent i = new Intent(Intent.ACTION_VIEW);
//				i.setData(Uri.parse(evidence.link));
//				mContext.startActivity(i);
			}
        });
        b = (Button) convertView.findViewById(R.id.childlinkbutton);
        b.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				BLeafDbAdapter db = new BLeafDbAdapter(mContext);
	    		Cursor c = db.getLinks(evidence.id);
	    		c.moveToFirst();
	    		String[] names = new String[c.getCount()];
	    		final String[] links = new String[names.length];
	    		while(!c.isAfterLast()){
	    			String n = c.getString(c.getColumnIndex(BLeafDbHelper.COL_NAME));
	    			String l = c.getString(c.getColumnIndex(BLeafDbHelper.COL_URL));
	    			if(n != null && !n.equalsIgnoreCase(""))
	    				names[c.getPosition()] = n;
	    			else
	    				names[c.getPosition()] = l;
	    			links[c.getPosition()] = l;
	    			c.moveToNext();
	    		}
	    		
	    		new AlertDialog.Builder(mContext)
	    		.setTitle("Additional Links")
	    		.setItems(names, new DialogInterface.OnClickListener(){
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String url = links[which];
						if (!url.startsWith("http://") && !url.startsWith("https://"))
							   url = "http://" + url;
						
						Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
						mContext.startActivity(browserIntent);
					}
	    		}).show();
			}
		});
        
        b = (Button) convertView.findViewById(R.id.childsharebutton);
        b.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
	    		BLeafFacebook.share(mContext, evidence.title, evidence.description + "\n" + evidence.link);
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
//        tv = (TextView) convertView.findViewById(R.id.grouprating);
        int sum = 0;
        Iterator<Evidence> i = children.get(groupPosition).iterator();
        while(i.hasNext())
        	sum += i.next().score;
//        tv.setText("" + sum);
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
//        this.notifyDataSetChanged();
    }
	
	public void sortGroups(){
		Collections.sort(groups, new Comparator<String>(){
			@Override
			public int compare(String object1, String object2) {
				return (int) Math.signum(catratings.get(object2) - catratings.get(object1));
			}
		});
		
//		Iterator<String> i = groups.iterator();
//		while(i.hasNext()){
//			String group = i.next();
//			
//		}
    	this.notifyDataSetChanged();
	}

	public Loader<Cursor> onCreateLoader(int arg0, Bundle arg1) {
		String company = arg1.getString("company");
		String mode = arg1.getString("mode");
		System.out.println("Result mode: " + mode);
		System.out.println("Searching for: " + company);
		
		String where = "company_info.name=? " +
				"AND company_info._id = evidence_companies.company_id " +
				"AND evidence._id = evidence_companies.evidence_id " +
				"AND evidence._id = evidence_categories.evidence_id " +
				"AND categories._id = evidence_categories.category_id " +
				"AND categories.rating > 0";
		String[] projection = new String[]{
				"evidence._id",
				"evidence.title",
				"evidence.description",
				"evidence.source",
				"evidence.link",
				"categories.name",
				"categories.rating",
				"evidence_companies.score"
		};
		System.out.println(where);
		CursorLoader loader = new CursorLoader(mContext, BLeafDbAdapter.CONTENT_URI_NAME_LOOKUP,  projection, 
				where, new String[]{company}, null);
//		CursorLoader loader = new CursorLoader(mContext, BLeafDbAdapter.CONTENT_URI_BASE,  null, 
//				BLeafDbAdapter.COL_COMPANY + "='" + company + "'", null, null);
		return loader;
	}


	public void onLoadFinished(Loader<Cursor> arg0, Cursor c) {
		if(c == null)
			System.out.println("aw poop.");
		int pos = 0;
		int neg = 0;
		@SuppressWarnings("unused")
		int zero = 0;
		int count = 0;
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
    		count++;
    		if(e.score > 0)
    			pos++;
    		else if(e.score < 0)
    			neg++;
    		else
    			zero++;
    	}
    	sortGroups();
    	
    	int totalscore = pos - neg;
    	final int totaltext;
    	final int textcolor;
    	
    	if(count == 0){
    		totaltext = R.string.rating_none;
    		textcolor = Color.BLACK;
    	} else if(totalscore > 0){
    		totaltext = R.string.rating_positive;
    		textcolor = Color.rgb(0, 153, 0);
    	} else if(totalscore < 0){
    		totaltext = R.string.rating_negative;
    	    textcolor = Color.rgb(153, 0, 0);
    	}else{
    		totaltext = R.string.rating_neutral;
    		textcolor = Color.rgb(204, 153, 17);
    	}
    	
    	final ProgressBar p = (ProgressBar) ((Activity) mContext).findViewById(R.id.result_load);
    	final TextView tv = (TextView) ((Activity)mContext).findViewById(R.id.buy);
    	((Activity) mContext).runOnUiThread(new Runnable(){

			@Override
			public void run() {
				p.setVisibility(View.GONE);
				tv.setText(totaltext);
				tv.setTextColor(textcolor);
			}
    		
    	});
	}


	public void onLoaderReset(Loader<Cursor> arg0) {
		// TODO Auto-generated method stub
		
	}

}
