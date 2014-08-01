package com.elle.bleaf;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.SearchManager;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.DisplayMetrics;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnCreateContextMenuListener;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.ExpandableListContextMenuInfo;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

public class ResultActivity extends FragmentActivity {
    
    public static final String API_KEY = "AIzaSyAFAyDWBGph99y7po0400yAO_DoLTuIw-c";
	public static final String BASE_PRODUCT_URI = "https://www.googleapis.com/shopping/search/v1/public/products?country=US&key=" + API_KEY + "&restrictBy=gtin:";
	public static final String PRODUCT_SEARCH = "http://www.google.com/m/products?ie=utf8&oe=utf8&scoring=p&source=bleaf&q=";
	Bundle extras;
   	ExpandableListView mBeliefList;
   	BeliefListAdapter mAdapter;
   	
   	ArrayList<String> mBeliefs;
   	ArrayList<ArrayList<Evidence>> mEvidence;
   	
   	TextView productname, productbrand, productprice;
   	Button productsearch, websearch;
   	
   	String searchurl;
   	
   	static BeliefData[] belieflist = new BeliefData[]{
   		new BeliefData("Environmental", 0),
   		new BeliefData("Worker Exploits", 0),
   		new BeliefData("Ice Cream!!!", 0)
   	};
   	
   	static HashMap<String, BeliefData> beliefmap = new HashMap<String, BeliefData>();
	public static final String MODE_NAME = "name";
	public static final String MODE_GCP = "gcp";
	protected static final int CONTEXT_SHARE = 0;
	protected static final int CONTEXT_LINKS = 1;
   	
   	static{
   		for(int i = 0; i < belieflist.length; i++){
   			beliefmap.put(belieflist[i].name, belieflist[i]);
   		}
   	}
   	
    DisplayMetrics metrics;
    int width;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.result);
        
        mBeliefs = new ArrayList<String>();
        mEvidence = new ArrayList<ArrayList<Evidence>>();
        

    	ProgressBar p = (ProgressBar) findViewById(R.id.result_load);
    	p.setVisibility(View.VISIBLE);
    	
        String comp = null;
        @SuppressWarnings("unused")
		String mode = null;
        extras = getIntent().getExtras();
        if(extras != null){
        	comp = extras.getString("company");
        	mode = extras.getString("mode");
        }
        String upc = extras.getString("upc");
        final String search;
        if(upc != null && !upc.equalsIgnoreCase(""))
        	search = upc;
        else
        	search = comp;
        
//        if(mode != null && mode.equalsIgnoreCase(MODE_GCP)){
//        	if(comp.length() > 6)
//        		comp = comp.substring(0,6);
//        	comp = ("gcp" + comp);
//        	extras.putString("company", comp);
//        }
        System.out.println(comp);
        productname = (TextView) findViewById(R.id.resultproductname);
        productbrand = (TextView) findViewById(R.id.resultproductbrand);
        productprice = (TextView) findViewById(R.id.resultproductprice);
        productsearch = (Button) findViewById(R.id.resultproductsearch);
        websearch = (Button) findViewById(R.id.resultwebsearch);
        
        productsearch.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(PRODUCT_SEARCH + search));
				startActivity(browserIntent);
			}
        });
        websearch.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
				intent.putExtra(SearchManager.QUERY, search);
				startActivity(intent);
			}
        });
        
        productname.setText("");
        productbrand.setText("");
        productprice.setText("");
        
        if(upc != null && !upc.equalsIgnoreCase("")){
        	try {
				products(upc);
			} catch (Exception e) {
				e.printStackTrace();
			}
        }
        
        TextView tv = (TextView) findViewById(R.id.resultcompany);
        tv.setText(comp);
        
