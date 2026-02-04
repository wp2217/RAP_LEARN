@EndUserText.label: 'Custom Entity for ALV Display'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_TRAVL_ALV_ROC' 
@Metadata.allowExtensions: true
define custom entity ZI_TRAVL_ALV_ROC   // data from talbe ztravel_roc_m
// with parameters parameter_name : parameter_type
{
 key travel_id   : /dmo/travel_id;
  agency_id       : /dmo/agency_id;
  customer_id     : /dmo/customer_id;
  begin_date      : /dmo/begin_date;
  end_date        : /dmo/end_date;
  @Semantics.amount.currencyCode: 'currency_code'
  booking_fee     : /dmo/booking_fee;
  @Semantics.amount.currencyCode: 'currency_code'
  total_price     : /dmo/total_price;
  currency_code   : /dmo/currency_code;
  description     : /dmo/description;
  overall_status  : /dmo/travel_status;
  created_by      : abp_creation_user;
  created_at      : abp_creation_tstmpl;
//  last_changed_by : abp_locinst_lastchange_user;
//  last_changed_at : abp_locinst_lastchange_tstmpl;
  
}
