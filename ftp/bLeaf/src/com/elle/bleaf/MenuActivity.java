package com.elle.bleaf;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;


public class MenuActivity extends Activity {
	SharedPreferences settings;
	Button result, scan, options, quit;
	
//	Facebook facebook;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        System.out.println("Starting App...");
        settings = getSharedPreferences("com.elle.bleaf_preferences", MODE_PRIVATE);
//        facebook = new Facebook("199911970077149");
//        String access_token = settings.getString("access_token", null);
//        long expires = settings.getLong("access_expires", 0);
//        if(access_token != null) {
//            facebook.setAccessToken(access_token);
//        }
//        if(expires != 0) {
//            facebook.setAccessExpires(expires);
//        }
        setContentView(R.layout.main);
        
        ConnectivityManager cm = (ConnectivityManager) this.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo ni = cm.getActiveNetworkInfo();
        
        final boolean firstrun;
        System.out.println("update interval: " + settings.getString("update_interval", "0"));
        long now = System.currentTimeMillis();
        long last_update = settings.getLong("last_update", 0);
        long update_interval = Integer.parseInt(settings.getString("update_interval", "0")) * 86400000;
        long update = update_interval + last_update;
        
        if(settings.getBoolean("is_updating", false)){
        	if(now - last_update > 21600000){
    			Editor e = settings.edit();
    			e.putBoolean("is_updating", false);
    			e.commit();
        	}
        }
        
        System.out.println("Now:         " + now);
        System.out.println("Last update: " + last_update);
        System.out.println("Next update: " + update);
        
        if(!settings.getBoolean("setup_complete", false)){
        	firstrun = true;
        	new AlertDialog.Builder(MenuActivity.this)
			.setTitle("Welcome to bLeaf!")
    	    .setMessage("It appears this is your first time using bLeaf, so we need to download all the information about the companies on which we report from our servers.  This may take several minutes.\n\nWhile this is happening, please rate the categories on importance based on your personal beliefs.")
    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	    		public void onClick(DialogInterface dialogInterface, int i) {
					Intent myIntent = new Intent(MenuActivity.this, BeliefRatingActivity.class);
					startActivity(myIntent);
	    		}
    	    }).show();
        	Editor e = settings.edit();
        	e.putBoolean("setup_complete", true);
        	e.commit();
        } else{
        	firstrun = false;
        }
        if(now > update && !settings.getBoolean("is_updating", false) && ni != null && ni.isConnected()){
        	System.out.println("Checking for feed updates...");
        	BLeafDbAdapter db = new BLeafDbAdapter(this);
        	Cursor c = db.getFeeds();
        	c.moveToFirst();
        	final String[] feeds = new String[c.getCount() * 2];
        	int i = 0;
        	while(!c.isAfterLast()){
        		feeds[i] = c.getString(c.getColumnIndex(BLeafDbHelper.COL_URL));
        		i++;
        		feeds[i] = c.getString(c.getColumnIndex(BLeafDbHelper.COL_MD5));
        		i++;
        		c.moveToNext();
        	}
        	c.close();
        	new AsyncTask<String, Void, Boolean>(){
				@Override
				protected Boolean doInBackground(String... params) {
					boolean result = false;
					for(int i = 0; i < params.length; i+=2){
						try {
							if(!BLeafParser.checkFeed(params[i], params[i+1]))
								result = true;
						} catch (Exception e) {
							e.printStackTrace();
						}
					}
					return result;
				}
				
				@Override
				protected void onPostExecute(Boolean update){
					if(firstrun){
						new BLeafUpdateTask().execute(feeds);
	    				Editor e = settings.edit();
	    				e.putLong("last_update", System.currentTimeMillis());
	    				e.commit();
					} else if(update){
						new AlertDialog.Builder(MenuActivity.this)
		    			.setTitle("Feed updates found")
			    	    .setMessage("Feed updates found.  Would you like to download updates now?")
			    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {
			    	    	  new BLeafUpdateTask().execute(feeds);
			    				Editor e = settings.edit();
			    				e.putLong("last_update", System.currentTimeMillis());
			    				e.commit();
			    	      }
			    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {}
			    	    }).show();
					}
				}
        	}.execute(feeds);
        }
        
        
