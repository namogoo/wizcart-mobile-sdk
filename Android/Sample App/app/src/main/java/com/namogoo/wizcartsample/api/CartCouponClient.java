package com.namogoo.wizcartsample.api;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class CartCouponClient {
    private static Retrofit retrofit = null;

    public static Retrofit getCartCouponClient(String baseUrl) {

        if (retrofit==null) {
            retrofit = new Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
        }
        return retrofit;
    }
}
