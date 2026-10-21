@EndUserText.label: 'Root Abstract GET GR Paramas'
define root abstract entity ZD_ROC_GETGR_PARAMS_ROOT
{
      @EndUserText.label: 'Purchase Order Type'
  key PurchaseOrderType : abap.char(5);

      @EndUserText.label: 'Purchase Order'
  key PurchaseOrder     : abap.char(10);
      _items            : composition [0..*] of ZD_ROC_GETGR_PARAMS;

}
