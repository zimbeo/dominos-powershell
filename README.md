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

Check out some menu items for the store you choose
```
Get-Menu -StoreID 4336
```

Create a store object to define which store you would like to use. StoreID can be retreived from ``Get-NearbyStores``
```
$store = Set-Store -StoreID 4336
```
