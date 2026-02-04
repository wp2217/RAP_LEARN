@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booksuppl with draft'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_ROC_D
  as projection on ZI_BOOKSUPPL_ROC_D
{
  key BooksupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,

      @ObjectModel.text.element: [ 'SupplementDesc' ]
      SupplementID,
      _SupplementText.Description as SupplementDesc : localized,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking: redirected to parent ZC_BOOKING_ROC_D,
      _Supplement,
      _SupplementText,
      _Travel : redirected to ZC_TRAVEL_ROC_D
}
