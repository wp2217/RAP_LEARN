@EndUserText.label: 'Universal Domain Value Help'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ROC_DOMAIN_VH'

@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
//custom entity不能用作CDS entity的association
define custom entity ZI_ROC_DOMAIN_VH
{

      @ObjectModel.text.element: [ 'Text' ]
  key Value      : abap.char(10);

      @Search.defaultSearchElement: true
      Text       : abap.char(60);

      @UI.hidden : true
      DomainName : sxco_ad_object_name;

}
