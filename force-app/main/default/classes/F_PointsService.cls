public class F_PointsService {

    public static void onBeforeInsert(List<FieloPLT__Point__c> records) {
        Set<Id> pointTypeIds = new Set<Id>();
        List<FieloPLT__Point__c> approvedPoints = new List<FieloPLT__Point__c>();

        for (FieloPLT__Point__c p : records) {
            if (p.FieloPLT__Status__c == 'Approved') {
                pointTypeIds.add(p.FieloPLT__PointType__c);
                approvedPoints.add(p);
            }
        }

        if (!approvedPoints.isEmpty()) {
            Map<Id, FieloPLT__PointType__c> pointTypesMap = new Map<Id, FieloPLT__PointType__c>(
                (List<FieloPLT__PointType__c>) Database.query(
                    'SELECT Id, Name FROM FieloPLT__PointType__c WHERE Id IN : pointTypeIds'
                )
            );

            setExpirationDate(approvedPoints, pointTypesMap);
        }
    }

    public static void onBeforeUpdate(List<FieloPLT__Point__c> records, Map<Id, FieloPLT__Point__c> existingRecords) {
        Set<Id> pointTypeIds = new Set<Id>();
        List<FieloPLT__Point__c> approvedPoints = new List<FieloPLT__Point__c>();

        for (FieloPLT__Point__c p : records) {
            FieloPLT__Point__c oldRecord = existingRecords.get(p.Id);
            if(p.FieloPLT__Status__c == 'Approved'  && oldRecord.FieloPLT__Status__c != 'Approved') {
                pointTypeIds.add(p.FieloPLT__PointType__c);
                approvedPoints.add(p);
            }
        }

        if (!approvedPoints.isEmpty()) {
            Map<Id, FieloPLT__PointType__c> pointTypesMap = new Map<Id, FieloPLT__PointType__c>(
                (List<FieloPLT__PointType__c>) Database.query(
                    'SELECT Id, Name FROM FieloPLT__PointType__c WHERE Id IN : pointTypeIds'
                )
            );

            setExpirationDate(approvedPoints, pointTypesMap);
        }
    }

    public static void setExpirationDate(List<FieloPLT__Point__c> records, Map<Id, FieloPLT__PointType__c> pointTypesMap) {
        for (FieloPLT__Point__c p : records) {
            if (pointTypesMap?.get(p.FieloPLT__PointType__c)?.Name == 'Point') {
                Datetime refDatetime = p.CreatedDate != null ? p.CreatedDate : System.now();
                p.FieloPLT__ExpirationDate__c = Date.newInstance(refDatetime.dateGmt().year()+2,12,31);

                System.assert(p.FieloPLT__ExpirationDate__c != null, 'Expiration date should not be null');

                p.FieloPLT__ExpirationDateCheck__c = String.valueOf(
                    DateTime.newInstance(
                        p.FieloPLT__ExpirationDate__c.year(),
                        p.FieloPLT__ExpirationDate__c.month(),
                        p.FieloPLT__ExpirationDate__c.day()
                    ).format('yyyyMMdd')
                );
            }
        }
    }
}
