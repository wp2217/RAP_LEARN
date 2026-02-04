@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view'
//@Metadata.ignorePropagatedAnnotations: true  注释掉Interface Entity 定义的Lable才能显示

@UI.headerInfo: {
    typeName: 'SM30 Data Maintain',
    typeNamePlural: 'SM30Data',
    title: {
    type: #STANDARD,
    label: 'Ture SM30 Data',
    value: 'Param'
    }
}

define view entity ZC_SM30_ROC
  as projection on ZI_SM30_ROC
{

      @UI.facet: [{ 
                          type: #IDENTIFICATION_REFERENCE
                          } ]

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{  position: 10 }]
  key Param,
      SM30SingletonField,

      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{  position: 20 }]
      Description,

      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{  position: 30 }]
      Value,

      @UI.lineItem: [{ position: 40}]
      @UI.identification: [{  position: 40 }]
      Active,

      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{  position: 50 }]
      Locallastchangedat,

      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{  position: 60 }]
      Lastchangedat,
      /* Associations */
      _SM30_SINGLETON : redirected to parent ZC_SM30_SINGLETON
}
