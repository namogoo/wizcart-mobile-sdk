package com.namogoo.wizcartsample.api;

public class CartCouponApiUtils {
    public static final String BASE_URL = "https://coupon.personali.com/";

    public static CartCouponApi getCartCouponApi() {
        return CartCouponClient.getCartCouponClient(BASE_URL).create(CartCouponApi.class);
    }
}
