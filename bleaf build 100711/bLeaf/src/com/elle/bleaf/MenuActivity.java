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
	
	Button result, scan, load, feed, quit;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
		
        result = (Button) findViewById(R.id.buttonresult);
        result.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				Intent myIntent = new Intent(MenuActivity.this, ResultActivity.class);
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
        
        load = (Button) findViewById(R.id.buttonload);
        load.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				createData();
			}
        });
        
        feed = (Button) findViewById(R.id.buttonfeed);
        feed.setOnClickListener(new OnClickListener(){
			public void onClick(View v) {
				BLeafParser.getFeeds();
			}
        });
        
        quit = (Button) findViewById(R.id.buttonquit);
        quit.setOnClickListener(new OnClickListener(){
			public void onClick(View arg0) {
				finish();
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
		dbadapter.open();
        dbadapter.addEvidence("derp", belieflist[0], "Eats Babies");
        dbadapter.addEvidence("derp", belieflist[0], "Uses turtles as hockey pucks");
        dbadapter.addEvidence("derp", belieflist[0], "Hates puppies");
        dbadapter.addEvidence("derp", belieflist[1], "Children work in a fire factory");
        dbadapter.addEvidence("derp", belieflist[1], "Shoots late workers");
        dbadapter.addEvidence("derp", belieflist[1], "Still Eats Babies");
        dbadapter.addEvidence("derp", belieflist[2], "Its delicious!");
        dbadapter.addEvidence("derp", belieflist[2], "OM NOM NOM");
//        dbadapter.close();
	}
	
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
	    if (requestCode == 0) {
	        if (resultCode == android.app.Activity.RESULT_OK) {
	            String contents = intent.getStringExtra("SCAN_RESULT");
	            String format = intent.getStringExtra("SCAN_RESULT_FORMAT");
	            System.out.println(contents);
	            System.out.println(format);
	            // Handle successful scan
				Intent i = new Intent(MenuActivity.this, ResultActivity.class);
				i.putExtra("company", contents);
				startActivity(i);
	        } 
	        else if (resultCode == android.app.Activity.RESULT_CANCELED) {
	            // Handle cancel
	        }
	    }
	}
}
