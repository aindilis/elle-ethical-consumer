package com.elle.bleaf;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class MenuActivity extends Activity {
	SharedPreferences settings;
	Button result, scan, options, quit;
	
//	Facebook facebook;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        System.out.println("Starting App...");
        settings = getPreferences(MODE_PRIVATE);
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
        
        
        if(!settings.getBoolean("setup_complete", false)){
        	new AlertDialog.Builder(MenuActivity.this)
			.setTitle("Setup Beliefs")
    	    .setMessage("bLeaf allows you to customize which issues you would like to receive information on.  Would you like to do so now?")
    	    .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	    		public void onClick(DialogInterface dialogInterface, int i) {
					Intent myIntent = new Intent(MenuActivity.this, BeliefRatingActivity.class);
					startActivity(myIntent);
	    		}
    	    }).setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
    	      public void onClick(DialogInterface dialogInterface, int i) {}
    	    }).show();
        	Editor e = settings.edit();
        	e.putBoolean("setup_complete", true);
        	e.commit();
        }
        
        
        BLeafFacebook.setup(MenuActivity.this);
		
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
        
        
        checkFeeds();
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
	
	public void checkFeeds(){
		
	}
	
   	static String[] belieflist = new String[]{
   		"Environmental",
   		"Worker Exploits",
   		"Ice Cream!!!"
   	};
   	
	private void createData(){
		BLeafDbAdapter dbadapter = new BLeafDbAdapter(this);
//		dbadapter.open();
        System.out.println(dbadapter.addEvidence("12345", belieflist[0], "Eats Babies"));
        dbadapter.addEvidence("12345", belieflist[0], "Uses turtles as hockey pucks");
        dbadapter.addEvidence("12345", belieflist[0], "Hates puppies");
        dbadapter.addEvidence("12345", belieflist[1], "Children work in a fire factory");
        dbadapter.addEvidence("12345", belieflist[1], "Shoots late workers");
        dbadapter.addEvidence("12345", belieflist[1], "Still Eats Babies");
        dbadapter.addEvidence("12345", belieflist[2], "Its delicious!");
        dbadapter.addEvidence("12345", belieflist[2], "OM NOM NOM");
//        dbadapter.close();
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
}
