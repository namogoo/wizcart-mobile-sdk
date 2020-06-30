package com.namogoo.wizcartsample.api;


import com.namogoo.wizcartsample.model.CouponResponse;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface CartCouponApi {
    @GET("/")
    Call<CouponResponse> getCoupon(@Query("customer_id") Integer account_id, @Query("coupon_key") String couponHash);

}
