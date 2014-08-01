package com.elle.bleaf;

import java.net.MalformedURLException;
import java.net.URL;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.widget.SimpleCursorAdapter;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

public class BLeafFeedActivity extends Activity {
	Button done, add, scan;
	ListView feedlist;
	BLeafDbAdapter db;
	SimpleCursorAdapter mAdapter;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feeds);
        db = new BLeafDbAdapter(this);
		
		done = (Button) findViewById(R.id.feed_ok);
		add = (Button) findViewById(R.id.feed_add);
		scan = (Button) findViewById(R.id.feed_scan);
		
		feedlist = (ListView) findViewById(R.id.feed_listview);
        mAdapter = new SimpleCursorAdapter(this, R.layout.search_child, null, new String[]{"url"}, new int[]{R.id.search_name}, 0);
    	feedlist.setAdapter(mAdapter);
    	feedlist.setOnItemClickListener(new OnItemClickListener(){
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, final int arg2,
					long arg3) {
	    		new AlertDialog.Builder(BLeafFeedActivity.this)
    			.setTitle("Remove Feed?")
	    	    .setMessage("Would you like to stop receiving updates from this feed?")
	    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	    	      public void onClick(DialogInterface dialogInterface, int i) {
	    	    	  Cursor c = (Cursor) mAdapter.getItem(arg2);
	    	    	  String where = "url=?";
	    	    	  String[] arg = new String[]{c.getString(c.getColumnIndex(BLeafDbHelper.COL_URL))};
	    	    	  db.deleteStuff(BLeafDbHelper.TABLE_FEEDS, where, arg);
	    	    	  updateAdapter();
	    	      }
	    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
	    	      public void onClick(DialogInterface dialogInterface, int i) {}
	    	    }).show();
			}
    	});
		this.updateAdapter();
		done.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				finish();
			}
		});
		
		add.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				addFeed("");
			}
		});
		
		scan.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
		    	Intent intent = new Intent("com.google.zxing.client.android.SCAN");
		    	intent.putExtra("SCAN_MODE", "QR_CODE_MODE");
		    	try{
		    		startActivityForResult(intent, 3553);
		    	}catch(ActivityNotFoundException e){
		    		new AlertDialog.Builder(BLeafFeedActivity.this)
		    			.setTitle("Install Barcode Scanner?")
			    	    .setMessage("bLeaf requires barcode scanner to scan products.  Would you like to install it now?")
			    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {
			    	        Uri uri = Uri.parse("market://search?q=pname:com.google.zxing.client.android");
			    	        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			    	        BLeafFeedActivity.this.startActivity(intent);
			    	      }
			    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {}
			    	    }).show();
		    	}
			}
		});
	}
	
	private void addFeed(final String pUrl){
		final EditText et = new EditText(this);
		et.setText(pUrl);
		new AlertDialog.Builder(BLeafFeedActivity.this)
		.setTitle("Add feed URL")
	    .setView(et)
	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	      public void onClick(DialogInterface dialogInterface, int i) {
	    	  String s = et.getText().toString();
	    	  try {
				new URL(s);
			} catch (MalformedURLException e) {
				new AlertDialog.Builder(BLeafFeedActivity.this)
					.setTitle("Invalid URL")
					.setMessage("Sources must come from web pages or RSS feeds.")
					.setNeutralButton("Ok", null)
					.show();
				return;
			}
	    	  ContentValues v = new ContentValues();
	    	  v.put(BLeafDbHelper.COL_URL, s);
	    	  db.insertStuff(BLeafDbHelper.TABLE_FEEDS, v);
	    	  updateAdapter();
	      }
	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
	      public void onClick(DialogInterface dialogInterface, int i) {}
	    }).show();
		
	}
	
	private void updateAdapter(){
		Cursor c = db.getFeeds();
		mAdapter.changeCursor(c);
		mAdapter.notifyDataSetChanged();
	}
	
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
	    switch (requestCode) {
	    case 3553:
	        if (resultCode == RESULT_OK) {
	            String contents = intent.getStringExtra("SCAN_RESULT");
	            // Handle successful scan
	            addFeed(contents);
	        } else if (resultCode == RESULT_CANCELED) {
	            // Handle cancel
	        }
	        break;
	    }
	}
}
