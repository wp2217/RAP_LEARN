@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_ROC_D
  provider contract transactional_query
  as projection on ZI_TRAVEL_ROC_D
{
  key TravelUUID,
      TravelID,

      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyID,
      _Agency.Name       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerID,
      _Customer.LastName as CustomerName,

      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,

      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      _Status._Text.Text as OverallStatusText : localized, //系统登录语言

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_ROC_D,
      _Currency,
      _Customer,
      _Status
}
