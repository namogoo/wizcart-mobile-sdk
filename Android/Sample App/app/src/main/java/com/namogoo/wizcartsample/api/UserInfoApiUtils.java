package com.namogoo.wizcartsample.api;

public class UserInfoApiUtils {
    public static final String BASE_URL = "https://key.personali.com/";

    public static UserInfoApi getUserInfoApi() {
        return RetrofitClient.getClient(BASE_URL).create(UserInfoApi.class);
    }
}
