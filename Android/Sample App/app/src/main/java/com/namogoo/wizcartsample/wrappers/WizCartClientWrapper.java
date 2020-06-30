package com.namogoo.wizcartsample.wrappers;

import com.namogoo.sdk.wizcart.WizCartClient;
import com.namogoo.sdk.wizcart.listeners.WizCartListener;
import com.namogoo.sdk.wizcart.models.Cart;
import com.namogoo.sdk.wizcart.models.Product;
import com.namogoo.sdk.wizcart.models.enums.PageType;
import com.namogoo.wizcartsample.customer.CustomerCart;
import com.namogoo.wizcartsample.customer.CustomerProduct;

import java.util.ArrayList;

public class WizCartClientWrapper {

    public enum CartChange {
        ITEM_ADDED,
        ITEM_REMOVED
    }


    private WizCartClient wizCartClient;
    private boolean lastWizCartVisibleState;
    /*****
     * Constructors
     */
    public WizCartClientWrapper () {
        wizCartClient = WizCartClient.getWizCartClient();
        lastWizCartVisibleState = false;
    }

    /***
     * Static Methods
     */

    /***
     *
     * @param clientId - logged in client unique identifier
     * @param tempClientId - unique identifier for the user who didn't login
     * @param retailerVisitor - unique identifier that connects the temp & client Ids (doesn't change after user logs in)
     */
    public void setClientIds (String clientId, String tempClientId, String retailerVisitor)
    {
        WizCartClient.setWizCartClientIds(clientId, tempClientId, retailerVisitor);
    }

    /***
     * Public Methods
     */

    public void registerWizCartListener(WizCartListener wizCartListener) {
        wizCartClient.registerWizCartListener(wizCartListener);
    }

    public void unregisterWizCartListener(WizCartListener wizCartListener) {
        wizCartClient.unregisterWizCartListener(wizCartListener);
    }

    public void sendTrackingPageView(PageType pageType, CustomerCart customerCart, boolean displayedWizcartIncentive, String wizCartCouponCode)
    {
        wizCartClient.trackPageView(pageType, covertCustomerCartToWizCart(customerCart), displayedWizcartIncentive, wizCartCouponCode);
    }

    public void sendTrackingUpdatedWizCartVisualStateIfNeeded(PageType pageType, CustomerCart customerCart, String wizCartCouponCode, boolean isShowing, boolean isNewCouponCode) {
        if (isNewCouponCode == false && lastWizCartVisibleState == isShowing)
        {
            return;
        }
        lastWizCartVisibleState = isShowing;
        if (isShowing == true) {
            wizCartClient.trackMaximizeIncentive(pageType, covertCustomerCartToWizCart(customerCart), wizCartCouponCode);
        } else {
            wizCartClient.trackMinimizeIncentive(pageType, covertCustomerCartToWizCart(customerCart), wizCartCouponCode);
        }
    }

    public void sendTrackingCopyCouponToClipBoard(PageType pageType, CustomerCart customerCart, String wizCartCouponCode) {
        wizCartClient.trackCopyCoupon(pageType, covertCustomerCartToWizCart(customerCart), wizCartCouponCode);
    }

    public void sendTrackingCompletedPurchase(PageType pageType, CustomerCart customerCart, float discountValueOfWizCartCouponUsed, String wizCartCouponCode, boolean addedOtherIncentiveTypes, ArrayList<String> appliedCoupons, String trackingId)
    {
        wizCartClient.trackCompletedPurchase(pageType, covertCustomerCartToWizCart(customerCart), discountValueOfWizCartCouponUsed, wizCartCouponCode, addedOtherIncentiveTypes, appliedCoupons, trackingId);
    }

    public void setTrafficSources(ArrayList<String> trafficSources) {
        WizCartClient.setTrafficSources(trafficSources);
    }

    public void getIncentive(CustomerCart customerCart)
    {
        Cart cart = covertCustomerCartToWizCart(customerCart);
        wizCartClient.getIncentive(cart, PageType.PRODUCT_PAGE);
    }

    public void updateWizCart(PageType pageType, CustomerCart customerCart, CustomerProduct customerProduct, CartChange cartChange)
    {
        getIncentive(customerCart);
        if (cartChange.equals(CartChange.ITEM_ADDED))
        {
            wizCartClient.trackItemAddedToCart(pageType, covertCustomerCartToWizCart(customerCart), convertCustomerProductToWizCartProduct(customerProduct));
        } else {
            wizCartClient.trackItemRemovedFromCart(pageType, covertCustomerCartToWizCart(customerCart), convertCustomerProductToWizCartProduct(customerProduct));
        }
    }

    //Todo: change below methods to customize for client cart
    /***
     *
     * Should implement client convert logic here
     */

    private Cart covertCustomerCartToWizCart(CustomerCart customerCart)
    {
        Cart cart = new Cart();
        cart.setCartId(customerCart.getCartId());
        float subtotal = customerCart.getSubTotalPrice();
        float total = customerCart.getTotalPrice();
        float discountValue = customerCart.getDiscountValue();
        cart.setSubtotal(subtotal);
        cart.setTotal(total);
        cart.setDiscountValue(discountValue);

        int quantity = 0;
        ArrayList<Product> wizCartProducts = new ArrayList<>();
        for (CustomerProduct customerProduct : customerCart.getProducts()) {
            wizCartProducts.add(convertCustomerProductToWizCartProduct(customerProduct));
            quantity += customerProduct.getQuantity();
        }

        cart.setQuantity(quantity);
        cart.setItems(wizCartProducts);
        return cart;
    }

    private Product convertCustomerProductToWizCartProduct(CustomerProduct customerProduct) {
        Product wizCartProduct = new Product(customerProduct.getSku(), customerProduct.getProductId(), customerProduct.getPrice(), customerProduct.getListPrice(), customerProduct.getBrand(), customerProduct.getCategories(), customerProduct.getAttributes(), customerProduct.getQuantity());
        return wizCartProduct;
    }

}
