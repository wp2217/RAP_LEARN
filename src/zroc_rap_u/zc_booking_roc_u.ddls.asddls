@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_ROC_U 
// provider contract transactional_query
 as projection on ZI_BOOKING_ROC_U
{
  key TravelId,
  key BookingId,
  BookingDate,
  CustomerId,
  CarrierId,
  ConnectionId, 
  FlightDate,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  FlightPrice,
  CurrencyCode,
  /* Associations */
  _Carrier,
  _Connection,
  _Customer,
  _Travel: redirected to parent ZC_TRAVEL_ROC_U
}
