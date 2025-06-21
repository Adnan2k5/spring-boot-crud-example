package com.javatechie.crud.example.service;

import com.javatechie.crud.example.entity.Product;
import com.javatechie.crud.example.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {
    @Autowired
    private ProductRepository repository;

    public Product saveProduct(Product product) {
        return repository.save(product);
    }

    public List<Product> saveProducts(List<Product> products) {
        return repository.saveAll(products);
    }

    public List<Product> getProducts() {
        return repository.findAll();
    }

    public Product getProductById(int id) {
        return repository.findById(id).orElse(null);
    }

    public Product getProductByName(String name) {
        return repository.findByName(name);
    }

    public String deleteProduct(int id) {
        repository.deleteById(id);
        return "product removed !! " + id;
    }

    public Product updateProduct(Product product) {
        Product existingProduct = repository.findById(product.getId()).orElse(null);
        existingProduct.setName(product.getName());
        existingProduct.setQuantity(product.getQuantity());
        existingProduct.setPrice(product.getPrice());
        return repository.save(existingProduct);
    }  
    
    //Product search with min & max price (for api v2)
    public List<Product> enhancedProductSearch(String name, Double minPrice, Double maxPrice) {
        return repository.findAll().stream()
            .filter(product -> {
                boolean matchesName = name == null || 
                    product.getName().toLowerCase().contains(name.toLowerCase());
                    boolean matchesMinPrice = minPrice == null || product.getPrice() >= minPrice;
                    boolean matchesMaxPrice = maxPrice == null || product.getPrice() <= maxPrice;
                    return matchesName && matchesMinPrice && matchesMaxPrice;
                })
        .collect(Collectors.toList());
    }
}
