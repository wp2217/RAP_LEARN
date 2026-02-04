@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_ROC_M
  as projection on ZI_BOOKSUPPL_ROC_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementDesc' ]
      SupplementId,
      _SupplementText.Description as SupplementDesc:localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking:redirected to parent ZC_BOOKING_ROC_M,
      _Supplement,
      _SupplementText,
      _Travel:redirected to ZC_TRAVEL_ROC_M
}
