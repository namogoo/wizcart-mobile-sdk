package com.namogoo.wizcartsample;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.namogoo.sdk.wizcart.models.enums.PageType;
import com.namogoo.wizcartsample.customer.CustomerCart;
import com.namogoo.wizcartsample.general.Config;
import com.namogoo.wizcartsample.general.Utils;
import com.namogoo.wizcartsample.wrappers.WizCartClientWrapper;

import java.util.UUID;

import static com.namogoo.wizcartsample.general.Params.CUSTOMER_CART;
import static com.namogoo.wizcartsample.general.Params.WIZCART_COUPON_CODE;

public class ThankYouActivity extends AppCompatActivity {

    private WizCartClientWrapper wizCartClientWrapper;
    private String couponCode;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Utils.hideSystemUI(this);
        setContentView(R.layout.activity_thankyou);

        findViewById(R.id.back_store).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        getIntentExtra();
        initWizCart();
    }

    private void getIntentExtra() {
        if (getIntent().getExtras() == null) {
            return;
        }
        couponCode = getIntent().getExtras().getString(WIZCART_COUPON_CODE);
    }

    private void initWizCart()
    {
        //the account id was initialized in the previous activity
        //no need to resend it
        wizCartClientWrapper = new WizCartClientWrapper();

        //should send the customer cart of the purchase
        //this is only a sample app so we generate a new one
        CustomerCart customerCart = new CustomerCart();
        customerCart.setCartId(Config.CART_ID);
        //send tracking for page view
        //in this sample app we always display the wizcart incentive
        //if you know the incentive will not be visible to the customer send false
        wizCartClientWrapper.sendTrackingPageView(PageType.CONFIRMATION_PAGE, customerCart, false, couponCode);

        Config.CART_ID = UUID.randomUUID().toString(); //the cart id should be unique per purchase
    }

    @Override
    protected void onResume() {
        super.onResume();
        Utils.hideSystemUI(this);
    }
}
