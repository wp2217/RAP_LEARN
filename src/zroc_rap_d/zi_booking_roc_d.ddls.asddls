@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking data with draft'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKING_ROC_D
  as select from /dmo/a_booking_d
  composition [0..*] of ZI_BOOKSUPPL_ROC_D       as _BookSuppl
  association        to parent ZI_TRAVEL_ROC_D          as _Travel  on  $projection.TravelUUID = _Travel.TravelUUID
  association [1..1] to /DMO/I_Customer          as _Customer       on  $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier        on  $projection.CarrierID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection     on  $projection.CarrierID    = _Connection.AirlineID
                                                                    and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _Booking_Status on  $projection.BookingStatus = _Booking_Status.BookingStatus
{
  key booking_uuid          as BookingUUID,
      parent_uuid           as TravelUUID, //Travel UUID
      booking_id            as BookingID,
      booking_date          as BookingDate,
      customer_id           as CustomerID,
      carrier_id            as CarrierID,
      connection_id         as ConnectionID,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _BookSuppl,
      _Travel,
      _Customer,
      _Carrier,
      _Connection,
      _Booking_Status
}
