@EndUserText.label: 'Abstract Entity for Create Action Params'
define root abstract entity ZD_ROC_CREATE_PARAMS
  // with parameters parameter_name : parameter_type
{
  
  CompanyCode  : bukrs;

  @Consumption.valueHelpDefinition: [{
    entity     : {
    name       : 'ZI_ROC_SETTLE_TYPE_VH',
    element    : 'Code'
  }}]
  SettleType   : zeroc_settle_type;

  @Consumption.valueHelpDefinition: [{
    entity     : {
    name       : 'ZI_ROC_INV_BUS_TYPE_VH',
    element    : 'Code'
  }}]
  BusinessType : zeroc_inv_bus_type;

}
