# Student Database Connection Guide

## 🎯 Quick Start: Connecting to PostgreSQL from R

### Basic Connection
```r
library(DBI)
library(RPostgres)

# Connect to the student database
con <- dbConnect(RPostgres::Postgres(), 
                 host = "localhost",
                 dbname = "student",
                 user = "student",
                 password = "")
```

### 📊 Available Demo Databases

#### Northwind Database (E-commerce)
```r
# List all customers
customers <- dbGetQuery(con, "SELECT * FROM northwind.customers")

# Get order details
orders <- dbGetQuery(con, "SELECT * FROM northwind.orders LIMIT 10")

# Product information
products <- dbGetQuery(con, "SELECT * FROM northwind.products")
```

#### Sakila Database (DVD Rental)
```r
# List all actors
actors <- dbGetQuery(con, "SELECT * FROM sakila.actor")

# Get film information
films <- dbGetQuery(con, "SELECT * FROM sakila.film LIMIT 10")

# Customer rentals
rentals <- dbGetQuery(con, "SELECT * FROM sakila.rental LIMIT 10")
```

### 🔍 Exploring Database Structure

```r
# List all tables in Northwind schema
northwind_tables <- dbGetQuery(con, "
  SELECT table_name 
  FROM information_schema.tables 
  WHERE table_schema = 'northwind'
")

# List all tables in Sakila schema
sakila_tables <- dbGetQuery(con, "
  SELECT table_name 
  FROM information_schema.tables 
  WHERE table_schema = 'sakila'
")

# Describe a table structure
dbGetQuery(con, "
  SELECT column_name, data_type 
  FROM information_schema.columns 
  WHERE table_schema = 'northwind' AND table_name = 'customers'
")
```

### 📈 Data Analysis Examples

#### Example 1: Northwind Customer Analysis
```r
library(dplyr)

# Get customer data
customers_df <- dbGetQuery(con, "SELECT * FROM northwind.customers")

# Convert to tibble for better dplyr support
customers_tbl <- as_tibble(customers_df)

# Analyze customers by country
customer_summary <- customers_tbl %>%
  group_by(country) %>%
  summarise(customer_count = n()) %>%
  arrange(desc(customer_count))

print(customer_summary)
```

#### Example 2: Sakila Film Analysis
```r
# Get film data
films_df <- dbGetQuery(con, "SELECT * FROM sakila.film")

# Analyze films by rating
film_summary <- films_df %>%
  group_by(rating) %>%
  summarise(
    count = n(),
    avg_length = mean(length, na.rm = TRUE),
    avg_rental_rate = mean(rental_rate, na.rm = TRUE)
  ) %>%
  arrange(desc(count))

print(film_summary)
```

### 🎨 Data Visualization

```r
library(ggplot2)

# Visualize customer distribution by country
customers_tbl %>%
  group_by(country) %>%
  summarise(count = n()) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(country, count), y = count)) +
  geom_col() +
  coord_flip() +
  labs(title = "Top 10 Countries by Customer Count",
       x = "Country", y = "Number of Customers")
```

### 🚀 Advanced Queries

#### Join Operations
```r
# Join customers with orders (Northwind)
customer_orders <- dbGetQuery(con, "
  SELECT c.company_name, c.country, COUNT(o.order_id) as order_count
  FROM northwind.customers c
  LEFT JOIN northwind.orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_id, c.company_name, c.country
  ORDER BY order_count DESC
  LIMIT 10
")

# Join actors with films (Sakila)
actor_films <- dbGetQuery(con, "
  SELECT a.first_name, a.last_name, COUNT(fa.film_id) as film_count
  FROM sakila.actor a
  JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
  GROUP BY a.actor_id, a.first_name, a.last_name
  ORDER BY film_count DESC
  LIMIT 10
")
```

### 🔧 Best Practices

1. **Always close connections**:
```r
# Close the connection when done
dbDisconnect(con)
```

2. **Use parameterized queries** for safety:
```r
# Safe way to query with parameters
customer_id <- "ALFKI"
result <- dbGetQuery(con, 
  "SELECT * FROM northwind.customers WHERE customer_id = $1",
  params = list(customer_id))
```

3. **Handle large datasets efficiently**:
```r
# For large datasets, use chunking
large_result <- dbSendQuery(con, "SELECT * FROM large_table")
while (!dbHasCompleted(large_result)) {
  chunk <- dbFetch(large_result, n = 1000)
  # Process chunk
}
dbClearResult(large_result)
```

### 🆘 Troubleshooting

#### Connection Issues
```r
# Test if PostgreSQL is running
system("bash scripts/test_student_db.sh")

# Or check connection manually
tryCatch({
  con <- dbConnect(RPostgres::Postgres(), 
                   host = "localhost",
                   dbname = "student",
                   user = "student",
                   password = "")
  print("Connection successful!")
  dbDisconnect(con)
}, error = function(e) {
  print(paste("Connection failed:", e$message))
})
```

#### Package Issues
```r
# Install missing packages
install.packages(c("DBI", "RPostgres", "dplyr", "ggplot2"))

# Or use conda
system("conda install -c conda-forge r-dbi r-rpostgres")
```

---

**Happy coding!** 🎉 Use this guide to get started with database analysis in your assignments.
