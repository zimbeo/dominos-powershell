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

class Order {
    [Store]$Store
    [Customer]$Customer
    [Address]$Address
}

# Functions
function New-Address {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Street,
        [String]$StreetNumber,
        [String]$StreetName,
        [String]$UnitType,
        [String]$UnitNumber,
        [String]$City,
        [String]$Region,
        [Parameter(Mandatory=$true)]
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
        [Parameter(Mandatory=$true)]
        [String]$FirstName,
        [Parameter(Mandatory=$true)]
        [String]$LastName,
        [Parameter(Mandatory=$true)]
        [String]$Email,
        [Parameter(Mandatory=$true)]
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

function Get-Menu {
    param (
        [Parameter(Mandatory=$true)]
        [String]$StoreID
    )

    $response = Invoke-RestMethod "https://order.dominos.com/power/store/$StoreID/menu?lang=en&structured=true" -Method 'GET' -Headers $headers

    $products = $response.PreconfiguredProducts | Get-Member | Where-Object -Property MemberType -ne Method

    $menuItems = @()

    foreach ($product in $products) {
        $code = $product.Name

        $menuItem = [PSCustomObject]@{
            Code = $code
            Name = $response.PreconfiguredProducts.$code.Name
            Size = $response.PreconfiguredProducts.$code.Size
            Description = $response.PreconfiguredProducts.$code.Description
        }

        $menuItems += $menuItem
    }


    return $menuItems
}

function Set-Store {
    param (
        [Parameter(Mandatory=$true)]
        [String]$StoreID
    )

    $store = [Store]::new()
    $store.StoreID = $StoreID

    return $store
}

function New-Order {
    param (
        [Parameter(Mandatory=$true)]
        [Store]$Store,
        [Parameter(Mandatory=$true)]
        [Customer]$Customer,
        [Parameter(Mandatory=$true)]
        [Address]$Address,
        [Parameter(Mandatory=$true)]
        [String]$ProductCode
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Referer", "https://order.dominos.com/en/pages/order/")
    $headers.Add("Content-Type", "application/json")

    $body = Get-Content -Raw -Path ./order.json | ConvertFrom-Json

    $body.Order.StoreID = $Store.StoreID
    $body.Order.Email = $Customer.Email
    $body.Order.FirstName = $Customer.FirstName
    $body.Order.LastName = $Customer.LastName
    $body.Order.Phone = $Customer.Phone
    $body.Order.Address.Street = $Address.StreetNumber + " " + $Address.Street
    $body.Order.Address.City = $Address.City
    $body.Order.Address.PostalCode = $Address.PostalCode
    $body.Order.Products += @($ProductCode)

    $bodyJS = $body | ConvertTo-Json

    $response = Invoke-RestMethod 'https://order.dominos.com/power/place-order' -Method 'POST' -Headers $headers -Body $bodyJS
}