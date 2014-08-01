package com.elle.bleaf;

import java.util.ArrayList;


import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.TextView;

public class BeliefListAdapter extends BaseExpandableListAdapter {
	Context mContext;
	ArrayList<BeliefData> groups;
	ArrayList<ArrayList<EvidenceData>> children;
	
	public BeliefListAdapter(Context pContext, ArrayList<BeliefData> groups,
            ArrayList<ArrayList<EvidenceData>> children) {
        this.mContext = pContext;
        this.groups = groups;
        this.children = children;
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
		final EvidenceData evidence = (EvidenceData) getChild(groupPosition, childPosition);
        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) mContext
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.child_layout, null);
        }
        TextView tv = (TextView) convertView.findViewById(R.id.childtext);
        tv.setText("- " + evidence.getText());
        Button b = (Button) convertView.findViewById(R.id.childsourcebutton);
        b.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
				String term = evidence.getText();
				intent.putExtra(SearchManager.QUERY, term);
				mContext.startActivity(intent);
			}
        });
        b.setVisibility(evidence.getVisibility());
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
        BeliefData belief = (BeliefData) getGroup(groupPosition);
        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) mContext
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.group_layout, null);
        }
        TextView tv = (TextView) convertView.findViewById(R.id.grouptext);
        tv.setText(belief.name);
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

}
