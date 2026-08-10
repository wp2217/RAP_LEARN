@ObjectModel.dataCategory: #VALUE_HELP
@EndUserText.label: 'Business Type F4'
@Search.searchable: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.resultSet.sizeCategory: #XS  //数据量比较少，Fiori界面会按照下拉列表显示
define view entity ZI_ROC_SETTLE_STATUS_VH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZDROC_SETTLE_STATUS' )   as Val
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDROC_SETTLE_STATUS' ) as Txt on  Txt.domain_name    = Val.domain_name
                                                                                                and Txt.value_position = Val.value_position
                                                                                                and Txt.language       = $session.system_language
{
  key Val.value_low as Code,
      @Search.defaultSearchElement: true
      Txt.text      as Text
}
