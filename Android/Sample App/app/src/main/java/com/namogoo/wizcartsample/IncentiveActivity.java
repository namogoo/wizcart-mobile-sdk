package com.namogoo.wizcartsample;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.namogoo.sdk.wizcart.exceptions.WebResponseNonWizCartUserException;
import com.namogoo.sdk.wizcart.models.IncentiveResult;
import com.namogoo.sdk.wizcart.models.enums.PageType;
import com.namogoo.wizcartsample.api.CartCouponApi;
import com.namogoo.wizcartsample.api.CartCouponApiUtils;
import com.namogoo.wizcartsample.customer.CustomerCart;
import com.namogoo.wizcartsample.customer.CustomerProduct;
import com.namogoo.wizcartsample.general.Config;
import com.namogoo.wizcartsample.general.Utils;
import com.namogoo.sdk.wizcart.listeners.WizCartListener;
import com.namogoo.sdk.wizcart.models.WizCartIncentiveResponse;
import com.namogoo.sdk.wizcart.models.WizCartTrackingResponse;
import com.namogoo.wizcartsample.model.CouponResponse;
import com.namogoo.wizcartsample.wrappers.WizCartClientWrapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.namogoo.wizcartsample.general.Params.WIZCART_COUPON_CODE;
import static com.namogoo.wizcartsample.general.Utils.getHashFromString;

public class IncentiveActivity extends AppCompatActivity {

    private WizCartClientWrapper wizCartClientWrapper;
    private WizCartListener wizCartListener;

    private TextView tvItemsCounter;
    private TextView tvSubtotal;
    private TextView tvIncentiveMessage;
    private TextView tvCouponCode;
    private RelativeLayout couponCodeContainer;
    private LinearLayout incentiveContainer;

