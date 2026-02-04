@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement data with draft'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKSUPPL_ROC_D
  as select from /dmo/a_bksuppl_d

  association        to parent ZI_BOOKING_ROC_D as _Booking        on $projection.BookingUUID = _Booking.BookingUUID
  association [1..1] to ZI_TRAVEL_ROC_D         as _Travel         on $projection.TravelUUID = _Travel.TravelUUID
  association [1..1] to /DMO/I_Supplement       as _Supplement     on $projection.SupplementID = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText   as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID

{
  key booksuppl_uuid        as BooksupplUUID,
      root_uuid             as TravelUUID, //Travel UUID
      parent_uuid           as BookingUUID, //Booking UUID
      booking_supplement_id as BookingSupplementID,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Travel,
      _Booking,
      _Supplement,
      _SupplementText
}
