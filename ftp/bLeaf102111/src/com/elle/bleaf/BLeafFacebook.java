package com.elle.bleaf;

import java.io.IOException;
import java.net.MalformedURLException;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.facebook.android.DialogError;
import com.facebook.android.Facebook;
import com.facebook.android.Facebook.DialogListener;
import com.facebook.android.FacebookError;

public class BLeafFacebook {
	static SharedPreferences settings;
	static Facebook facebook = new Facebook("199911970077149");
	
	public static void setup(Activity activity){
		settings = activity.getPreferences(Context.MODE_PRIVATE);

        String access_token = settings.getString("access_token", null);
        long expires = settings.getLong("access_expires", 0);
        if(access_token != null) {
            facebook.setAccessToken(access_token);
            System.out.println("Token Id: " + access_token);
        }
        if(expires != 0) {
            facebook.setAccessExpires(expires);
            System.out.println("Token Expires: " + expires);
        }
	}
	
	public static void testPost(Activity activity){
		if(!facebook.isSessionValid()){
			System.out.println("Facebook session invalid!");
			
			BLeafFacebook.authorize(activity);
			return;
		}
		
		postOnWall("this post was made automatically");
		
//        facebook.dialog(activity, "feed", new DialogListener(){
//
//			@Override
//			public void onComplete(Bundle values) {
//			}
//
//			@Override
//			public void onFacebookError(FacebookError e) {
//				// TODO Auto-generated method stub
//				
//			}
//
//			@Override
//			public void onError(DialogError e) {
//				// TODO Auto-generated method stub
//				
//			}
//
//			@Override
//			public void onCancel() {
//				// TODO Auto-generated method stub
//				
//			}
//        });
	}
	
	
	public static void postOnWall(String msg) {
         try {
                String response = facebook.request("me");
                Bundle parameters = new Bundle();
                parameters.putString("message", msg);
                parameters.putString("description", "test test test");
                response = facebook.request("me/feed", parameters, 
                        "POST");
         } catch(Exception e) {
             e.printStackTrace();
         }
    }
	
	public static void authorize(Activity activity){
		facebook.authorize(activity, new DialogListener() {
            @Override
            public void onComplete(Bundle values) {
            	System.out.println("Saving token...");
                SharedPreferences.Editor editor = settings.edit();
                editor.putString("access_token", facebook.getAccessToken());
                editor.putLong("access_expires", facebook.getAccessExpires());
                editor.commit();
            }

            @Override
            public void onFacebookError(FacebookError error) {}

            @Override
            public void onError(DialogError e) {}

            @Override
            public void onCancel() {}
        });
	}
	
	public static void authorizeCallback(int requestCode, int resultCode, Intent intent){
		System.out.println("Authorize callback goooo!");
        facebook.authorizeCallback(requestCode, resultCode, intent);
	}
}