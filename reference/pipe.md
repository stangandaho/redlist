# Pipe operator

This operator allows for chaining commands in a more readable way.

This operator allows for chaining commands in a more readable way, while
also updating the left-hand side value.

## Usage

``` r
lhs %>% rhs

lhs %<>% rhs
```

## Value

The left-hand side value is passed to the right-hand side function.

The left-hand side value is modified by the right-hand side function and
reassigned to the left-hand side.
