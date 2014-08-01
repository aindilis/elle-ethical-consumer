package com.elle.bleaf;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
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
    
    public static boolean onOptionSelected(Context context, MenuItem item){
    	switch (item.getItemId()) {
	    case R.id.settings:
			Intent myIntent = new Intent(context, BLeafPreferenceActivity.class);
			context.startActivity(myIntent);
	        return true;
	    case R.id.history:
	    	return true;
	    case R.id.help:
	        return true;
	    default:
//	        return super.onOptionsItemSelected(item);
	        return false;
	    }
    }
}
