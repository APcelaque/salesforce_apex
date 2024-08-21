public class MoraAlertController0 {
    @AuraEnabled
    public static Map<String, Object> checkMora(Id recordId) {
        // Suponiendo que la oportunidad está relacionada con la factura a través de la cuenta
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :recordId LIMIT 1];
        List<Invoice__c> invoices = [SELECT Id, fw1__Age__c FROM Invoice__c WHERE fw1__Account__c = :opp.AccountId AND fw1__Age__c > 0];
        
        Map<String, Object> result = new Map<String, Object>();
        if (!invoices.isEmpty()) {
            result.put('isMora', true);
            result.put('message', 'El cliente tiene facturas pendientes con mora.');
        } else {
            result.put('isMora', false);
        }
        return result;
    }
}

public with sharing class MoraAlertController {
    @AuraEnabled
    public static Map<String, Object> getMoraStatus(Id accountId) {
        Map<String, Object> result = new Map<String, Object>();
        Boolean hasMora = false;
        String message = '';
        
        List<fw1__Invoice__c> invoices = [SELECT Id, fw1__Age__c FROM Invoice__c WHERE fw1__Account__c = :accountId AND fw1__Age__c > 0];
        
        if (!invoices.isEmpty()) {
            hasMora = true;
            message = 'El cliente tiene facturas con mora.';
        }
        
        result.put('hasMora', hasMora);
        result.put('message', message);
        
        return result;
    }
}