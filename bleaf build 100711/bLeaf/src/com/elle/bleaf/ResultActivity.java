package com.elle.bleaf;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import android.app.Activity;
import android.database.Cursor;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnChildClickListener;

public class ResultActivity extends Activity {
   	ExpandableListView mBeliefList;
   	BeliefListAdapter mAdapter;
   	
   	ArrayList<BeliefData> mBeliefs;
   	ArrayList<ArrayList<EvidenceData>> mEvidence;
   	
   	static BeliefData[] belieflist = new BeliefData[]{
   		new BeliefData("Environmental", 0),
   		new BeliefData("Worker Exploits", 0),
   		new BeliefData("Ice Cream!!!", 0)
   	};
   	
   	static HashMap<String, BeliefData> beliefmap = new HashMap<String, BeliefData>();
   	
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
        
        mBeliefs = new ArrayList<BeliefData>();
        mEvidence = new ArrayList<ArrayList<EvidenceData>>();
        String comp = getIntent().getExtras().getString("company");
        
        if(comp != null){
        	comp = comp.substring(1,6);
        }else{
        	comp = "12345";
        }
        System.out.println(comp);
        feedPop(comp);
        
        
        mBeliefList = (ExpandableListView) findViewById(R.id.belieflist);

        metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);
        width = metrics.widthPixels;
        //this code for adjusting the group indicator into right side of the view
        mBeliefList.setIndicatorBounds(width - GetDipsFromPixel(75), width - GetDipsFromPixel(35));
        
        mBeliefList.setOnChildClickListener(new OnChildClickListener(){

			public boolean onChildClick(ExpandableListView arg0, View arg1,
					int arg2, int arg3, long arg4) {
				EvidenceData evidence = (EvidenceData) mAdapter.getChild(arg2, arg3);
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
    }
    
    public void addItem(EvidenceData pEvidence) {
        if (!mBeliefs.contains(pEvidence.getBelief())) {
            mBeliefs.add(pEvidence.getBelief());
        }
        int index = mBeliefs.indexOf(pEvidence.getBelief());
        if (mEvidence.size() < index + 1) {
            mEvidence.add(new ArrayList<EvidenceData>());
        }
        mEvidence.get(index).add(pEvidence);
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
    	addItem(new EvidenceData("derp", belieflist[0], "Eats Babies"));
        addItem(new EvidenceData("derp", belieflist[0], "Uses turtles as hockey pucks"));
        addItem(new EvidenceData("derp", belieflist[0], "Hates puppies"));
        addItem(new EvidenceData("derp", belieflist[1], "Children work in a fire factory"));
        addItem(new EvidenceData("derp", belieflist[1], "Shoots late workers"));
        addItem(new EvidenceData("derp", belieflist[1], "Still Eats Babies"));
        addItem(new EvidenceData("derp", belieflist[2], "Its delicious!"));
        addItem(new EvidenceData("derp", belieflist[2], "OM NOM NOM"));
    }
    
    private void dbPop(){
		BLeafDbAdapter dbadapter = new BLeafDbAdapter(this);
		dbadapter.open();
    	Cursor c = dbadapter.fetchCompanyEvidence("derp");
//    	startManagingCursor(c);
    	while(!c.isAfterLast()){
    		EvidenceData e = new EvidenceData(
    				c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_COMPANY)),
    				getBelief(c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_BELIEF))),
    				c.getString(c.getColumnIndexOrThrow(BLeafDbAdapter.COL_DESCRIPTION)));
    		addItem(e);
    		c.moveToNext();
    	}
    	c.close();
    	dbadapter.close();
    }
    
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
				EvidenceData e = new EvidenceData(
						company,
						getBelief(assertion.getCause()),
						reason.getContent());
				addItem(e);
			}
		}
    }
}