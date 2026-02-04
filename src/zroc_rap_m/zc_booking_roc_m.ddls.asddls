@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booking Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_ROC_M as projection on ZI_BOOKING_ROC_M
{
    key TravelId,
    key BookingId,
    BookingDate,
     @ObjectModel.text.element: [ 'CustomerName' ]
    CustomerId,
    _Customer.LastName as CustomerName,
     @ObjectModel.text.element: [ 'CarrierName' ]
    CarrierId,
    _Carrier.Name as CarrierName,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
     @ObjectModel.text.element: [ 'BookingStatusText' ]
    BookingStatus,
    _Booking_Status._Text.Text as BookingStatusText :localized,
    LastChangedAt,
    /* Associations */
    _Booking_Status,
    _BookSuppl: redirected to composition child ZC_BOOKSUPPL_ROC_M,
    _Carrier,
    _Connection, 
    _Customer,
    _Travel:redirected to parent ZC_TRAVEL_ROC_M
}
