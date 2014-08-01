package com.elle.bleaf;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;

import android.net.ParseException;

public class Item {
	static SimpleDateFormat FORMATTER = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss Z");
	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public void addLogic(Assertion a) {
		logic.add(a);
	}
	
	public ArrayList<Assertion> getLogic() {
		return logic;
	}

	public void addReason(Reason reason) {
		reasons.add(reason);
	}

	public ArrayList<Reason> getReasons () {
		return reasons;
	}
	
	public void setDate(Date date) {
		this.date = date;
	}

	private String source;
	private String title;
	private String category;
	private ArrayList<Assertion> logic;
	private ArrayList<Reason> reasons;
	private Date date;
	enum TernaryLogic {TRUE,FALSE,UNKNOWN};
	private TernaryLogic approved; 

	public TernaryLogic getApproved() {
		return approved;
	}

	public void setApproved(TernaryLogic approved) {
		this.approved = approved;
	}

	public String getDate() {
		return FORMATTER.format(this.date);
	}

	public void setDate(String date) throws java.text.ParseException {
		// pad the date if necessary
		while (!date.endsWith("00")){
			date += "0";
		}
		try {
			this.date = FORMATTER.parse(date.trim());
		} catch (ParseException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public String toString() {
		return title + '\n' + category + '\n' + date + '\n';
	}
	
	public Item () {
		logic = new ArrayList<Assertion>();
		reasons = new ArrayList<Reason>();
		approved = TernaryLogic.UNKNOWN;
	}
	
	public String printLogic () {
		Iterator<Assertion> itr = logic.iterator();
		String returnval = "";
		while (itr.hasNext()) {
			Assertion assertion = itr.next();
			returnval = returnval + assertion.toString();
		}
		returnval = printReasons();
		return returnval;
	}
	
	public String printReasons () {
		String returnval = "";
		Iterator<Reason> itr2 = reasons.iterator();
		while (itr2.hasNext()) {
			Reason reason = itr2.next();
			returnval = returnval + "Reason: " + reason.getContent()+ "\n";
		}
		return returnval;
	}
}