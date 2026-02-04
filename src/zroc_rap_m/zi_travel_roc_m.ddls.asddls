@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View of Travel Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_TRAVEL_ROC_M
  as select from ztravel_roc_m
  composition [0..*] of ZI_BOOKING_ROC_M         as _Booking
  association [0..1] to /DMO/I_Agency            as _Agency   on $projection.AgencyId = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to I_Currency               as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to /DMO/I_Overall_Status_VH as _Status   on $projection.OverallStatus = _Status.OverallStatus

{
  key travel_id       as TravelId,
      agency_id       as AgencyId,
      customer_id     as CustomerId,
      begin_date      as BeginDate,
      end_date        as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode' 
      booking_fee     as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,
      currency_code   as CurrencyCode,
      description     as Description,
      overall_status  as OverallStatus,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true  //for Etag
      last_changed_at as LastChangedAt,

      //Compoment
      _Booking,
      //Assosiation
      _Agency,
      _Customer,
      _Currency,
      _Status
}
