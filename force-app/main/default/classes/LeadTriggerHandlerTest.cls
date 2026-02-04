@IsTest
public with sharing class LeadTriggerHandlerTest {
    @testSetup
        static void setUpData(){
            Lead ld1 = new Lead(FirstName = 'Test', LastName = 'User1', Company = 'ABC', Title = 'vp', LeadSource = 'Website', Email = 'abc@example.com', Phone = '987654321', Industry = 'Technology');
            Lead ld2 = new Lead(FirstName = 'Test', LastName = 'User2', Company = 'XYZ', Title = 'mgr', LeadSource = 'Website', Email = 'xyz@example.com', Phone = null, Industry = 'Finance');
            Lead ld3 = new Lead(FirstName = 'Test', LastName = 'User3', Company = 'PQR', Title = 'exec', LeadSource = 'Website', Email = 'pqr@example.com');
            Lead ld4 = new Lead(FirstName = 'Test', LastName = 'User4', Company = 'TAB', Title = 'jr', LeadSource = 'Website', Email = 'tab@example.com');

            Lead ld5 = new Lead(FirstName = 'Test', LastName = 'User5', Company = 'LMN', Title = 'software engineer', LeadSource = 'Phone Inquiry', Email = null, Phone = null, Industry = 'Finance');
            Lead ld6 = new Lead(FirstName = 'Test', LastName = 'User6', Company = 'OPQ', Title = 'intern', LeadSource = 'Phone Inquiry');
            Lead ld7 = new Lead(FirstName = 'Test', LastName = 'User7', Company = 'RST', Title = 'developer', LeadSource = 'Phone Inquiry');

            Lead ld8 = new Lead(FirstName = 'Test', LastName = 'User8', Company = 'AAA', Title = 'VP of Sales'); 
            Lead ld9 = new Lead(FirstName = 'Test', LastName = 'User9', Company = 'BBB', Title = 'assistant manager');
            Lead ld10 = new Lead(FirstName = 'Test', LastName = 'User10', Company = 'CCC', Title = 'chief exec');
            
            Lead ld11 = new Lead(FirstName = 'Test', LastName = 'UserNull', Company = 'DDD', Title = null, LeadSource = null, Email = null, Phone = null, Industry = null);
            Lead ld12 = new Lead(FirstName = 'Test', LastName = 'UserEmpty', Company = 'EEE', Title = '', LeadSource = '', Email = '');

            List<Lead> leadsList = new List<Lead>{ld1,ld2,ld3,ld4,ld5, ld6, ld7, ld8, ld9, ld10, ld11, ld12};
            insert leadsList;
        }
    @IsTest
        public static void leadTriggerHandler_testHandleTitleNormalization_Positive(){
            List<Lead> leadsForTest = [SELECT Id, LastName, Title FROM Lead WHERE LastName LIKE 'User%'];
            LeadTriggerHandler.handleTitleNormalization(leadsForTest);
            for(Lead ld : leadsForTest){
                if(ld.LastName == 'User1'){
                    Assert.areEqual('Vice President', ld.Title, 'User1 should be normalized to Vice President');
                }
                else if(ld.LastName == 'User2'){
                    Assert.areEqual('Manager', ld.Title, 'User2 should be normalized to Manager');
                }
                else if (ld.LastName == 'User3'){
                    Assert.areEqual('Executive', ld.Title, 'User3 should be normalized to Executive');
                }
                else if (ld.LastName == 'User4'){
                    Assert.areEqual('Assistant', ld.Title, 'User4 should be normalized to Assistant');
                }
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleTitleNormalization_NegativeCases(){
            List<Lead> leadsForTest = [SELECT Id, LastName, Title FROM Lead WHERE LastName LIKE 'User%'];
            LeadTriggerHandler.handleTitleNormalization(leadsForTest);
            for(Lead ld: leadsForTest){
                if(ld.LastName == 'User5'){
                    Assert.areEqual('software engineer', ld.Title, 'User5 should remain unchanged');
                }
                else if(ld.LastName == 'User6'){
                    Assert.areEqual('intern', ld.Title, 'User6 should remain unchanged');
                }
                else if(ld.LastName == 'User7'){
                    Assert.areEqual('developer', ld.Title, 'User7 should remain unchanged');
                }
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleTitleNormalization_EdgeCases(){
            List<Lead> leadsForTest = [SELECT Id, LastName, Title FROM Lead WHERE LastName LIKE 'User%'];
            LeadTriggerHandler.handleTitleNormalization(leadsForTest);
            for(Lead ld: leadsForTest){
                if(ld.LastName == 'User8'){
                    Assert.areEqual('Vice President', ld.Title, 'VP of Sales should be changed to Vice President');
                }
                else if(ld.LastName == 'User9'){
                    Assert.areEqual('Manager', ld.Title, 'assistant manager should be changed to Manager');
                }
                else if(ld.LastName == 'User10'){
                    Assert.areEqual('Executive', ld.Title, 'chief exec should be changed to Executive');
                }
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleTitleNormalization_NullEmptyCases(){
            List<Lead> leadsForTest = [SELECT Id, LastName, Title FROM Lead WHERE LastName IN ('UserNull', 'UserEmpty')];
            LeadTriggerHandler.handleTitleNormalization(leadsForTest);
            for(Lead ld: leadsForTest){
                if(ld.LastName == 'UserNull'){
                    Assert.areEqual(null, ld.Title, 'Title remains null');
                }
                else if(ld.LastName == 'UserEmpty'){
                    Assert.areEqual(null, ld.Title, 'Title remains null for empty string');
                }
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleAutoLeadScoring_Positive(){
            List<Lead> leadsList = [SELECT Id, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE LeadSource = 'Website' AND 
                                                                                                                Email != null AND 
                                                                                                                Phone != null AND 
                                                                                                                Industry = 'Technology'];
            LeadTriggerHandler.handleAutoLeadScoring(leadsList);
            for(Lead ld : leadsList){
                Assert.areEqual(18, ld.Lead_Score__c, 'Max cap score when all conditions are met is 18');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleAutoLeadScoring_Negative(){
            List<Lead> leadsList = [SELECT Id, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE LeadSource != 'Website' AND 
                                                                                                                Email = null AND 
                                                                                                                Phone = null AND 
                                                                                                                Industry = 'Finance'];
            LeadTriggerHandler.handleAutoLeadScoring(leadsList);
            for(Lead ld :leadsList){
                Assert.areEqual(10, ld.Lead_Score__c, 'Score is the base score of 10 when conditions are not met');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleAutoLeadScoring_EdgeCase(){
            List<Lead> leadsList = [SELECT Id, LeadSource, Email, Phone, Lead_Score__c, Industry FROM Lead WHERE LeadSource = 'Website' AND 
                                                                                        Email != null AND 
                                                                                        Phone = null AND
                                                                                        Industry = 'Finance'];
            LeadTriggerHandler.handleAutoLeadScoring(leadsList);
            for(Lead ld: leadsList){
                Assert.areEqual(13, ld.Lead_Score__c, 'Score is 13 when LeadSource as Website and Email not null conditions are met');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleAutoLeadScoring_NullEmptyCases(){
            List<Lead> leadsList = [SELECT Id, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE LeadSource = null AND
                                                                                                                Email = null AND
                                                                                                                Phone = null AND
                                                                                                                Industry = null];
            LeadTriggerHandler.handleAutoLeadScoring(leadsList);
            for(Lead ld: leadsList){
                Assert.areEqual(10, ld.Lead_Score__c, 'Lead is base value as the conditions are null');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleLeadAutoConvert_Positive(){
            Lead ld3 = new Lead(FirstName = 'Test', LastName = 'User3', Company = 'PQR', Email = 'pqr@example.com');
            Lead ld4 = new Lead(FirstName = 'Test', LastName = 'User4', Company = 'TAB', Email = 'tab@example.com');
            List<Lead> lds = new List<Lead> ();
            lds.add(ld3);
            lds.add(ld4);
            insert lds;
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Contact con = new Contact(FirstName = 'Test', LastName = 'User4', Email = 'tab@example.com', AccountId = acc.Id);
            insert con;
            LeadTriggerHandler.handleLeadAutoConvert(lds);
            //Requery the leads after the main class is called to see the updated fields
            List<Lead> updatedLeads = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :lds];
            for(Lead ld: updatedLeads){
                if(ld.Email == con.Email){
                    Assert.areEqual(true, ld.IsConverted, 'Lead should be converted');
                    Assert.areEqual(con.Id, ld.ConvertedContactId, 'Contact names should match');
                }
                else{
                    Assert.areEqual(false, ld.IsConverted, 'Lead without matching Contact should not be converted');
                }
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleLeadAutoConvert_Negative_NoContacts(){
            Lead ld3 = new Lead(FirstName = 'Test', LastName = 'User3', Company = 'PQR', Email = 'pqr@example.com');
            Lead ld4 = new Lead(FirstName = 'Test', LastName = 'User4', Company = 'TAB', Email = 'tab@example.com');
            List<Lead> lds = new List<Lead> ();
            lds.add(ld3);
            lds.add(ld4);
            insert lds;
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Contact con = new Contact(FirstName = 'Test', LastName = 'User4', Email = 'abc@example.com', AccountId = acc.Id);
            insert con;
            LeadTriggerHandler.handleLeadAutoConvert(lds);
            List<Lead> updatedLeads = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :lds];
            for(Lead ld: updatedLeads){
                    Assert.areEqual(false, ld.IsConverted, 'No contact found, leave the lead unconverted');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleLeadAutoConvert_Negative_MultipleContacts(){
            Lead ld3 = new Lead(FirstName = 'Test', LastName = 'User3', Company = 'PQR', Email = 'pqr@example.com');
            Lead ld4 = new Lead(FirstName = 'Test', LastName = 'User4', Company = 'TAB', Email = 'tab@example.com');
            List<Lead> lds = new List<Lead> ();
            lds.add(ld3);
            lds.add(ld4);
            insert lds;
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Contact con1 = new Contact(FirstName = 'Test', LastName = 'User1', Email = 'pqr@example.com', AccountId = acc.Id);
            insert con1;
            Contact con2 = new Contact(FirstName = 'Test', LastName = 'User2', Email = 'pqr@example.com', AccountId = acc.Id);
            insert con2;
            LeadTriggerHandler.handleLeadAutoConvert(lds);
            List<Lead> updatedLeads = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :lds];
            for(Lead ld: updatedLeads){
                Assert.areEqual(false, ld.IsConverted, 'Multiple contacts found, leave the lead unconverted');
            }
        }
        @IsTest
        public static void leadTriggerHandler_testHandleLeadAutoConvert_LeadAlreadyConvertedRecursionCase(){
            Lead ld3 = new Lead(FirstName = 'Test', LastName = 'User3', Company = 'PQR', Email = 'pqr@example.com');
            Lead ld4 = new Lead(FirstName = 'Test', LastName = 'User4', Company = 'TAB', Email = 'tab@example.com');
            List<Lead> lds = new List<Lead> ();
            lds.add(ld3);
            lds.add(ld4);
            insert lds;
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Contact con1 = new Contact(FirstName = 'Test', LastName = 'User1', Email = 'pqr@example.com', AccountId = acc.Id);
            insert con1;
            LeadTriggerHandler.handleLeadAutoConvert(lds);
            List<Lead> updatedLeads = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :lds];
            for(Lead ld: updatedLeads){
                if(ld.email == con1.email){
                    Assert.areEqual(true, ld.IsConverted, 'Lead is converted');
                }
            }
            List<Lead> leadsList = [SELECT Id, Email, IsConverted, ConvertedContactId FROM Lead WHERE Id IN :lds];
            LeadTriggerHandler.handleLeadAutoConvert(leadsList);
            for(Lead ld:leadsList){
                if(ld.email == con1.email && ld.ConvertedContactId == con1.Id){
                    Assert.areEqual(true, ld.IsConverted, 'Lead is already converted, leave the lead');
                }
            }
        }
}