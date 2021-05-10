@isTest
public class TestF_PointsService {
    public static string guid() {
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    @isTest
    static void testExpirationDateInsert(){
        // Given
        FieloPLT__Program__c program = new FieloPLT__Program__c(
            Name = 'Program A',
            FieloPLT__OnlineTransactionProcessing__c = true,
            FieloPLT__CapAdjustmentTransactions__c = true,
            FieloPLT__ExternalId__c = guid()
        );
        insert program;

        FieloPLT__RuleTrigger__c rt = new FieloPLT__RuleTrigger__c(
            Name = 'Event',
            FieloPLT__Object__c = 'FieloPLT__Event__c',
            FieloPLT__Date__c = 'CreatedDate',
            FieloPLT__LookupFromTransaction__c = 'FieloPLT__Event__c',
            FieloPLT__LookupFrompoint__c = 'FieloPLT__Event__c',
            FieloPLT__Status__c = 'Active',
            FieloPLT__Prefix__c = ((sObject)Type.forName('FieloPLT__Event__c').newInstance()).getSObjectType().getDescribe().getKeyPrefix(),
            FieloPLT__ExternalId__c = guid()
		);
        insert rt;

        FieloPLT__Action__c action = new FieloPLT__Action__c(
            FieloPLT__TargetMember__c = 'FieloPLT__Member__c',
            FieloPLT__RuleTrigger__c = rt.Id,
            FieloPLT__ConditionField__c = 'FieloPLT__Type__c',
            FieloPLT__conditionValue__c = 'Registration',
            FieloPLT__ExternalId__c = guid()
        );
        insert action;

        FieloPLT__Promotion__c promotion = new FieloPLT__Promotion__c(
            Name = 'Promotion A',
            FieloPLT__Program__c = program.Id
        );
        insert promotion;

        FieloPLT__Rule__c rule = new FieloPLT__Rule__c(
            Name = 'Rule A',
            FieloPLT__Promotion__c = promotion.Id,
            FieloPLT__ExternalId__c = guid(),
            FieloPLT__PointConversionMode__c = 'Fixed Value',
            FieloPLT__ConversionValue__c = 100,
            FieloPLT__Action__c = action.Id,
            FieloPLT__Type__c = 'No Competition',
            FieloPLT__RelatedList__c = 'FieloPLT__Event__c'
        );
        insert rule;

        promotion.FieloPLT__Status__c = 'Active';
        update promotion;

        FieloPLT__Member__c member =  new FieloPLT__Member__c(
            Name = 'Member A',
            FieloPLT__Email__c = 'member_a@fielo.com',
            FieloPLT__Program__c = program.Id,
            FieloPLT__Type__c = 'Individual Account'
        );
        insert member;

        // When
        Test.startTest();
            FieloPLT.SObjectService.setStaticVariables();
            FieloPLT__Event__c event = new FieloPLT__Event__c(FieloPLT__Member__c = member.Id, FieloPLT__Type__c = 'Registration');
            insert event;
        Test.stopTest();

        // Then
        List<FieloPLT__Point__c> points = [SELECT Id, FieloPLT__TotalPoints__c, FieloPLT__ExpirationDate__c, FieloPLT__ExpirationDateCheck__c,FieloPLT__Status__c, CreatedDate FROM FieloPLT__Point__c WHERE FieloPLT__Transaction__r.FieloPLT__Event__c =: event.Id];
        System.assertEquals(100, points.get(0).FieloPLT__TotalPoints__c, 'Wrong amount of points generated for registration event');

        Date expectedDate = Date.newInstance(points.get(0).CreatedDate.dateGmt().year()+2,12,31);
        String expectedDateKey = String.valueOf(DateTime.newInstance(expectedDate.year(),expectedDate.month(),expectedDate.day()).format('yyyyMMdd'));

        System.assertEquals('Approved', points.get(0).FieloPLT__Status__c, 'Wrong Expiration Date for point record');
        System.assertEquals(expectedDate, points.get(0).FieloPLT__ExpirationDate__c, 'Wrong Expiration Date for point record');
        System.assertEquals(expectedDateKey, points.get(0).FieloPLT__ExpirationDateCheck__c, 'Wrong Expiration Date for point record');
    }
    @isTest
    static void testExpirationDateUpdate(){
        // Given
        FieloPLT__Program__c program = new FieloPLT__Program__c(
            Name = 'Program A',
            FieloPLT__OnlineTransactionProcessing__c = true,
            FieloPLT__CapAdjustmentTransactions__c = true,
            FieloPLT__ExternalId__c = guid()
        );
        insert program;
        
        FieloPLT__ProgramPointType__c ppt = [SELECT Id,RequestPointApproval__c FROM FieloPLT__ProgramPointType__c WHERE FieloPLT__Program__c =: program.Id];
        ppt.RequestPointApproval__c =  true;
        update ppt;

        FieloPLT__RuleTrigger__c rt = new FieloPLT__RuleTrigger__c(
            Name = 'Event',
            FieloPLT__Object__c = 'FieloPLT__Event__c',
            FieloPLT__Date__c = 'CreatedDate',
            FieloPLT__LookupFromTransaction__c = 'FieloPLT__Event__c',
            FieloPLT__LookupFrompoint__c = 'FieloPLT__Event__c',
            FieloPLT__Status__c = 'Active',
            FieloPLT__Prefix__c = ((sObject)Type.forName('FieloPLT__Event__c').newInstance()).getSObjectType().getDescribe().getKeyPrefix(),
            FieloPLT__ExternalId__c = guid()
		);
        insert rt;

        FieloPLT__Action__c action = new FieloPLT__Action__c(
            FieloPLT__TargetMember__c = 'FieloPLT__Member__c',
            FieloPLT__RuleTrigger__c = rt.Id,
            FieloPLT__ConditionField__c = 'FieloPLT__Type__c',
            FieloPLT__conditionValue__c = 'Registration',
            FieloPLT__ExternalId__c = guid()
        );
        insert action;

        FieloPLT__Promotion__c promotion = new FieloPLT__Promotion__c(
            Name = 'Promotion A',
            FieloPLT__Program__c = program.Id
        );
        insert promotion;

        FieloPLT__Rule__c rule = new FieloPLT__Rule__c(
            Name = 'Rule A',
            FieloPLT__Promotion__c = promotion.Id,
            FieloPLT__ExternalId__c = guid(),
            FieloPLT__PointConversionMode__c = 'Fixed Value',
            FieloPLT__ConversionValue__c = 100,
            FieloPLT__Action__c = action.Id,
            FieloPLT__Type__c = 'No Competition',
            FieloPLT__RelatedList__c = 'FieloPLT__Event__c'
        );
        insert rule;

        promotion.FieloPLT__Status__c = 'Active';
        update promotion;

        FieloPLT__Member__c member =  new FieloPLT__Member__c(
            Name = 'Member A',
            FieloPLT__Email__c = 'member_a@fielo.com',
            FieloPLT__Program__c = program.Id,
            FieloPLT__Type__c = 'Individual Account'
        );
        insert member;

        // When
        Test.startTest();
            FieloPLT.SObjectService.setStaticVariables();
            FieloPLT__Event__c event = new FieloPLT__Event__c(FieloPLT__Member__c = member.Id, FieloPLT__Type__c = 'Registration');
            insert event;
        
        	List<FieloPLT__Point__c> pointsToApprove = [SELECT Id, FieloPLT__TotalPoints__c, FieloPLT__ExpirationDate__c, FieloPLT__ExpirationDateCheck__c,FieloPLT__Status__c, CreatedDate FROM FieloPLT__Point__c WHERE FieloPLT__Transaction__r.FieloPLT__Event__c =: event.Id];
        	for(FieloPLT__Point__c p : pointsToApprove){
            	p.Status__c = 'Approved';
        	}
        	update pointsToApprove;
        Test.stopTest();

        // Then
        List<FieloPLT__Point__c> points = [SELECT Id, FieloPLT__TotalPoints__c, FieloPLT__ExpirationDate__c, FieloPLT__ExpirationDateCheck__c,FieloPLT__Status__c, CreatedDate FROM FieloPLT__Point__c WHERE FieloPLT__Transaction__r.FieloPLT__Event__c =: event.Id];
        System.assertEquals(100, points.get(0).FieloPLT__TotalPoints__c, 'Wrong amount of points generated for registration event');

        Date expectedDate = Date.newInstance(points.get(0).CreatedDate.dateGmt().year()+2,12,31);
        String expectedDateKey = String.valueOf(DateTime.newInstance(expectedDate.year(),expectedDate.month(),expectedDate.day()).format('yyyyMMdd'));

        System.assertEquals('Approved', points.get(0).FieloPLT__Status__c, 'Wrong Expiration Date for point record');
        System.assertEquals(expectedDate, points.get(0).FieloPLT__ExpirationDate__c, 'Wrong Expiration Date for point record');
        System.assertEquals(expectedDateKey, points.get(0).FieloPLT__ExpirationDateCheck__c, 'Wrong Expiration Date for point record');
    }
}
