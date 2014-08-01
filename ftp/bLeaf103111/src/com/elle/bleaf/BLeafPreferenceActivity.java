package com.elle.bleaf;
import java.net.MalformedURLException;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceClickListener;
import android.preference.PreferenceActivity;
import android.view.MenuItem;


public class BLeafPreferenceActivity extends PreferenceActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Load the preferences from an XML resource
        addPreferencesFromResource(R.xml.preferences);
        
        Preference pref;
        
        pref = (Preference) findPreference("rate_categories");
        pref.setOnPreferenceClickListener(new OnPreferenceClickListener() {
                public boolean onPreferenceClick(Preference preference) {
    				Intent myIntent = new Intent(BLeafPreferenceActivity.this, BeliefRatingActivity.class);
    				startActivity(myIntent);
                    return true;
                }
        });
        
        pref = (Preference) findPreference("test_feeds");
        pref.setOnPreferenceClickListener(new OnPreferenceClickListener() {
                public boolean onPreferenceClick(Preference preference) {
                	BLeafDbAdapter db = new BLeafDbAdapter(BLeafPreferenceActivity.this);
                	Cursor c = db.getFeeds();
                	c.moveToFirst();
                	while(!c.isAfterLast()){
                		String url = c.getString(c.getColumnIndex(BLeafDbHelper.COL_URL));
                		String md5 = c.getString(c.getColumnIndex(BLeafDbHelper.COL_MD5));
                		Boolean b = true;
                		try {
							b = BLeafParser.checkFeed(url, md5);
						} catch (MalformedURLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
                		if(!b){
                			BLeafParser.getFeed(BLeafPreferenceActivity.this, url);
                		}
                		c.moveToNext();
                	}
                	
                	
                	
                	
//    				try {
//						BLeafParser.checkFeed("http://www.elleconnect.com/andrewdo/bleaf/sample11.rss", "");
//					} catch (MalformedURLException e) {
//						System.out.println("Bad URL!");
//						e.printStackTrace();
//					}
                    return true;
                }
        });
        
        pref = (Preference) findPreference("manage_feeds");
        pref.setOnPreferenceClickListener(new OnPreferenceClickListener() {
                public boolean onPreferenceClick(Preference preference) {
    				Intent myIntent = new Intent(BLeafPreferenceActivity.this, BLeafFeedActivity.class);
    				startActivity(myIntent);
                    return true;
                }
        });
        
        pref = (Preference) findPreference("load_feed");
        pref.setOnPreferenceClickListener(new OnPreferenceClickListener() {
                public boolean onPreferenceClick(Preference preference) {
    				BLeafParser.getFeeds(BLeafPreferenceActivity.this);
                    return true;
                }
        });
        
        pref = (Preference) findPreference("nuke");
        pref.setOnPreferenceClickListener(new OnPreferenceClickListener() {
                public boolean onPreferenceClick(Preference preference) {
		    		new AlertDialog.Builder(BLeafPreferenceActivity.this)
		    			.setTitle("Nuke all data")
			    	    .setMessage("Cannot be undone.  Are you sure you want to continue?")
			    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {
			    	    	  BLeafDbAdapter db = new BLeafDbAdapter(BLeafPreferenceActivity.this);
			    				db.open();
			    				db.nukeDatabase();
			    				db.close();
			    	      }
			    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
			    	      public void onClick(DialogInterface dialogInterface, int i) {}
			    	    }).show();
                	
                    return true;
                }
        });
    }
    
    public static boolean onOptionSelected(final Context context, MenuItem item){
    	Intent intent;
    	switch (item.getItemId()) {
	    case R.id.settings:
			intent = new Intent(context, BLeafPreferenceActivity.class);
			context.startActivity(intent);
	        return true;
	    case R.id.history:
			intent = new Intent(context, BLeafHistoryActivity.class);
			context.startActivity(intent);
	    	return true;
	    case R.id.help:
        	new AlertDialog.Builder(context)
			.setTitle("Help")
    	    .setMessage("First press scan and follow the prompt to download Zxing (if you do not " +
    	    		"already have it installed). Scan a product UPC and the results will show up. " +
    	    		"The results are based on your ranking of “beliefs” as prompted when you first " +
    	    		"installed the application. If you wish to change your belief rankings press the " +
    	    		"“Options” button on the main menu and then press “Set Categories.” The window " +
    	    		"will pop-up and you will be able to re-rank your existing beliefs. If you have " +
    	    		"additional questions that are not answers please contact us at our website: " +
    	    		"www.elleconnect.com")
    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	    		public void onClick(DialogInterface dialogInterface, int i) {
	    		}
    	    }).show();
	        return true;
	    case R.id.about:
        	new AlertDialog.Builder(context)
			.setTitle("Help")
    	    .setMessage("elle is awesome!")
    	    .setPositiveButton("Go to Website", new DialogInterface.OnClickListener(){
				@Override
				public void onClick(DialogInterface arg0, int arg1) {
					Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.elleconnect.com"));
					context.startActivity(browserIntent);
				}
    	    })
    	    .setNegativeButton("Ok", new DialogInterface.OnClickListener() {
	    		public void onClick(DialogInterface dialogInterface, int i) {
	    		}
    	    }).show();
        	return true;
	    default:
//	        return super.onOptionsItemSelected(item);
	        return false;
	    }
    }
}
