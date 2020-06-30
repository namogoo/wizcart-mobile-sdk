package com.namogoo.wizcartsample.customer;

import java.io.Serializable;
import java.util.ArrayList;

public class CustomerCart implements Serializable {
    //this is a mock crt model that represents the current cart the customer has

    private String cartId;
    private ArrayList<CustomerProduct> products;
    private float currentDiscount;

    public CustomerCart() {
        products = new ArrayList<>();
    }

    public String getCartId() {
        return cartId;
    }

    public void setCartId(String cartId) {
        this.cartId = cartId;
    }

    public ArrayList<CustomerProduct> getProducts() {
        return products;
    }

    public void setProducts(ArrayList<CustomerProduct> products) {
        this.products = products;
    }

    public void addCustomProduct(CustomerProduct newProduct) {
        boolean wasUpdated = false;

        for (CustomerProduct product : getProducts())
        {
            if (product.getSku().equals(newProduct.getSku()))
            {
                product.setQuantity(product.getQuantity()+newProduct.getQuantity());
                boolean shouldBeRemoved = product.getQuantity() <= 0;
                if (shouldBeRemoved)
                {
                    getProducts().remove(product);
                    return;
                }
                wasUpdated = true;
                break;
            }
        }
        if (wasUpdated == false && newProduct.getQuantity() >0)
        {
            getProducts().add(newProduct);
        }

    }

    public float getSubTotalPrice() {
        float totalPrice = 0;
        for (CustomerProduct product : products)
        {
            totalPrice += product.getQuantity() * product.getListPrice();
        }
        return totalPrice;
    }

    public float getTotalPrice() {
        float totalPrice = 0;
        for (CustomerProduct product : products)
        {
            totalPrice += product.getQuantity() * product.getPrice();
        }
        return totalPrice - currentDiscount;
    }

    public float getDiscountValue()
    {
        return currentDiscount;
    }

    public int getTotalItemsQuantity()
    {
        int itemsQuantity = 0;
        for (CustomerProduct product : products)
        {
            itemsQuantity += product.getQuantity() ;
        }
        return itemsQuantity;
    }

    public void setDiscount(float currentCouponDiscountValue) {
        currentDiscount = currentCouponDiscountValue;
    }

    public CustomerProduct getProductBySKU(String sku) {
        for (CustomerProduct customerProduct : products)
        {
            if (customerProduct.getSku().equals(sku))
            {
                return customerProduct;
            }
        }
        return null;
    }
}
