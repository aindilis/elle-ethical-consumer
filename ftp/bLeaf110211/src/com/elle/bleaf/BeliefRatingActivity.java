package com.elle.bleaf;

import java.util.ArrayList;
import java.util.Iterator;

import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RatingBar;
import android.widget.RatingBar.OnRatingBarChangeListener;
import android.widget.TextView;

public class BeliefRatingActivity extends FragmentActivity implements LoaderManager.LoaderCallbacks<Cursor> {
	ArrayList<Belief> beliefs;
	ListView lv;
	BeliefRatingAdapter mAdapter;
	Button done, cancel;
	Boolean loaded = false;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.belief_rating);

        beliefs = new ArrayList<Belief>();
        
        lv = (ListView) findViewById(R.id.rating_listview);
        mAdapter = new BeliefRatingAdapter(this, beliefs);
        lv.setAdapter(mAdapter);
        
        lv.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, final int arg2,
					long arg3) {
				System.out.println("Item selected.");
				final Belief b = (Belief)lv.getItemAtPosition(arg2);
				final RatingBar rb = new RatingBar(BeliefRatingActivity.this);
				rb.setRating(b.rating);
				new AlertDialog.Builder(BeliefRatingActivity.this)
					.setTitle("Set rating for " + b.name)
					.setView(rb)
					.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialogInterface, int i) {
						b.rating = rb.getRating();
				        mAdapter.notifyDataSetChanged();
					}
					}).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
					  public void onClick(DialogInterface dialogInterface, int i) {
					  	
					  }
					}).show();
			}
        });
        
        done = (Button) findViewById(R.id.rating_ok);
        cancel = (Button) findViewById(R.id.rating_cancel);
        
        cancel.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				finish();
			}
        });
        
        done.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				if(loaded){
					Iterator<Belief> i = beliefs.iterator();
					Belief b;
					BLeafDbAdapter db = new BLeafDbAdapter(BeliefRatingActivity.this);
					ContentValues values;
					while(i.hasNext()){
						b = i.next();
						values = new ContentValues();
						values.put(BLeafDbHelper.COL_RATING, b.rating);
						db.updateStuff(BLeafDbHelper.TABLE_CATEGORY, values, BLeafDbHelper.COL_NAME + " = '" + b.name + "'", null);
					}
				}
				finish();
			}
        });
    	getSupportLoaderManager().initLoader(0, null, this);
	}
	
	private class BeliefRatingAdapter extends BaseAdapter{
		ArrayList<Belief> mBeliefs;
		Context mContext;
		
		public BeliefRatingAdapter(Context pContext, ArrayList<Belief> pList){
			mBeliefs = pList;
			mContext = pContext;
		}
		
		@Override
		public int getCount() {
			return mBeliefs.size();
		}

		@Override
		public Object getItem(int arg0) {
			return mBeliefs.get(arg0);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
	        if (convertView == null) {
	            LayoutInflater infalInflater = (LayoutInflater) mContext
	                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	            convertView = infalInflater.inflate(R.layout.rating_child, null);
	        }
	        TextView tv = (TextView) convertView.findViewById(R.id.rating_name);
	        tv.setText(((Belief)getItem(position)).name);
	        RatingBar rb = (RatingBar) convertView.findViewById(R.id.rating_star);
	        rb.setRating(((Belief)getItem(position)).rating);
	        final int p = position;
	        rb.setOnRatingBarChangeListener(new OnRatingBarChangeListener(){
				@Override
				public void onRatingChanged(RatingBar arg0, float arg1,
						boolean arg2) {
					if(arg2){
						((Belief)getItem(p)).rating = arg1;
					}
				}
	        });
	        return convertView;
		}
		
	}
	
	private class Belief{
		public String name;
		public float rating;
		@SuppressWarnings("unused")
		public int icon;
	}

	@Override
	public Loader<Cursor> onCreateLoader(int arg0, Bundle arg1) {
		CursorLoader loader = new CursorLoader(this, Uri.withAppendedPath(BLeafDbAdapter.CONTENT_URI, BLeafDbHelper.TABLE_CATEGORY), null, null, null, null);
		return loader;
	}

	@Override
	public void onLoadFinished(Loader<Cursor> loader, Cursor c) {
        Belief b;
        c.moveToFirst();
        System.out.println("Categories found: " + c.getCount());
        while(!c.isAfterLast()){
        	b = new Belief();
        	b.name = c.getString(c.getColumnIndex(BLeafDbHelper.COL_NAME));
        	b.rating = c.getFloat(c.getColumnIndex(BLeafDbHelper.COL_RATING));
        	
        	beliefs.add(b);
        	c.moveToNext();
        }
        mAdapter.notifyDataSetChanged();
        loaded = true;
	}

	@Override
	public void onLoaderReset(Loader<Cursor> arg0) {
		// TODO Auto-generated method stub
		
	}
}
