package com.javatechie.crud.example.controller;

import com.javatechie.crud.example.entity.Product;
import com.javatechie.crud.example.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;



@RestController
public class ProductController {

    @Autowired
    private ProductService service;

    @PostMapping("/addProduct")
    public Product addProduct(@RequestBody Product product) {
        return service.saveProduct(product);
    }

    @PostMapping("/addProducts")
    public List<Product> addProducts(@RequestBody List<Product> products) {
        return service.saveProducts(products);
    }

    @GetMapping("/products")
    public List<Product> findAllProducts() {
        return service.getProducts();
    }

    @GetMapping("/productById/{id}")
    public Product findProductById(@PathVariable int id) {
        return service.getProductById(id);
    }

    @GetMapping("/product/{name}")
    public Product findProductByName(@PathVariable String name) {
        return service.getProductByName(name);
    }

    @PutMapping("/update")
    public Product updateProduct(@RequestBody Product product) {
        return service.updateProduct(product);
    }

    @DeleteMapping("/delete/{id}")
    public String deleteProduct(@PathVariable int id) {
        return service.deleteProduct(id);
    }    //endpoint with versions

    //version 1.0.0
    @GetMapping("/api/v1/health")
    public ResponseEntity<?> healthV1() {
        return ResponseEntity.ok().body("v1 Health : GOOD");
    }

    @GetMapping("/api/v1/products")
    public List<Product> findAllProductsV1() {
        return service.getProducts();
    }

    //version 1.1.0
    @GetMapping("/api/v1.1/health")
    public ResponseEntity<?> healthV1_1() {
        return ResponseEntity.ok().body("v1.1 Health : GOOD");
    }

    @GetMapping("/api/v1.1/products")
    public List<Product> findAllProductsV1_1() {
        return service.getProducts();
    }

    @GetMapping("/api/v1.1/products/search")
    public ResponseEntity<?> searchV1_1(@RequestParam String keyword) {
        try {
            Product product = service.getProductByName(keyword);
            if (product != null) {
                return ResponseEntity.ok().body(product);
            } else {
                return ResponseEntity.status(404).body("Product not found");
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error occurred: " + e.getMessage());
        }
    }
    
}
