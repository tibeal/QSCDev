trigger F_Points on FieloPLT__Point__c (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        F_PointsService.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        F_PointsService.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}