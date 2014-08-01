package com.elle.bleaf;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.AsyncFacebookRunner.RequestListener;
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
		
		postOnWall(activity, "this post was made automatically");
		
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
	
	
	public static void postOnWall(Context context, String msg) {
         try {
//                String response = facebook.request("me");
                Bundle parameters = new Bundle();
                parameters.putString("message", msg);
//                parameters.putString("description", "test test test");
                String response = facebook.request("me/feed", parameters, "POST");
                System.out.println(response);
         } catch(Exception e) {
             e.printStackTrace();
         }
         
    }
	
	public static void share(Context context, String subject, String text) {
		 final Intent intent = new Intent(Intent.ACTION_SEND);

		 intent.setType("text/plain");
		 intent.putExtra(Intent.EXTRA_SUBJECT, subject);
		 intent.putExtra(Intent.EXTRA_TEXT, text);

		 context.startActivity(Intent.createChooser(intent, "Share..."));
	}
	
	public static void authorize(Activity activity){
		facebook.authorize(activity, new String[] {"publish_stream"}, new DialogListener() {
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
	
	public static void logout(Activity activity){
		AsyncFacebookRunner mAsyncRunner = new AsyncFacebookRunner(facebook);
		mAsyncRunner.logout(activity, new RequestListener(){

			@Override
			public void onComplete(String response, Object state) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onIOException(IOException e, Object state) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onFileNotFoundException(FileNotFoundException e,
					Object state) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onMalformedURLException(MalformedURLException e,
					Object state) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onFacebookError(FacebookError e, Object state) {
				// TODO Auto-generated method stub
				
			}
			
		});
	}
	
	public static void authorizeCallback(int requestCode, int resultCode, Intent intent){
		System.out.println("Authorize callback goooo!");
        facebook.authorizeCallback(requestCode, resultCode, intent);
	}
}