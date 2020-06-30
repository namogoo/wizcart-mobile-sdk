package com.namogoo.wizcartsample.general;

import android.app.Activity;
import android.content.Context;
import android.view.View;

import java.text.DecimalFormat;

public class Utils {
    public static void hideSystemUI(Activity activity) {

        View decorView = activity.getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE
                        // Set the content to appear under the system bars so that the
                        // content doesn't resize when the system bars hide and show.
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        //| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        // Hide the nav bar and status bar
                        //| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_FULLSCREEN);
    }

    public static String getDisplayPrice(float priceInCents)
    {
        String displayPrice = Config.PRICE_SYMBOL + String.format("%.2f", (priceInCents/100));
        return displayPrice;
    }

    public static String getDisplayPercent(float percent)
    {
        DecimalFormat df = new DecimalFormat("##.##");
        String displayPrice = df.format(percent/100);
        return displayPrice;
    }

    public static long getHashFromString(String str)
    {
        int hash = 5381;
        int i    = str.length();

        while(i >0) {
            hash = (hash * 33) ^ (int)str.charAt(--i);
        }

        /*  Since we want the results to be always positive, convert the
         * signed int to an unsigned by doing an unsigned bitshift. */
        return hash & 0xffffffffl;
    }

    public static void copyToClipBoard(Context context, String str)
    {
        if(android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.HONEYCOMB) {
            android.text.ClipboardManager clipboard = (android.text.ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
            clipboard.setText(str);
        } else {
            android.content.ClipboardManager clipboard = (android.content.ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
            android.content.ClipData clip = android.content.ClipData.newPlainText("Copied Text", str);
            clipboard.setPrimaryClip(clip);
        }
    }
}
