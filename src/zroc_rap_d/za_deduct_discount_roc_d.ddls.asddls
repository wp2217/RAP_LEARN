@EndUserText.label: 'Abstract entity for Deduct discount'
define abstract entity ZA_DEDUCT_DISCOUNT_ROC_D
  //with parameters parameter_name : parameter_type
{
  discount  : abap.int1;

  @Consumption.valueHelpDefinition: [{
    entity  : {
    name    : '/DMO/I_Overall_Status_VH',
    element : 'OverallStatus'
  }}]
  testfield : /dmo/overall_status;
}
