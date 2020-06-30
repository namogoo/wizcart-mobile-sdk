package com.namogoo.wizcartsample;

import android.app.Application;

import com.namogoo.sdk.wizcart.WizCartClient;

import static com.namogoo.wizcartsample.general.Config.ACCOUNT_ID;

public class WizCartSampleApp extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        WizCartClient.newInstance(getApplicationContext(), ACCOUNT_ID);
    }
}
