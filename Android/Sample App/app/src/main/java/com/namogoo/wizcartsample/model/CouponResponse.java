package com.namogoo.wizcartsample.model;


import android.support.annotation.Keep;

import java.io.Serializable;

@Keep
public class CouponResponse implements Serializable {
    String id;
    String createDate;
    String customer_id;
    String coupon_code;
    String coupon_value;
    String coupon_key;
    String issue_date;
    String purchased_date;
    String expiration_date;

    public String getId() {
        return id;
    }

    public String getCreateDate() {
        return createDate;
    }

    public String getCustomer_id() {
        return customer_id;
    }

    public String getCoupon_code() {
        return coupon_code;
    }

    public String getCoupon_value() {
        return coupon_value;
    }

    public String getCoupon_key() {
        return coupon_key;
    }

    public String getIssue_date() {
        return issue_date;
    }

    public String getPurchased_date() {
        return purchased_date;
    }

    public String getExpiration_date() {
        return expiration_date;
    }
}
