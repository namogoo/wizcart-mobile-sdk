package com.namogoo.wizcartsample;


import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.view.View;
import android.view.WindowManager;
import android.widget.CompoundButton;
import android.widget.TextView;
import android.widget.Toast;

import com.namogoo.sdk.wizcart.WizCartClient;
import com.namogoo.sdk.wizcart.models.enums.PageType;
import com.namogoo.wizcartsample.api.UserInfoApi;
import com.namogoo.wizcartsample.api.UserInfoApiUtils;
import com.namogoo.wizcartsample.customer.CustomerCart;
import com.namogoo.wizcartsample.general.Config;
import com.namogoo.wizcartsample.general.Utils;
import com.namogoo.sdk.wizcart.listeners.WizCartListener;
import com.namogoo.sdk.wizcart.models.WizCartIncentiveResponse;
import com.namogoo.sdk.wizcart.models.WizCartTrackingResponse;
import com.namogoo.wizcartsample.wrappers.WizCartClientWrapper;

import java.util.ArrayList;

import static com.namogoo.wizcartsample.general.Config.ACCOUNT_ID;
import static com.namogoo.wizcartsample.general.Config.CLIENT_USER_ID_CONTROL;
import static com.namogoo.wizcartsample.general.Config.CLIENT_USER_ID_TEMP;
import static com.namogoo.wizcartsample.general.Config.CLIENT_USER_ID_TEMP_CONTROL;
import static com.namogoo.wizcartsample.general.Config.CLIENT_USER_ID_WIZCART;
import static com.namogoo.wizcartsample.general.Config.RETAIL_VISITOR;
import static com.namogoo.wizcartsample.general.Config.RETAIL_VISITOR_CONTROL;

public class MainShoppingActivity extends AppCompatActivity {

    private WizCartClientWrapper wizCartClientWrapper;
    private WizCartListener wizCartListener;
    private String currentClientId;

    ArrayList<String> trafficSources;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Utils.hideSystemUI(this);
        setContentView(R.layout.activity_shopping_main);

        setVersions();
        addOnClicks();

        //init the wizcart
        wizCartClientWrapper = new WizCartClientWrapper();
        addWizCartListener();
        currentClientId = CLIENT_USER_ID_WIZCART;
        wizCartClientWrapper.setClientIds(currentClientId, CLIENT_USER_ID_TEMP, RETAIL_VISITOR);
        getClientTypeAndGroup();
    }

    private void setVersions() {
        ((TextView)findViewById(R.id.app_version)).setText(getString(R.string.app_version, BuildConfig.VERSION_NAME));
        ((TextView)findViewById(R.id.sdk_version)).setText(getString(R.string.sdk_version, WizCartClient.getSDKVersion()));
    }

    private void addOnClicks() {

        findViewById(R.id.btn_tracking).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //need to fill all params before sending
                PageType pageType = PageType.HOME_PAGE;
                CustomerCart customerCart = new CustomerCart();
                boolean wasIncentiveDisplayed = false;
                customerCart.setCartId(Config.CART_ID);
                String wizCartCouponCode = null;
                wizCartClientWrapper.sendTrackingPageView(pageType, customerCart,wasIncentiveDisplayed, wizCartCouponCode);
            }
        });

        findViewById(R.id.btn_incentive).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent incentiveIntent = new Intent(MainShoppingActivity.this, IncentiveActivity.class);
                startActivity(incentiveIntent);
            }
        });

        ((SwitchCompat)findViewById(R.id.user_switch)).setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                currentClientId = isChecked ? CLIENT_USER_ID_WIZCART : CLIENT_USER_ID_CONTROL;
                String tempClientId = isChecked ? CLIENT_USER_ID_TEMP : CLIENT_USER_ID_TEMP_CONTROL;
                String retailVisitor = isChecked ? RETAIL_VISITOR : RETAIL_VISITOR_CONTROL;
                wizCartClientWrapper.setClientIds(currentClientId, tempClientId, retailVisitor);
                getClientTypeAndGroup();
            }
        });
    }

    private void addWizCartListener() {

        if (wizCartListener == null) {
            //create a wizcart   listener
            wizCartListener = new WizCartListener() {
                @Override
                public void incentiveResponse(WizCartIncentiveResponse wizCartIncentiveResponse, Exception exception) {
                    if (wizCartIncentiveResponse != null) {
                        //Success: Do something
                    } else {
                        //Error: check the Exception parameter
                    }
                }

                @Override
                public void trackingResponse(WizCartTrackingResponse trackingResponse) {
                    String msg;
                    if (trackingResponse != null && trackingResponse.getTrackingResponseType().equals(WizCartTrackingResponse.TrackingResponseType.OK)) {

                        msg = "Success";
                    } else {
                        msg = "Error";
                    }
                    Toast.makeText(MainShoppingActivity.this, msg, Toast.LENGTH_SHORT).show();
                }
            };
        }
        wizCartClientWrapper.registerWizCartListener(wizCartListener);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Utils.hideSystemUI(this);

        //the SDK checks for double listeners
        addWizCartListener();
    }

    @Override
    protected void onPause() {
        wizCartClientWrapper.unregisterWizCartListener(wizCartListener);
        super.onPause();
    }

    private void getClientTypeAndGroup()
    {
        trafficSources = new ArrayList<>();
        new AsyncTask<Void, Void, Void>()
        {
            final ProgressDialog dialog = new ProgressDialog(MainShoppingActivity.this);
            UserInfoApi userInfoApi = UserInfoApiUtils.getUserInfoApi();
            @Override
            protected void onPreExecute() {
                super.onPreExecute();
                dialog.setMessage(getString(R.string.processing));

                dialog.setOnShowListener(new DialogInterface.OnShowListener() {
                    @Override
                    public void onShow(DialogInterface dialog) {
                        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                    }
                });
                dialog.show();

            }

            @Override
            protected Void doInBackground(Void... voids) {
                try {
                    String groupType = userInfoApi.groupType(ACCOUNT_ID, currentClientId, true).execute().body();
                    String userType = userInfoApi.userType(ACCOUNT_ID, currentClientId, true).execute().body();
                    trafficSources.add(groupType);
                    trafficSources.add(userType);
                    wizCartClientWrapper.setTrafficSources(trafficSources);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(Void aVoid) {
                super.onPostExecute(aVoid);
                try {
                    dialog.dismiss();
                } catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }
}
