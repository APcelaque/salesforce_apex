public with sharing class MoraController {
    @AuraEnabled
    public static Boolean checkMora(id, oppId) {
        try {

            Opportunity opp = [SELECT cliente_en_mora__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
            return opp.cliente_en_mora__c;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}

public static Boolean tieneMora(Id cuentaId) {
    // Consultar el objeto Mora 
    List<Mora__c> moraList = [SELECT Id 
                              FROM Mora__c 
                              WHERE Cuenta__c = :cuentaId 
                              AND MontoMora__c > 0
                              LIMIT 1];
    
    // verificar si la lista de moras no está vacía
    return !moraList.isEmpty();
}

trigger OportunidadMoraTrigger on Opportunity (before insert, before update) {
    for (Opportunity opp : Trigger.new) {
        // Verificar si la cuenta tiene mora
        if (MoraController.tieneMora(opp.AccountId)) {
            opp.Cliente_en_Mora__c = true;
        } else {
            opp.Cliente_en_Mora__c = false;
        }
    }
}

public with sharing class MoraAlertController {
    @AuraEnabled(cacheable=true)
    public static Boolean tieneMora(Id opportunityId) {
        // Obtener la Oportunidad
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        
        // Verificar si hay facturas con mora (Age > 0)
        List<Invoice__c> invoices = [SELECT Age__c FROM Invoice__c WHERE AccountId = :opp.AccountId AND Age__c > 0 LIMIT 1];
        
        return invoices.size() > 0;
    }
}