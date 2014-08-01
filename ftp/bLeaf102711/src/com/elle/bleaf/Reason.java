package com.elle.bleaf;

public class Reason {
	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	private String source;
	private String content;
	
	public Reason (String source, String content) {
		this.source = source;
		this.content = content;
	}
}