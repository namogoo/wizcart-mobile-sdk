package com.namogoo.wizcartsample.customer;


import android.support.annotation.Keep;

import java.util.ArrayList;
import java.util.HashMap;

@Keep
public class CustomerProduct {
    private String sku;
    private String productId;
    private Float price;
    private Float listPrice;
    private String brand;
    private ArrayList<String>  categories;
    private HashMap<String, String> attributes;
    private Integer quantity;

    public CustomerProduct(String sku, String productId, Float price, Float listPrice, String brand, ArrayList<String> categories, HashMap<String, String> attributes, Integer quantity) {
        this.sku = sku;
        this.productId = productId;
        this.price = price;
        this.listPrice = listPrice;
        this.brand = brand;
        this.categories = categories;
        this.attributes = attributes;
        this.quantity = quantity;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public Float getPrice() {
        return price;
    }

    public void setPrice(Float price) {
        this.price = price;
    }

    public Float getListPrice() {
        return listPrice;
    }

    public void setListPrice(Float listPrice) {
        this.listPrice = listPrice;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public ArrayList<String> getCategories() {
        return categories;
    }

    public void setCategories(ArrayList<String> categories) {
        this.categories = categories;
    }

    public HashMap<String, String> getAttributes() {
        return attributes;
    }

    public void setAttributes(HashMap<String, String> attributes) {
        this.attributes = attributes;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }
}
