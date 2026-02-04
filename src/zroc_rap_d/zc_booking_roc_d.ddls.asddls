@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booking with draft'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_ROC_D
  as projection on ZI_BOOKING_ROC_D
{
  key BookingUUID,
      TravelUUID,
      
      
      BookingID,
      BookingDate,

      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerID,
      _Customer.LastName         as CustomerName,

      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierID,
      _Carrier.Name              as CarrierName,

      ConnectionID,
      FlightDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,

      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _Booking_Status._Text.Text as BookingStatusText : localized,

      LocalLastChangedAt,
      /* Associations */
      _Booking_Status,
      _BookSuppl: redirected to composition child ZC_BOOKSUPPL_ROC_D,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZC_TRAVEL_ROC_D
}
