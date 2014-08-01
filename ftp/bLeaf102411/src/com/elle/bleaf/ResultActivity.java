package com.elle.bleaf;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import android.database.Cursor;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.DisplayMetrics;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.TextView;

public class ResultActivity extends FragmentActivity {
	Bundle extras;
   	ExpandableListView mBeliefList;
   	BeliefListAdapter mAdapter;
   	
   	ArrayList<String> mBeliefs;
   	ArrayList<ArrayList<Evidence>> mEvidence;
   	
   	static BeliefData[] belieflist = new BeliefData[]{
   		new BeliefData("Environmental", 0),
   		new BeliefData("Worker Exploits", 0),
   		new BeliefData("Ice Cream!!!", 0)
   	};
   	
   	static HashMap<String, BeliefData> beliefmap = new HashMap<String, BeliefData>();
	public static final String MODE_NAME = "name";
	public static final String MODE_GCP = "gcp";
   	
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
        
        
        String comp = null;
        String mode = null;
        extras = getIntent().getExtras();
        if(extras != null){
        	comp = extras.getString("company");
        	mode = extras.getString("mode");
        }
        
        if(mode != null && mode.equalsIgnoreCase(MODE_GCP)){
        	if(comp.length() > 6)
        		comp = comp.substring(0,6);
        	comp = ("gcp" + comp);
        	extras.putString("company", comp);
        }
        System.out.println(comp);
        
        
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
        loaderPop();
    }
    
    public void addItem(Evidence pEvidence) {
//        if (!mBeliefs.contains(pEvidence.getBelief())) {
//            mBeliefs.add(pEvidence.getBelief());
//        }
//        int index = mBeliefs.indexOf(pEvidence.getBelief());
//        if (mEvidence.size() < index + 1) {
//            mEvidence.add(new ArrayList<Evidence>());
//        }
//        mEvidence.get(index).add(pEvidence);
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
    
    @SuppressWarnings("unused")
	private void oldPop(){
//    	addItem(new Evidence("derp", belieflist[0], "Eats Babies"));
//        addItem(new Evidence("derp", belieflist[0], "Uses turtles as hockey pucks"));
//        addItem(new Evidence("derp", belieflist[0], "Hates puppies"));
//        addItem(new Evidence("derp", belieflist[1], "Children work in a fire factory"));
//        addItem(new Evidence("derp", belieflist[1], "Shoots late workers"));
//        addItem(new Evidence("derp", belieflist[1], "Still Eats Babies"));
//        addItem(new Evidence("derp", belieflist[2], "Its delicious!"));
//        addItem(new Evidence("derp", belieflist[2], "OM NOM NOM"));
    }
    
    private void dbPop(){
		BLeafDbAdapter dbadapter = new BLeafDbAdapter(this);
		dbadapter.open();
    	Cursor c = dbadapter.fetchCompanyEvidence("derp");
//    	startManagingCursor(c);
    	while(!c.isAfterLast()){
//    		Evidence e = new Evidence(
//    				c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_COMPANY)),
//    				getBelief(c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_BELIEF))),
//    				c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_DESCRIPTION)));
//    		addItem(e);
    		c.moveToNext();
    	}
    	c.close();
    	dbadapter.close();
    }
    
    @SuppressWarnings("unused")
	private void feedPop(String pCompany){
    	String company = pCompany;
    	ArrayList<Assertion> assertions = BLeafParser.scan(company);
    	Iterator<Assertion> itr = assertions.iterator();
		while (itr.hasNext()) {
			Assertion assertion = itr.next();
			ArrayList<Reason> reasons = assertion.getContainingItem().getReasons();
			Iterator<Reason> ritr = reasons.iterator();
			while(ritr.hasNext()){
				Reason reason = ritr.next();
//				Evidence e = new Evidence(
//						company,
//						getBelief(assertion.getCause()),
//						reason.getContent());
//				addItem(e);
			}
		}
    }
    
    private void loaderPop(){
    	getSupportLoaderManager().initLoader(0, extras, mAdapter);
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