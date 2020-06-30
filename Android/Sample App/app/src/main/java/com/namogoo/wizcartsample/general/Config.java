package com.namogoo.wizcartsample.general;

import java.util.UUID;

public class Config {

    public static final Integer ACCOUNT_ID = 264;

    public static final String CLIENT_USER_ID_WIZCART = "b551882c4a4d6779ef696d2902323cfb";  //logged in user that is not in wizcart sample group
    public static final String CLIENT_USER_ID_TEMP = "b551882c4a4d6779ef696d2902323cfb"; // non logged in user
    public static final String RETAIL_VISITOR = "b551882c4a4d6779ef696d2902323cfb"; //Should remain the same until user logs out

    public static final String CLIENT_USER_ID_CONTROL = "fffe3b22ddcc5e887aaa8fd9aa9083ca"; //logged in user that is not in wizcart sample group
    public static final String CLIENT_USER_ID_TEMP_CONTROL = "fffe3b22ddcc5e887aaa8fd9aa9083ca"; // non logged in user
    public static final String RETAIL_VISITOR_CONTROL = "fffe3b22ddcc5e887aaa8fd9aa9083ca"; //Should remain the same until user logs out


    public static String CART_ID = UUID.randomUUID().toString(); //the cart id should be unique per purchase


    public static final float PRODUCT_PRICE = 30.00f;
    public static final String PRICE_SYMBOL = "\u20ac";
}
