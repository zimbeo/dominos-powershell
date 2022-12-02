# Classes
class Address {
    [String]$Street
    [String]$StreetNumber
    [String]$StreetName
    [String]$UnitType
    [String]$UnitNumber
    [String]$City
    [String]$Region
    [String]$PostalCode
    [String]$CountyNumber
    [String]$CountyName
}

class Customer {
    [String]$FirstName
    [String]$LastName
    [String]$Email
    [String]$Phone
}

class Store {
    [String]$AddressDescription
    [String]$AllowCarryoutOrders
    [String]$AllowDeliveryOrders
    [String]$AllowDuc
    [String]$AllowPickupWindowOrders
    [String]$ContactlessCarryout
    [String]$ContactlessDelivery
    [String]$HolidaysDescription
    [String]$HoursDescription
    [String]$IsDeliveryStore
    [String]$IsNEONow
    [String]$IsOnlineCapable
    [String]$IsOnlineNow
    [String]$IsOpen
    [String]$IsSpanish
    [String]$LanguageLocationInfo
    [String]$LocationInfo
    [String]$MaxDistance
    [String]$MinDistance
    [String]$Phone
    [String]$ServiceHoursDescription
    [String]$ServiceIsOpen
    [String]$ServiceMethodEstimatedWaitMinutes
    [String]$StoreCoordinates
    [String]$StoreID
}

class Cart {
    [String[]]$Products

    [void] AddProduct([String]$product) {
        $this.Products += $product
    }
}

class Payment{
    [String]$Number
    [String]$Expiration
    [String]$Cvv
    [String]$Zip
}

# Functions
function New-Address {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Street,
        [String]$StreetNumber,
        [String]$StreetName,
        [String]$UnitType,
        [String]$UnitNumber,
        [String]$City,
        [String]$Region,
        [Parameter(Mandatory = $true)]
        [String]$PostalCode,
        [String]$CountyNumber,
        [String]$CountyName
    )

    $address = [Address]::new()
    $address.Street = $Street
    $address.StreetNumber = $StreetNumber
    $address.UnitType = $UnitType
    $address.UnitNumber = $UnitNumber
    $address.City = $City
    $address.Region = $Region
    $address.PostalCode = $PostalCode
    $address.CountyNumber = $CountyNumber
    $address.CountyName = $CountyName

    return $address
}

function New-Customer {
    param (
        [Parameter(Mandatory = $true)]
        [String]$FirstName,
        [Parameter(Mandatory = $true)]
        [String]$LastName,
        [Parameter(Mandatory = $true)]
        [String]$Email,
        [Parameter(Mandatory = $true)]
        [String]$Phone
    )

    $customer = [Customer]::new()
    $customer.FirstName = $FirstName
    $customer.LastName = $LastName
    $customer.Email = $Email
    $customer.Phone = $Phone

    return $customer
}

function Get-NearbyStores {
    param (
        [Address]$Address
    )
    
    $street = $Address.Street
    $postalCode = $Address.PostalCode

    $response = Invoke-RestMethod "https://order.dominos.com/power/store-locator?s=$street&c=$postalCode" -Method 'GET' -Headers $headers

    $stores = $response.Stores | Where-Object -Property IsOpen -eq "true"

    return $stores
}

function Get-Store {
    param (
        [Parameter(Mandatory = $true)]
        [String]$StoreID,
        [Parameter(Mandatory = $true)]
        [Address]$Address
    )

    $street = $Address.Street
    $postalCode = $Address.PostalCode

    $response = Invoke-RestMethod "https://order.dominos.com/power/store-locator?s=$street&c=$postalCode" -Method 'GET' -Headers $headers

    $stores = $response.Stores | Where-Object -Property IsOpen -eq "true"
    $stores = $stores | Where-Object -Property StoreID -eq $StoreID

    $store = [Store]::new()
    $store.StoreID = $stores.StoreID
    $store.AddressDescription = $stores.AddressDescription
    $store.AllowCarryoutOrders = $stores.AllowCarryoutOrders
    $store.AllowDeliveryOrders = $stores.AllowDeliveryOrders
    $store.AllowDuc = $stores.AllowDuc
    $store.AllowPickupWindowOrders = $stores.AllowPickupWindowOrders
    $store.ContactlessCarryout = $stores.ContactlessCarryout
    $store.ContactlessDelivery = $stores.ContactlessDelivery
    $store.HolidaysDescription = $stores.HolidaysDescription
    $store.HoursDescription = $stores.HoursDescription
    $store.IsDeliverystore = $stores.IsDeliveryStore
    $store.IsNEONow = $stores.IsNEONow
    $store.IsOnlineCapable = $stores.IsOnlineCapable
    $store.IsOnlineNow = $stores.IsOnlineNow
    $store.IsOpen = $stores.IsOpen
    $store.IsSpanish = $stores.IsSpanish
    $store.LanguageLocationInfo = $stores.LanguageLocationInfo
    $store.LocationInfo = $stores.LocationInfo
    $store.MaxDistance = $stores.MaxDistance
    $store.MinDistance = $stores.MinDistance
    $store.Phone = $stores.Phone
    $store.ServiceHoursDescription = $stores.ServiceHoursDescription
    $store.ServiceIsOpen = $stores.ServiceIsOpen
    $store.ServiceMethodEstimatedWaitMinutes = $stores.ServiceMethodEstimatedWaitMinutes
    $store.StoreCoordinates = $stores.StoreCoordinates

    return $store

}

