@EndUserText.label: 'Root Abstract GET GR Paramas'
define root abstract entity ZD_ROC_GETGR_PARAMS_ROOT
{
  dummy  : abap.char(1);
  _items : composition [0..*] of ZD_ROC_GETGR_PARAMS;

}
