Set-Location -Path "C:\scripts\dominos-powershell"
Import-Module .\Dominos.psm1

$customer = New-Customer -FirstName "Joe" -LastName "Biden" -Email "joe@whitehouse.gov" -Phone "2024561111"
$address = New-Address -Street "Pennsylvania Avenue NW" -StreetNumber "1600" -PostalCode "20500"

$store = Get-Store -StoreID 4336 -Address $address

$cart = New-Cart
Add-Item -Cart $cart -Product "20BCOKE"

$payment = New-Payment -Number "4100123422343234" -Expiration "0115" -Cvv "777" -Zip "90210" 

$order = Initialize-Order -Store $store -Customer $customer -Address $address -Cart $cart -Payment $payment

New-Order -Order $order
