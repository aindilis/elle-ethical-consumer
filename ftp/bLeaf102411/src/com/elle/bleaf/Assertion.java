package com.elle.bleaf;

import java.util.ArrayList;
import java.util.Iterator;

public class Assertion {
	enum Action { ASSERT, RETRACT };
	public Action getAction() {
		return action;
	}

	public void setAction(Action action) {
		this.action = action;
	}

	private Action action;
	private String cause;
	private ArrayList<String> manufacturers;
	
	public Item getContainingItem() {
		return containingItem;
	}

	public void setContainingItem(Item containingItem) {
		this.containingItem = containingItem;
	}

	private Item containingItem;
	
	public void setCause(String cause) {
		this.cause = cause;
	}
	
	public String getCause () {
		return cause;
	}
	
	public void addManufacturer (String manufacturer) {
		manufacturers.add(manufacturer);
	}
	
	public ArrayList<String> getManufacturers () {
		return manufacturers;
	}
	
	public Assertion (Item containingItem, Action action) {
		this.containingItem = containingItem;
		this.action = action;
		this.manufacturers = new ArrayList<String>();
	}
	
	public String toString () {
		String result = "";
		result = "Cause: " + cause + "\n";
		Iterator<String> itr = manufacturers.iterator();
		while (itr.hasNext()) {
			result = result + "\tManufacturer: " + itr.next() + "\n";
		}
		return result;
	}
}