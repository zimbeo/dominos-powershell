# Dominos PowerShell Wrapper

Import the .psm1

```
Import-Module Dominos.psm1
```

Create a cusomter and an address object
```
$customer = New-Customer -FirstName "Joe" -LastName "Biden" -Email "joe@whitehouse.gov" -Phone "2024561111"
$address = New-Address -Street "Pennsylvania Avenue NW" -StreetNumber "1600" -PostalCode "20500"
```

Find stores nearby your address
```
Get-NearbyStores -Address $address | Format-Table
```

Create a store object to define which store you would like to use
```
$store = Get-Store -StoreID 4336 -Address $address
```

Check out some menu items for the store you choose
```
Get-Menu -StoreID 4336
```

Create a cart object to store products you want. You can do that all at once or add as you shop. Item codes are retrieved from `Get-Menu`
```
# Creating a cart and adding upon creation
$cart = New-Cart -Prodcuts @("20BCOKE", "P12IPAZA")

# Creating a cart and adding items to it as you go
$cart = New-Cart
Add-Item -Cart $cart -Product "20BCOKE"
```

Create an Order, providing a store, your customer details, address, your cart, as well as your payment information
```
$order = Initialize-Order -Store $store -Customer $customer -Address $address -Cart $cart
```

Place your order using the previously created order
```
New-Order -Order $order
```