package com.elle.bleaf;

import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.net.ParseException;

public class Message implements Comparable<Message> {
	static SimpleDateFormat FORMATTER = 
		new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss Z");
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public URL getLink() {
		return link;
	}

	public void setLink(URL link) {
		this.link = link;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	private String title;
	private URL link;
	private String description;
	private Date date;

	// getters and setters omitted for brevity
	public void setLink(String link) {
		try {
			this.link = new URL(link);
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}
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
		return title + '\n' + link + '\n' + description + '\n' + date + '\n';
		// omitted for brevity
	}

	@Override
	public int hashCode() {
		// omitted for brevity
		return 0;
	}

	@Override
	public boolean equals(Object obj) {
		// omitted for brevity
		return new Boolean("true");
	}
	
	// sort by date
	public int compareTo(Message another) {
		if (another == null) return 1;
		// sort descending, most recent first
		return another.date.compareTo(date);
	}
}
