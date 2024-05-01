public class CCAnalyticsWaveTemplateConfig extends wavetemplate.WaveTemplateConfigurationModifier {

    final static private List<String> CC_FIELD_VARIABLES = new list<String> {'CC_Field1','CC_Field2','CC_Field3','CC_Field4','CC_Field5','CC_Field6','CC_Field7','CC_Field8','CC_Field9','CC_Field10'};
    final static private List<String> CC_FIELD_THRESHOLD_VARIABLES = new list<String> {'CC_Field1_Threshold','CC_Field2_Threshold','CC_Field3_Threshold','CC_Field4_Threshold','CC_Field5_Threshold','CC_Field6_Threshold','CC_Field7_Threshold','CC_Field8_Threshold','CC_Field9_Threshold','CC_Field10_Threshold'};
    final static private List<String> FILTER_VARIABLES  = new list<String> {'FilterDimension1','FilterDimension2','FilterDimension3','FilterDimension4'};
    final static private String CASE_OBJECT_API_NAME = 'Case';

    static private List<String> getAllThresholdValues (wavetemplate.Answers answers) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < 10; i++) {
            String fieldVar = CC_FIELD_VARIABLES[i];
            String thresholdVar = CC_FIELD_THRESHOLD_VARIABLES[i];
            //if CC Field was chosen, figure out threshold
            if (answers!=null && answers.get(fieldVar)!=null) {
                Map<String, Object> var =  (Map<String, Object>) answers.get(fieldVar);
                String fieldAPIName = (String) var.get('fieldName');
                if (!String.isBlank(fieldAPIName)) {
                    //get the corresponding threshold
                    List<Object> threshold = (List<Object>)answers.get(thresholdVar);
                    if (threshold!=null && threshold[0]!=null) {
                        String tValue = (String) threshold[0];
                        if (!tValue.equals('Not AutoTriaging')) 
                            result.add(tValue);
                        else {
                            result.add('101');
                        }
                    } else {
                        result.add('101');
                    }
                }
            }
        }
        return result;
    }
    static private List<String> getAllCCFields (wavetemplate.Answers answers) {
        List<String> result = new List<String>();
        for (String varName : CC_FIELD_VARIABLES) {
            if (answers!=null && answers.get(varName)!=null) {
                Map<String, Object> var =  (Map<String, Object>) answers.get(varName);
                String fieldAPIName = (String) var.get('fieldName');
                if (!String.isBlank(fieldAPIName)) {
                    result.add(fieldAPIName);
                }
            }
        }
        return result;
    }
    static private List<String> getAllFilterVariables (wavetemplate.Answers answers) {
        List<String> result = new List<String>();
        for (String varName : FILTER_VARIABLES) {
            if (answers!=null && answers.get(varName)!=null) {
                Map<String, Object> var =  (Map<String, Object>) answers.get(varName);
                String fieldAPIName = (String) var.get('fieldName');
                if (!String.isBlank(fieldAPIName)) {
                    result.add(fieldAPIName);
                }
            }
        }
        return result;
    }
    /*static private String getCCStartDateSAQLFilter (wavetemplate.Answers answers) {
        String result;

        //When did we get the first RecordInsight?
        AggregateResult[] r  = [select min(CreatedDate)minCreateDate from AIRecordInsight];
        if (r!=null) {
            Datetime minDT = (DateTime) r[0].get('minCreateDate');
            if (minDT!=null) {
                result = 'date(\'CreatedDate_Year\', \'CreatedDate_Month\', \'CreatedDate_Day\')  in ';
                result+= ' [dateRange([' + minDT.year() + ',' + minDT.month() + ',' + minDT.day() + '],[2120,11,27])]';
            }
        }
        //The output should be in this format
        //date('CreatedDate_Year', 'CreatedDate_Month', 'CreatedDate_Day')  in  [dateRange([2020,11,26], [2120,11,27])]
        return result; 
    }*/
    static private List<String> getAllDateAndNumericFields() {

        List<String> result = new List<String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(CASE_OBJECT_API_NAME);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            Schema.DescribeFieldResult r = fieldMap.get(fieldName).getDescribe();
            
            if (r!=null && fielddataType!=null && 
                (fieldDataType==Schema.DisplayType.DateTime || fieldDataType==Schema.DisplayType.Date || 
                    fieldDataType==Schema.DisplayType.Currency || fieldDataType==Schema.DisplayType.Double || 
                    fieldDataType==Schema.DisplayType.Integer  || fieldDataType==Schema.DisplayType.Long || 
                    fieldDataType==Schema.DisplayType.Percent || fieldDataType==Schema.DisplayType.Time  )) {
                
                //add to list of Date or Numeric Fields
                result.add(r.getName());
            }
        }
        return result;
    }

    private static void removeDateAndNumericFieldsFromCCVariables (wavetemplate.WaveTemplateInfo template) {
        
        Map<string, wavetemplate.VariableDefinition> variables = template.getVariables();
        List<String> allDateAndNumericFields = getAllDateAndNumericFields ();
        system.debug (allDateAndNumericFields);
        Set<String> allDateAndNumericFieldSet =  new Set<String>(allDateAndNumericFields);
        
        for (String varName : CC_FIELD_VARIABLES) {
            wavetemplate.VariableDefinition ccFieldVariable = variables.get(varName);
            ccFieldVariable.setExcludes(allDateAndNumericFieldSet);
        }

        for (String varName : FILTER_VARIABLES) {
            wavetemplate.VariableDefinition filterVariable = variables.get(varName);
            filterVariable.setExcludes(allDateAndNumericFieldSet);
        }
    }

    static private List<String> getAllLookUpFields() {

        List<String> result = new List<String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(CASE_OBJECT_API_NAME);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            Schema.DescribeFieldResult r = fieldMap.get(fieldName).getDescribe();
            
            if (r!=null && fielddataType!=null && (fieldDataType==Schema.DisplayType.Reference)) {
                //add to list of LookUp Fields
                result.add(r.getName());
            }
        }
        return result;
    }

    static private List<String> getAllLookUpFieldsFromCCVariables (List<String> ccFields) {
        List<String> allLookUpFields = getAllLookUpFields ();
        system.debug (allLookUpFields);
        Set<String> allLookUpFieldsSet =  new Set<String>(allLookUpFields);
        List<String> result = new List<String>();
        for (String ccField : ccFields) {
            //if CC LookUp was chosen, add to list of LookUp fields
                if (allLookUpFieldsSet.contains(ccField)) {
                    result.add(ccField);
                }
        } 
        return result;
    }

    static private List<String> getObjectName(List<String> lookUpFieldsNamesList) {
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<String> result = new List<String>();
        for (String lookUpFieldName : lookUpFieldsNamesList) {
            Schema.DescribeFieldResult FR = objResult.fields.getMap().get(lookUpFieldName).getDescribe();
            Schema.sObjectType sObj = FR.getReferenceTo()[0];
            Schema.DescribeSObjectResult sOobjDr=  sObj.getDescribe();
            String sObjName = sOobjDr.getName();
            result.add(sObjName);
        }
        return result;
    }

    public override void onConfigurationRetrieval(wavetemplate.WaveTemplateInfo template) {
        removeDateAndNumericFieldsFromCCVariables(template);
    }
    public override void beforeAppCreate(wavetemplate.WaveTemplateInfo waveTemplate, wavetemplate.Answers answers){

        //Get all CC fields chosen in the wizard
        List<String> ccFields = getAllCCFields(answers);
        system.debug(ccFields);
        answers.put('All_CC_Fields',ccFields);
        answers.put('CC_NumFields',ccFields.size());

        //Get list of LookUp fields chosen in Wizard
        List<String> lookUpFieldsNamesList = getAllLookUpFieldsFromCCVariables(ccFields);
        system.debug(lookUpFieldsNamesList);
        answers.put('All_Selected_LookUp_Fields_List',lookUpFieldsNamesList);

        //List<String> lookUpFieldsNamesList = new list<String> {'ailabs__Parent_Type_Lookup__c'};

        //Get total number of LookUp fields chosen in Wizard
        Integer amountOfLookUpFields = lookUpFieldsNamesList.size();
        system.debug(amountOfLookUpFields);
        answers.put('CC_LookUp_NumFields',amountOfLookUpFields);

        Set<String> allLookUpFieldsNamesSet =  new Set<String>(lookUpFieldsNamesList);

        //Get list of object name of LookUp fields chosen in Wizard
        List<String> lookUpFieldsObjectNames = getObjectName(lookUpFieldsNamesList);
        system.debug(lookUpFieldsObjectNames);
        answers.put('All_Selected_LookUp_Fields_Object_Names',lookUpFieldsObjectNames);

        //Create a case when expression for non-Lookup fields
        String actualCaseStatement  = 'case \'RI.PredictionField\' ';
        for (string ccField : ccFields ) {
            if (!allLookUpFieldsNamesSet.contains(ccField)) {
                actualCaseStatement+= 'when ' + '\"Case.'+ccField+'\"' + ' then ' + '\'RI.Case.'+ +ccField+'\'' + ' ';
            }
        }

        //Extend the case when expression to include up to 3 lookup fields
        for (Integer i = 0; i < amountOfLookUpFields; i++) {
            if (i < 3) {
                String currentLookupField = '\"Case.' + lookUpFieldsNamesList[i] + '\"';
                //String currentLookupField = '\"Case.' + lookUpFieldsNames + 'ֿֿ\"';
                Integer j = i +1;
                String nameOfJoin = 'ActualLookup' + j + '.Name';
                actualCaseStatement+= 'when ' + currentLookupField + ' then ' + '\''  + nameOfJoin + '\'' + ' ';
            }
        }

        actualCaseStatement+= ' end';
        system.debug(actualCaseStatement);
        answers.put('Computed_ActualCaseStatement',actualCaseStatement);

        


        String recommendationCaseStatement  = 'case when '  + '\'ValueType\'' + '==' + '\"Enum\"' + ' then ' +  '\'Value\'';

        //Extend the case when expression to include up to 3 lookup fields
        for (Integer i = 0; i < amountOfLookUpFields; i++) {
        //for (Integer i = 0; i < 1; i++) {
            if (i < 3) {
                String currentLookupField = '\"Case.' + lookUpFieldsNamesList[i] + '\"';
                //String currentLookupField = '\"Case.' + lookUpFieldsNames + 'ֿֿ\"';
                Integer j = i +1;
                String nameOfJoin = 'RecommendationLookup' + j + '.Name';
                recommendationCaseStatement+= ' when \'RI.PredictionField\' ==' + currentLookupField + ' then ' + '\''  + nameOfJoin + '\'' + ' ';
            }
        }

        recommendationCaseStatement+= ' else ' + '\"Invalid\"' + '  end';
        system.debug(recommendationCaseStatement);
        answers.put('Computed_RecommendationCaseStatement',recommendationCaseStatement);


        //List<String> ccFields = new List<String> {'ailabs__Case_Type_Lookup__c','ailabs__Parent_Type_Lookup__c','ailabs__Division_Lookup__c'};

        //String result;
        String predictorLabelStatement;
        Map<String,String> fieldmap;
        String objectAPIName = 'Case';
        system.debug('objectAPIName = ' + objectAPIName);
        if (objectAPIName!=null & !String.isBlank(objectAPIName)) {
            fieldmap = getAllFieldLabels (objectAPIName);
        }   
        //time to build the case statement
        if (fieldmap!=null && ccFields!=null) {
            predictorLabelStatement = 'case PredictionField  ';
            for (String fieldApiName : ccFields) {
                String fieldLabel = fieldmap.get(fieldApiName);
                if (!String.isBlank(fieldApiName) && !String.isBlank(fieldLabel)) {
                    predictorLabelStatement+= 'when ' + '\"Case.'+fieldApiName+'\"' + ' then ' + '"'+ fieldLabel + '" ';
                }
            }
            predictorLabelStatement+= ' end';
        }
        //system.debug('case statement = ' + predictorLabelStatement);
        system.debug(predictorLabelStatement);
        answers.put('Computed_PredictorLabel_Statement',predictorLabelStatement); 

        //return result;



        //eg: case 'RI.PredictionField' when "Case.ailabs__Parent_Type__c" then 'RI.Case.ailabs__Parent_Type__c' when "Case.Type" then 'RI.Case.Type' end

        //Get all CC threshold values
        List<String> thresholdValues = getAllThresholdValues(answers);
        system.debug(thresholdValues);
        answers.put('All_CC_Threshold_Fields',thresholdValues);

        //Case Confidence Statement
        String confidenceCaseStatement  = 'case \'RI.PredictionField\' ';
        for (Integer i = 0 ; i < ccFields.size();i++) {
            String ccField = ccFields[i];
            String tValue =  thresholdValues[i];
            confidenceCaseStatement+= 'when ' + '\"Case.' + ccField + '\"' + ' then ' + tValue + ' ';
        }
        
        confidenceCaseStatement+= ' end';
        system.debug(confidenceCaseStatement);
        answers.put('Computed_ConfidenceCaseStatement',confidenceCaseStatement);
        //eg: case 'RI.PredictionField' when "Case.ailabs__Parent_Type__c" then 85 when "Case.Type" then 80 end

        String recordInsightFilterStatement = 'PredictionField in [';
        for (string ccField : ccFields ) {
            recordInsightFilterStatement+= '\"Case.'+ccField+'\"' + ',';
        }
        recordInsightFilterStatement = recordInsightFilterStatement.removeEnd(',');
        recordInsightFilterStatement+= ']';
        answers.put('Computed_RIFilterStatement',recordInsightFilterStatement);
        //eg: PredictionField in ["Case.Type","Case.ailabs__Parent_Type__c"];


        //Get all filter dimensions
        List<String> filterFields = getAllFilterVariables(answers);
        system.debug(filterFields);
        answers.put('All_FilterDimension_Fields',filterFields);

        //Get Min(Date) for a REcordInsightRecord
        //SOQL Exception
        //String CCStartDT = getCCStartDateSAQLFilter(answers);
        //answers.put('Computed_CCStartDTFilterStatment',CCStartDT);

        //Get DefaultCurrency
        String currencyCode = getDefaultCurrency();
        answers.put('Computed_CurrencyCode',currencyCode);
    }  
    
    static private String getDefaultCurrency() {
        return UserInfo.getDefaultCurrency();
    }

    //returns a map of <fieldname, fieldlabel>
    static private  Map<String,String> getAllFieldLabels (String objectApiName) {
        Map<String,String> result = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType mainObjectSchema = schemaMap.get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = mainObjectSchema.getDescribe().fields.getMap();
        for (String key:fieldMap.keySet()) {
            Schema.SObjectField f = fieldMap.get(key);
            Schema.DescribeFieldResult fdesc = f.getDescribe();
            String fieldApiName = fdesc.getName();
            String fieldLabel = fdesc.getLabel();
            result.put(fieldApiName,fieldLabel);
        }
        return result;
    }
}