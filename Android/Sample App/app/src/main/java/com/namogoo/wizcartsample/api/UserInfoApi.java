package com.namogoo.wizcartsample.api;


import com.namogoo.sdk.wizcart.models.WizCartConnectParams;
import com.namogoo.sdk.wizcart.models.WizCartConnectResponse;
import com.namogoo.sdk.wizcart.models.WizCartGetIncentiveParams;
import com.namogoo.sdk.wizcart.models.WizCartIncentiveResponse;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface UserInfoApi {
    @GET("user_to_type_{account_id}")
    Call<String> userType(@Path("account_id") Integer account_id, @Query("name") String clientId, @Query("safe") boolean isSafe);

    @GET("user_to_group_{account_id}")
    Call<String> groupType(@Path("account_id") Integer account_id, @Query("name") String clientId, @Query("safe") boolean isSafe);

}
