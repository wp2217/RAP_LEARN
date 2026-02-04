@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_ROC_U 
 provider contract transactional_query
as projection on ZI_TRAVEL_ROC_U
{
  key TravelId,
  AgencyId,
  CustomerId,
  BeginDate,
  EndDate,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  BookingFee,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  TotalPrice,
  CurrencyCode,
  Description,
  OverallStatus,
  LastChangedAt,
  /* Associations */
  _Agency,
  _Booking:redirected to composition child ZC_BOOKING_ROC_U,
  _Currency,
  _Customer,
  _Status
}
