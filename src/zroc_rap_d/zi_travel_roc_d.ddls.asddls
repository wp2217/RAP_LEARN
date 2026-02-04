@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel data with draft'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRAVEL_ROC_D
  as select from /dmo/a_travel_d
  composition [0..*] of ZI_BOOKING_ROC_D         as _Booking
  association [0..1] to /DMO/I_Agency            as _Agency   on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to I_Currency               as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to /DMO/I_Overall_Status_VH as _Status   on $projection.OverallStatus = _Status.OverallStatus
{
  key travel_uuid           as TravelUUID,
      travel_id             as TravelID,
      agency_id             as AgencyID,
      customer_id           as CustomerID,
      begin_date            as BeginDate,
      end_date              as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee           as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price           as TotalPrice,
      currency_code         as CurrencyCode,
      description           as Description,
      overall_status        as OverallStatus,
      
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true 
      local_last_changed_at as LocalLastChangedAt,   //for Etag
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,  //for total Etag

      //Compoment
      _Booking,
      //Assosiation
      _Agency,
      _Customer,
      _Currency,
      _Status
}
