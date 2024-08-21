public class tasa_cambio_prueba {

    public void actualizarYGuardarHistorial() {
        String url = 'https://bchapi-am.azure-api.net/api/v1/indicadores/620/cifras?formato=Json&clave=acd6f33468194c77b46fd5397fb05e60';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Deserializar la respuesta JSON como una lista
            List<Object> responseList = (List<Object>) JSON.deserializeUntyped(res.getBody());

            if (responseList != null && !responseList.isEmpty()) {
                // Iniciar variables para almacenar el último registro
                Map<String, Object> lastRecord = null;
                Date latestDate = Date.newInstance(1900, 1, 1);

                // Iterar sobre los registros para encontrar el más reciente
                for (Object recordObj : responseList) {
                    Map<String, Object> record = (Map<String, Object>) recordObj;
                    String fechaStr = (String) record.get('Fecha');
                    Date fecha = Date.valueOf(fechaStr.split('T')[0]); // Convertir a objeto Date

                    // Verificar si este es el registro más reciente
                    if (fecha > latestDate) {
                        latestDate = fecha;
                        lastRecord = record;
                    }
                }

                if (lastRecord != null) {
                    // Extraer el valor y la fecha
                    String valor = String.valueOf(lastRecord.get('Valor'));
                    String fecha = String.valueOf(lastRecord.get('Fecha'));

                    // Formatear la salida para debug
                    System.debug('Último registro formateado: ' + valor + ', Fecha: ' + fecha);

                    // Actualizar el registro existente en DatedConversionRate
                    try {
                        DatedConversionRate dcr = [SELECT Id, IsoCode, ConversionRate, StartDate 
                                                   FROM DatedConversionRate 
                                                   WHERE IsoCode = 'HNL' AND StartDate = :Date.today()
                                                   LIMIT 1];

                        if (dcr != null) {
                            // Actualizar el registro existente con los nuevos valores
                            dcr.ConversionRate = Decimal.valueOf(valor);
                            update dcr;
                            System.debug('Registro de DatedConversionRate actualizado.');
                        } else {
                            System.debug('No se encontró un registro de DatedConversionRate para actualizar.');
                        }
                    } catch (Exception e) {
                        System.debug('Error al actualizar DatedConversionRate: ' + e.getMessage());
                    }

                    // Insertar un nuevo registro en Exchange_Rate__c para el historial
                    try {
                        Exchange_Rate__c exchangeRate = new Exchange_Rate__c();
                        exchangeRate.CurrencyIsoCode = 'HNL'; // Debes ajustar según sea necesario
                        exchangeRate.Rate__c = Decimal.valueOf(valor);
                        exchangeRate.Effective_Date__c = Date.valueOf(fecha.split('T')[0]);
                        exchangeRate.Currency_Code__c = 'HNL'; // Ajustar según corresponda

                        insert exchangeRate;
                        System.debug('Registro en Exchange_Rate__c insertado con éxito.');
                    } catch (Exception e) {
                        System.debug('Error al insertar en Exchange_Rate__c: ' + e.getMessage());
                    }
                } else {
                    System.debug('No se encontró un registro válido en la API.');
                }
            } else {
                System.debug('No se encontraron registros en la respuesta de la API.');
            }
        } else {
            System.debug('Error en la solicitud: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
    }
}