function Get-Menu {
    param (
        [Parameter(Mandatory = $true)]
        [String]$StoreID
    )

    $response = Invoke-RestMethod "https://order.dominos.com/power/store/$StoreID/menu?lang=en&structured=true" -Method 'GET' -Headers $headers

    $products = $response.PreconfiguredProducts | Get-Member | Where-Object -Property MemberType -ne Method

    $menuItems = @()

    foreach ($product in $products) {
        $code = $product.Name

        $menuItem = [PSCustomObject]@{
            Code        = $code
            Name        = $response.PreconfiguredProducts.$code.Name
            Size        = $response.PreconfiguredProducts.$code.Size
            Description = $response.PreconfiguredProducts.$code.Description
        }

        $menuItems += $menuItem
    }


    return $menuItems
}

# Fix this, shit broke when adding items on create
function New-Cart {
    param (
        [String[]]$Products
    )
    
    $cart = [Cart]::new()
    $cart.Products = $Products

    return $cart
}

function Add-Item {
    param(
        [Parameter(Mandatory = $true)]
        [Cart]$Cart,
        [Parameter(Mandatory =$true)]
        [String]$Product
    )

    $cart.AddProduct($Product)

    return $cart
}

function New-Payment {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Number,
        [Parameter(Mandatory = $true)]
        [String]$Expiration,
        [Parameter(Mandatory = $true)]
        [String]$Cvv,
        [Parameter(Mandatory = $true)]
        [String]$Zip
    )

    $payment = [Payment]::new()
    $payment.Number = $Number
    $payment.Expiration = $Expiration
    $payment.Cvv = $Cvv
    $payment.Zip = $Zip

    return $payment
}

function Initialize-Order {
    param (
        [Parameter(Mandatory = $true)]
        [Store]$Store,
        [Parameter(Mandatory = $true)]
        [Customer]$Customer,
        [Parameter(Mandatory = $true)]
        [Address]$Address,
        [Parameter(Mandatory = $true)]
        [Cart]$Cart,
        [Parameter(Mandatory = $true)]
        [Payment]$Payment
    )

    $card = [PSCustomObject]@{
        Type = "CreditCard"
        Expiration = $Payment.Expiration
        Amount = "15.00"
        CardType = "Visa"
        Number = $Payment.Number
        SecurityCode = $Payment.Cvv
        PostalCode = $Payment.Zip
    }

    $cardJS = $card | ConvertTo-Json

    $body = Get-Content -Raw -Path ./order.json | ConvertFrom-Json

    $body.Order.StoreID = $Store.StoreID
    $body.Order.Email = $Customer.Email
    $body.Order.FirstName = $Customer.FirstName
    $body.Order.LastName = $Customer.LastName
    $body.Order.Phone = $Customer.Phone
    $body.Order.Address.Street = $Address.Street
    $body.Order.Address.City = $Address.City
    $body.Order.Address.Region = $Address.Region
    $body.Order.Address.PostalCode = $Address.PostalCode
    $body.Order.Products = $Cart.Products
    $body.Order.Payments += $cardJS

    return $body    
}

function New-Order {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object]$Order
    )

    # Dominos API requires this Referer Header
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Referer", "https://order.dominos.com/en/pages/order/")
    $headers.Add("Content-Type", "application/json")

    # We need to send the body as a JSON String, not a PowerShell object
    $bodyJS = $Order | ConvertTo-Json

    $response = Invoke-RestMethod 'https://order.dominos.com/power/place-order' -Method 'POST' -Headers $headers -Body $bodyJS

    return $response
}