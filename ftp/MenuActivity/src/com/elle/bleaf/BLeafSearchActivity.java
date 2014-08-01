package com.elle.bleaf;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v4.widget.SimpleCursorAdapter;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ListView;

public class BLeafSearchActivity extends Activity {
	EditText search;
	ListView results;
	BLeafDbAdapter db;
	SimpleCursorAdapter mAdapter;
	
	@Override
	public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.search);
        db = new BLeafDbAdapter(this);
        
        search = (EditText) findViewById(R.id.searchinput);
        results = (ListView) findViewById(R.id.searchlist);
        mAdapter = new SimpleCursorAdapter(this, R.layout.search_child, null, new String[]{"name"}, new int[]{R.id.search_name}, 0);
    	results.setAdapter(mAdapter);
		Cursor c = db.searchCompanies("");
		mAdapter.changeCursor(c);
		mAdapter.notifyDataSetChanged();
        search.addTextChangedListener(new TextWatcher(){

			@Override
			public void afterTextChanged(Editable arg0) {
				Cursor c = db.searchCompanies(search.getText().toString());
				mAdapter.changeCursor(c);
				mAdapter.notifyDataSetChanged();
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// TODO Auto-generated method stub
				
			}
        	
        });
        
        results.setOnItemClickListener(new OnItemClickListener(){
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				Cursor c = (Cursor) mAdapter.getItem(arg2);
				String comp = c.getString(c.getColumnIndex("name"));
				Intent myIntent = new Intent(BLeafSearchActivity.this, ResultActivity.class);
				myIntent.putExtra("company", comp);
				myIntent.putExtra("mode", ResultActivity.MODE_NAME);
				startActivity(myIntent);
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
}