    private CustomerCart customerCart;
    private String currentCouponCode = null;
    private float currentCouponDiscountValue = 0;
    private boolean isFirstResponse;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_incentive);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        tvItemsCounter = findViewById(R.id.count_items);
        tvSubtotal = findViewById(R.id.subtotal);
        tvIncentiveMessage = findViewById(R.id.incentive_message);
        tvCouponCode = findViewById(R.id.coupon_code);
        couponCodeContainer = findViewById(R.id.coupon_code_container);
        incentiveContainer = findViewById(R.id.incentive_container);

        setDisplayPrice();
        addButtosnOnClick();
        addCopyCoupon();

        // this is a sample app
        // the customerCart represents the current cart the customer uses in the app
        customerCart = new CustomerCart();
        customerCart.setCartId(Config.CART_ID);
        updateUIQuantity();
        isFirstResponse = true;
        initWizCart();
    }


    private void initWizCart()
    {
        //the account id was initialized in the previous activity
        //no need to resend it
        wizCartClientWrapper = new WizCartClientWrapper();
        addWizCartListener();
        wizCartClientWrapper.getIncentive(customerCart);
    }

    private void addButtosnOnClick() {
        findViewById(R.id.add_item).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateProductQuantity(1);
            }
        });

        findViewById(R.id.remove_item).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateProductQuantity(-1);
            }
        });

        findViewById(R.id.btn_purchase).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                boolean addedOtherIncentiveTypes = false; //free shipping for example

                //in this sample we auto-fill the current coupon code & value as if the user filled it in the submission form
                ArrayList<String> appliedCoupons = null;
                if (currentCouponCode != null)
                {
                    appliedCoupons = new ArrayList<>();
                    appliedCoupons.add(currentCouponCode);
                    customerCart.setDiscount(currentCouponDiscountValue);
                }

                String trackingId = UUID.randomUUID().toString(); //should be the unique order id of the purchase
                wizCartClientWrapper.sendTrackingCompletedPurchase(PageType.PAYMENT_PAGE, customerCart, currentCouponDiscountValue, currentCouponCode, addedOtherIncentiveTypes, appliedCoupons, trackingId);
                Intent thankYouIntent = new Intent(IncentiveActivity.this, ThankYouActivity.class);
                thankYouIntent.putExtra(WIZCART_COUPON_CODE, currentCouponCode);
                startActivity(thankYouIntent);
                finish();
            }
        });
    }

    private void addCopyCoupon() {
        couponCodeContainer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Utils.copyToClipBoard(IncentiveActivity.this, currentCouponCode);
                //send tracking for copy coupon event
                wizCartClientWrapper.sendTrackingCopyCouponToClipBoard(PageType.PRODUCT_PAGE, customerCart, currentCouponCode);
                Toast.makeText(IncentiveActivity.this, getString(R.string.coupon_copy),Toast.LENGTH_LONG).show();
            }
        });
    }

    private void updateProductQuantity(int numToUpdate) {
        //we only have one item in the sample app so we either add or remove the same product
        CustomerProduct customerProductDelta = getSampleProduct(numToUpdate);
        customerCart.addCustomProduct(customerProductDelta);

        updateUIQuantity();
        WizCartClientWrapper.CartChange cartChange = numToUpdate > 0 ? WizCartClientWrapper.CartChange.ITEM_ADDED : WizCartClientWrapper.CartChange.ITEM_REMOVED;

        CustomerProduct customerProduct = customerCart.getProductBySKU(customerProductDelta.getSku());
        if (customerProduct == null)
        {
            customerProduct = getSampleProduct(0);
        }

        wizCartClientWrapper.updateWizCart(PageType.PRODUCT_PAGE, customerCart, customerProduct, cartChange);
    }
    private void updateUIQuantity() {
        //update the UI

        tvItemsCounter.setText(String.valueOf(customerCart.getTotalItemsQuantity()));

        float currentTotalInCents = customerCart.getTotalPrice() *100;
        String displayPrice = Utils.getDisplayPrice(currentTotalInCents);
        tvSubtotal.setText(displayPrice);
    }



    // in the sample app we only have one product so it is always the same product
    private CustomerProduct getSampleProduct(int quantity) {
        // these are all mock data for the product.
        // in production it should be filled with real data.
        String sku = "prod_sku";
        String productId = "product_id";
        float price = Config.PRODUCT_PRICE;
        float listPrice = Config.PRODUCT_PRICE;
        String brand = getString(R.string.namogoo);
        ArrayList<String> categories = new ArrayList<>();
        categories.add("Squares");
        HashMap<String, String> attributes = new HashMap<>();
        attributes.put("color", "FECF3C");
        attributes.put("size", getString(R.string.your_size));
        CustomerProduct product = new CustomerProduct(sku, productId, price, listPrice, brand, categories, attributes, quantity);
        return product;
    }

    private void setDisplayPrice() {
        String displayPrice = Utils.getDisplayPrice(Config.PRODUCT_PRICE*100);
        ((TextView)findViewById(R.id.display_price)).setText(displayPrice);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                this.finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void addWizCartListener() {
        if (wizCartListener == null) {
            wizCartListener = new WizCartListener() {
                @Override
                public void incentiveResponse(WizCartIncentiveResponse wizCartIncentiveResponse, Exception exception) {
                    if (wizCartIncentiveResponse != null && isFirstResponse == true)
                    {
                        //send tracking for page view after we recieve the first get incentive response
                        //in this sample app we always display the wizcart incentive
                        //if you know the incentive will not be visible to the customer send false
                        wizCartClientWrapper.sendTrackingPageView(PageType.PRODUCT_PAGE, customerCart, true, currentCouponCode);
                        isFirstResponse = false;
                    }
                    if (wizCartIncentiveResponse != null && (wizCartIncentiveResponse.getCurrentTier() != null || wizCartIncentiveResponse.getNextTier() != null)) {
                        incentiveContainer.setVisibility(View.VISIBLE);
                        wizCartClientWrapper.sendTrackingUpdatedWizCartVisualStateIfNeeded(PageType.PRODUCT_PAGE, customerCart, currentCouponCode, true, false);
                        float currentTotal = customerCart.getTotalPrice();
                        boolean isBeforeFirstTier = wizCartIncentiveResponse.getCurrentTier() == null;
                        if (isBeforeFirstTier) {
                            currentCouponCode = null;
                            currentCouponDiscountValue = 0;
                            couponCodeContainer.setVisibility(View.GONE);
                            //threshold is returned in cents
                            if (currentTotal > 0 && wizCartIncentiveResponse.getNextTier().getThreshold() > currentTotal * 100) {
                                String distanceToFirstTier = Utils.getDisplayPrice(wizCartIncentiveResponse.getNextTier().getThreshold() - currentTotal * 100);
                                int discount = wizCartIncentiveResponse.getNextTier().getDiscountResult().getValue();
                                if (wizCartIncentiveResponse.getNextTier().getDiscountResult().getType().equals(IncentiveResult.DiscountValueType.PERCENT)) {
                                    tvIncentiveMessage.setText(getString(R.string.incentive_result_above_threshold_first_tier_below_min_tier_percent, distanceToFirstTier, Utils.getDisplayPercent(discount)));
                                } else {
                                    tvIncentiveMessage.setText(getString(R.string.incentive_result_above_threshold_first_tier_below_min_tier_fixed, distanceToFirstTier, Utils.getDisplayPercent(discount)));
                                }
                                return;
                            }
                             tvIncentiveMessage.setText(getString(R.string.incentive_result_below_threshold_first_tier));
                            return;
                        }
                        int discount = wizCartIncentiveResponse.getCurrentTier().getDiscountResult().getValue();
                        if (wizCartIncentiveResponse.getCurrentTier().getDiscountResult().getType().equals(IncentiveResult.DiscountValueType.PERCENT)) {
                            tvIncentiveMessage.setText(getString(R.string.incentive_result_in_tier_percent, Utils.getDisplayPercent(discount)));
                        } else {
                            tvIncentiveMessage.setText(getString(R.string.incentive_result_in_tier_fixed, Utils.getDisplayPercent(discount)));
                        }
                        //once you receive a coupon it should be stored locally until used or expired.
                        //this is not implemented in this sample application
                        getCartCoupon(wizCartIncentiveResponse.getCurrentTier().getThreshold() / 100, discount / 100);

                    } else {
                        wizCartClientWrapper.sendTrackingUpdatedWizCartVisualStateIfNeeded(PageType.PRODUCT_PAGE, customerCart, currentCouponCode, false, false);
                        if (exception instanceof WebResponseNonWizCartUserException) {
                            incentiveContainer.setVisibility(View.GONE);
                            return;
                        }
                        couponCodeContainer.setVisibility(View.GONE);
                        tvIncentiveMessage.setText(getString(R.string.incentive_result_below_threshold_first_tier));
                    }
                }

                @Override
                public void trackingResponse(WizCartTrackingResponse trackingResponse) {
                }
            };
        }
        wizCartClientWrapper.registerWizCartListener(wizCartListener);
    }

    private void getCartCoupon(int currentTier, final int discount) {
        //this call will generate a new coupon code for the end user.
        //this method should be called only the current saved coupon was used or expired

        CartCouponApi cartCouponApi = CartCouponApiUtils.getCartCouponApi();
        String couponHash = "CHRONODRIVE_"+currentTier+"_"+discount;
        long couponKey = getHashFromString(couponHash);
        if (couponKey > 0) {
            cartCouponApi.getCoupon(Config.ACCOUNT_ID, String.valueOf(couponKey)).enqueue(new Callback<CouponResponse>() {
                @Override
                public void onResponse(Call<CouponResponse> call, Response<CouponResponse> response) {
                    if (response.isSuccessful())
                    {
                        CouponResponse couponResponse = response.body();
                        currentCouponCode = couponResponse.getCoupon_code();
                    } else
                    {
                        //only for the sample application environment,
                        //in the case there is no coupon in the system we generate a random coupon.
                        //in real scenario this should not happen because the coupon db should be full.
                        currentCouponCode = UUID.randomUUID().toString().substring(0,13).toUpperCase();
                    }
                    currentCouponDiscountValue = discount;
                    tvCouponCode.setText(currentCouponCode);
                    couponCodeContainer.setVisibility(View.VISIBLE);
                    wizCartClientWrapper.sendTrackingUpdatedWizCartVisualStateIfNeeded(PageType.PRODUCT_PAGE, customerCart, currentCouponCode, true, true);

                }

                @Override
                public void onFailure(Call<CouponResponse> call, Throwable t) {
                    couponCodeContainer.setVisibility(View.GONE);
                }
            });
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        //the SDK checks for double listeners
        addWizCartListener();
    }

    @Override
    protected void onPause() {
        wizCartClientWrapper.unregisterWizCartListener(wizCartListener);
        super.onPause();
    }
}
