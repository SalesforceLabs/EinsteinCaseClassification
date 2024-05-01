@isTest
public with sharing class CCAnalyticsWaveTemplateTest {

    static testMethod void testOnConfigurationRetrieval() {
        wavetemplate.WaveTemplateInfo template = wavetemplate.Test.getWaveTemplateInfoForApexTesting('cc_value');

        CCAnalyticsWaveTemplateConfig mod = new CCAnalyticsWaveTemplateConfig();
        mod.onConfigurationRetrieval(template);

    }

    static testMethod void testBeforeAppUpdate() {
        wavetemplate.WaveTemplateInfo template = wavetemplate.Test.getWaveTemplateInfoForApexTesting('cc_value');
        wavetemplate.Answers answers  = wavetemplate.Test.getDefaultAnswersForApexTesting('cc_value');
        
        Map<string, wavetemplate.VariableDefinition> variables = template.getVariables();
        wavetemplate.VariableDefinition ccField1 = variables.get('CC_Field1');
        wavetemplate.VariableDefinition dim1 = variables.get('FilterDimension1');
        wavetemplate.VariableDefinition dim2 = variables.get('FilterDimension2');
        wavetemplate.VariableDefinition dim3 = variables.get('FilterDimension3');
        wavetemplate.VariableDefinition dim4 = variables.get('FilterDimension4');


        //Set first cc field to type
        Map<String, Object>ccField1Value = (Map<String, Object> ) ccField1.getDefaultValue();
        ccField1Value.put('fieldName','Type');
        ccField1Value.put('sobjectName','Case');
        
        answers.put('CC_Field1',ccField1Value);
        ccField1.setComputedValue(ccField1Value);

        //Set dims to Priority, Origin, ,SuppliedEmail & Status
        Map<String, Object> dim1Value = (Map<String, Object> ) dim1.getDefaultValue();
        dim1Value.put('fieldName','Priority');
        dim1Value.put('sobjectName','Case');
        dim1.setComputedValue(dim1Value);
        //answers.put('FilterDimension1',dim1);

        Map<String, Object> dim2Value = (Map<String, Object> ) dim2.getDefaultValue();
        dim2Value.put('fieldName','Origin');
        dim2Value.put('sobjectName','Case');
        dim2.setComputedValue(dim2Value);
        //answers.put('FilterDimension2',dim2);

        Map<String, Object> dim3Value = (Map<String, Object> ) dim3.getDefaultValue();
        dim3Value.put('fieldName','SuppliedEmail');
        dim3Value.put('sobjectName','Case');
        dim3.setComputedValue(dim3Value);
        //answers.put('FilterDimension3',dim3);

        Map<String, Object> dim4Value = (Map<String, Object> ) dim4.getDefaultValue();
        dim4Value.put('fieldName','Status');
        dim4Value.put('sobjectName','Case');
        dim4.setComputedValue(dim4Value);
        //answers.put('FilterDimension4',dim4);

        
        //Test the beforeAppUpdate method in your Apex Modifier Class
        CCAnalyticsWaveTemplateConfig mod = new CCAnalyticsWaveTemplateConfig();
        mod.beforeAppCreate(template, answers);

        //Number of CC fields must be 1
        Integer numCCFields = (Integer) answers.get('CC_NumFields');
        System.assertNotEquals(0,numCCFields,'Num Fields should be greater than 0');
        System.assertEquals(1,numCCFields,'Expected Num Fields for this test = 1');
        String actualCaseStatement = (String) answers.get('Computed_ActualCaseStatement');
        System.assertNotEquals(null,actualCaseStatement,'Actual Case Statement must not be null');

        
        
        
    } 
    
    
}