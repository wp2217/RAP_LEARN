@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View of Booking Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BOOKING_ROC_U
  as select from /dmo/booking as Booking
  association        to parent ZI_TRAVEL_ROC_U as _Travel     on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer        as _Customer   on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier         as _Carrier    on  $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection      as _Connection on  $projection.CarrierId    = _Connection.AirlineID
                                                              and $projection.ConnectionId = _Connection.ConnectionID
{
  key travel_id     as TravelId,
  key booking_id    as BookingId,
      booking_date  as BookingDate,
      customer_id   as CustomerId,
      carrier_id    as CarrierId,
      connection_id as ConnectionId,
      flight_date   as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price  as FlightPrice,
      currency_code as CurrencyCode,

      _Travel,
      _Customer,
      _Carrier,
      _Connection
}