//        BLeafFacebook.setup(MenuActivity.this);
		
        
        result = (Button) findViewById(R.id.buttonresult);
        result.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				Intent myIntent = new Intent(MenuActivity.this, BLeafSearchActivity.class);
				startActivity(myIntent);
			}
        });

        options = (Button) findViewById(R.id.buttonoptions);
        options.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				Intent myIntent = new Intent(MenuActivity.this, BLeafPreferenceActivity.class);
				startActivity(myIntent);
			}
        });
        
        scan = (Button) findViewById(R.id.buttonscan);
        scan.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
		    	Intent intent = new Intent("com.google.zxing.client.android.SCAN");
		    	intent.putExtra("SCAN_MODE", "SCAN_MODE");
		    	try{
		    		startActivityForResult(intent, 3553);
		    	}catch(ActivityNotFoundException e){
		    		new AlertDialog.Builder(MenuActivity.this)
		    			.setTitle("Install Barcode Scanner?")
			    	    .setMessage("bLeaf requires barcode scanner to scan products.  Would you like to install it now?")
			    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {
			    	        Uri uri = Uri.parse("market://search?q=pname:com.google.zxing.client.android");
			    	        Intent intent = new Intent(Intent.ACTION_VIEW, uri);
			    	        MenuActivity.this.startActivity(intent);
			    	      }
			    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {}
			    	    }).show();
		    	}
			}
        });
        
        quit = (Button) findViewById(R.id.buttonquit);
        quit.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				finish();
			}
        });
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
	    MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.main_menu, menu);
	    return true;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
	    return BLeafPreferenceActivity.onOptionSelected(this, item);
	}
	
	public String grabgcp(String upc) {
    	char leading = upc.charAt(0);
    	char check = upc.charAt(7);
    	if (upc.length() == 12) {
    		String gcp = upc.substring(0, 6);
    		return gcp;
    	}
    	if (upc.length() == 13) {
    		String gcp = upc.substring(1, 7);
    		return gcp;
    	}
    	if (upc.length() == 8) {
    	String newupc = upc.substring(1, 7);
    		char first = newupc.charAt(0);
    		char second = newupc.charAt(1);
    		char third = newupc.charAt(2);
    		char fourth = newupc.charAt(3);
    		char fifth = newupc.charAt(4);
    		char last = newupc.charAt(5);
    	if (last == '0' || last == '1' || last == '2') {
    			char[] upcarray = {leading, first, second, last, '0', '0', '0', '0', third, fourth, fifth, check};
    			String upca = new String(upcarray);
    			String gcp = upca.substring(0, 6);
    			return gcp;
    	}
    	else if (last == '3') {
    		char[] upcarray = {leading, first, second, third, '0', '0', '0', '0', '0', fourth, fifth, check};
    		String upca = new String(upcarray);
    		String gcp = upca.substring(0, 6);
    		return gcp;
    	}
    	else if (last == '4') {
    		char[] upcarray = {leading, first, second, third, fourth, '0', '0', '0', '0', '0', fifth, check};
    		String upca = new String(upcarray);
    		String gcp = upca.substring(0, 6);
    		return gcp;
    		
    	}
    	else if (last == '5' || last == '6' || last == '7' || last == '8' || last == '9') {
    		char[] upcarray = {leading, first, second, third, fourth, fifth, '0', '0', '0', '0', last, check};
    		String upca = new String(upcarray);
    		String gcp = upca.substring(0, 6);
    		return gcp;
    	}
    	

    	}
		return null;
    }
	
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
	    switch (requestCode) {
	    case 3553:
	        if (resultCode == android.app.Activity.RESULT_OK) {
				Intent i = new Intent(MenuActivity.this, ResultActivity.class);
	            String upc = intent.getStringExtra("SCAN_RESULT");
	            String format = intent.getStringExtra("SCAN_RESULT_FORMAT");
	            System.out.println(upc);
	            System.out.println(format);
	            i.putExtra("upc", upc);
	            i.putExtra("fomat", format);
	            String gcp = grabgcp(upc);
	        	gcp = ("gcp" + gcp);
	        	BLeafDbAdapter db = new BLeafDbAdapter(this);
	        	String comp = db.getCompany(gcp);
	        	
				i.putExtra("company", comp);
				i.putExtra("mode", ResultActivity.MODE_NAME);
				startActivity(i);
				
				String u = "upc" + upc;
				String n = comp;
				if(comp.equalsIgnoreCase("")){
					n = u;
				}
				ContentValues v = new ContentValues();
				v.put(BLeafDbHelper.COL_NAME, n);
				v.put(BLeafDbHelper.COL_TIME, System.currentTimeMillis());
				v.put(BLeafDbHelper.COL_GCP, u);
				if(db.hasScanned(u)){
					String where = "gcp=?";
					String[] arg = new String[]{u};
					db.updateStuff(BLeafDbHelper.TABLE_HISTORY, v, where, arg);
				}else
					db.insertStuff(BLeafDbHelper.TABLE_HISTORY, v);
	        } 
	        else if (resultCode == android.app.Activity.RESULT_CANCELED) {
	            // Handle cancel
	        }
	        break;
	    case 32665:
	        BLeafFacebook.authorizeCallback(requestCode, resultCode, intent);
	    	
	    	break;
	    }
	}
    
    private class BLeafUpdateTask extends AsyncTask<String, Void, Boolean>{

		@Override
		protected Boolean doInBackground(String... params) {
			boolean result = false;
			for(int i = 0; i < params.length; i+=2){
				try {
					if(!BLeafParser.checkFeed(params[i], params[i+1])){
						BLeafParser.getFeed(MenuActivity.this, params[i]);
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return result;
		}
		
		@Override
		protected void onPreExecute(){
			Editor e = settings.edit();
			e.putBoolean("is_updating", true);
			e.commit();
		}
		
		@Override
		protected void onPostExecute(Boolean update){
			Editor e = settings.edit();
			e.putBoolean("is_updating", false);
			e.commit();
		}
    	
    }
}
