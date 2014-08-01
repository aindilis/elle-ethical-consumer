package com.elle.bleaf;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class MenuActivity extends Activity {
//	SharedPreferences settings;
	Button result, scan, cats, fbbutton, feed, quit;
	
//	Facebook facebook;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        System.out.println("Starting App...");
//        settings = getPreferences(MODE_PRIVATE);
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
        
        BLeafFacebook.setup(MenuActivity.this);
		
        result = (Button) findViewById(R.id.buttonresult);
        result.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				Intent myIntent = new Intent(MenuActivity.this, ResultActivity.class);
				myIntent.putExtra("company", "XYZ");
				myIntent.putExtra("mode", ResultActivity.MODE_NAME);
				startActivity(myIntent);
			}
        });

        cats = (Button) findViewById(R.id.buttoncats);
        cats.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				Intent myIntent = new Intent(MenuActivity.this, BeliefRatingActivity.class);
				startActivity(myIntent);
			}
        });
        
        scan = (Button) findViewById(R.id.buttonscan);
        scan.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
		    	Intent intent = new Intent("com.google.zxing.client.android.SCAN");
		    	intent.putExtra("SCAN_MODE", "PRODUCT_MODE");
		    	try{
		    		startActivityForResult(intent, 0);
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
        
        fbbutton = (Button) findViewById(R.id.buttonfacebook);
        fbbutton.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				BLeafFacebook.testPost(MenuActivity.this);
			}
        });
        
        feed = (Button) findViewById(R.id.buttonfeed);
        feed.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				BLeafParser.getFeeds(MenuActivity.this);
			}
        });
        
        quit = (Button) findViewById(R.id.buttonquit);
        quit.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				BLeafDbAdapter db = new BLeafDbAdapter(MenuActivity.this);
				db.open();
				db.nukeDatabase();
			}
        });
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
	
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
	    switch (requestCode) {
	    case 0:
	        if (resultCode == android.app.Activity.RESULT_OK) {
	            String contents = intent.getStringExtra("SCAN_RESULT");
	            String format = intent.getStringExtra("SCAN_RESULT_FORMAT");
	            System.out.println(contents);
	            System.out.println(format);
	            // Handle successful scan
				Intent i = new Intent(MenuActivity.this, ResultActivity.class);
				i.putExtra("company", contents);
				i.putExtra("mode", ResultActivity.MODE_GCP);
				startActivity(i);
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