//        feedPop(comp);
        
        
        mBeliefList = (ExpandableListView) findViewById(R.id.belieflist);

        metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);
        width = metrics.widthPixels;
        //this code for adjusting the group indicator into right side of the view
        mBeliefList.setIndicatorBounds(width - GetDipsFromPixel(75), width - GetDipsFromPixel(35));
        
        mBeliefList.setOnChildClickListener(new OnChildClickListener(){

			public boolean onChildClick(ExpandableListView arg0, View arg1,
					int arg2, int arg3, long arg4) {
				Evidence evidence = (Evidence) mAdapter.getChild(arg2, arg3);
				if(evidence.getVisibility() == View.GONE){
					evidence.setVisibility(View.VISIBLE);
				}else{
					evidence.setVisibility(View.GONE);
				}
				mAdapter.notifyDataSetChanged();
				return true;
			}
        	
        });
        
        mAdapter = new BeliefListAdapter(this, mBeliefs, mEvidence);
        mBeliefList.setAdapter(mAdapter);
        mBeliefList.setOnCreateContextMenuListener(new OnCreateContextMenuListener(){
			@Override
			public void onCreateContextMenu(ContextMenu arg0, View arg1,
					ContextMenuInfo arg2) {
				if(ExpandableListView.getPackedPositionType(((ExpandableListContextMenuInfo)arg2).packedPosition)
						== ExpandableListView.PACKED_POSITION_TYPE_CHILD){
					arg0.setHeaderTitle("Options"); 
					arg0.add(0, CONTEXT_SHARE, 0, "Share this point");
					arg0.add(0, CONTEXT_LINKS, 1, "Links");
				}
			}
        });
        loaderPop();
    }
    
    public BeliefData getBelief(String pName){
    	if(!beliefmap.containsKey(pName)){
    		beliefmap.put(pName, new BeliefData(pName, 0));
    	}
    	return beliefmap.get(pName);
    }
    
    public int GetDipsFromPixel(float pixels)
    {
     // Get the screen's density scale
    	final float scale = getResources().getDisplayMetrics().density;
     // Convert the dps to pixels, based on density scale
     	return (int) (pixels * scale + 0.5f);
    }
    
    private void loaderPop(){
    	getSupportLoaderManager().initLoader(0, extras, mAdapter);
    }
    
    public String[] products(String upc) throws MalformedURLException, JSONException, IOException {
		String producturl = BASE_PRODUCT_URI + upc;
		URL url = new URL(producturl);
		ByteArrayOutputStream urlOutputStream = new ByteArrayOutputStream();
		IOUtils.copy(url.openStream(), urlOutputStream);
		String urlContents = urlOutputStream.toString();
		JSONObject products = new JSONObject(urlContents);
		JSONArray itemArray = products.getJSONArray("items");
		JSONObject itemObject = itemArray.getJSONObject(0);
		JSONObject productObject = itemObject.getJSONObject("product");
		JSONObject author = productObject.getJSONObject("author");
		String storename = author.getString("name");
		String title = productObject.getString("title");
		String description = productObject.getString("description");
		String brand = productObject.getString("brand");
		String linktostore = productObject.getString("link");
		JSONArray imageArray = productObject.getJSONArray("images");
		JSONObject imageObject = imageArray.getJSONObject(0);
		String imageurl = imageObject.getString("link");
		JSONArray inventories = productObject.getJSONArray("inventories");
		JSONObject inventoryinfo = inventories.getJSONObject(0);
		String price = inventoryinfo.getString("price");
		String[] productdata = {storename, title, description, brand, linktostore, imageurl, price};
		
		
		searchurl = linktostore;
		productname.setText(title);
		productbrand.setText(brand);
		productprice.setText(price);
		try {
			ImageView i = (ImageView)findViewById(R.id.resultimage);
			Bitmap bitmap = BitmapFactory.decodeStream((InputStream)new URL(imageurl).getContent());
			i.setImageBitmap(bitmap); 
		} catch (Exception e) {
			
		}
		
		return productdata;
	}
    
    @Override 
    public boolean onContextItemSelected(MenuItem item) {
    	ExpandableListContextMenuInfo menuInfo = (ExpandableListContextMenuInfo) item.getMenuInfo();
    	int group = ExpandableListView.getPackedPositionGroup(menuInfo.packedPosition);
    	int child = ExpandableListView.getPackedPositionChild(menuInfo.packedPosition);
    	Evidence e = null;
    	if(child != -1){
    		e = (Evidence) mAdapter.getChild(group, child);
    	}
    	switch (item.getItemId()) {
    	case CONTEXT_SHARE:
    		BLeafFacebook.share(ResultActivity.this, e.title, e.description + "\n" + e.link);
    		return true;
    	case CONTEXT_LINKS:
    		BLeafDbAdapter db = new BLeafDbAdapter(this);
    		Cursor c = db.getLinks(e.id);
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
    		
    		new AlertDialog.Builder(this)
    		.setTitle("Additional Links")
    		.setItems(names, new DialogInterface.OnClickListener(){
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String url = links[which];
					if (!url.startsWith("http://") && !url.startsWith("https://"))
						   url = "http://" + url;
					
					Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
					startActivity(browserIntent);
				}
    		}).show();
    		return true;
    	}
    	return false; 
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
}