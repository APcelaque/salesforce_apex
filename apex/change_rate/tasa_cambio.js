function obtenerTokenSalesforce() {

    var url = 'https://test.salesforce.com/services/oauth2/token';

    var payload = {
        grant_type: 'password',
        client_id: '3MVG9WCdh6PFin0jRsO0fy05xLNTyZUOrvIl2Y7yLaMGR_trJiauUUZdK2MSd0x_Zm4p7sMdFkOg28Ydi73U3',
        client_secret: 'B3C982BD56F38A96BC7CECB1032CBA9F63835AA3BF15A1E999D9AF366B76CACB', 
        username: 'allan.pineda@celaque.net.devtestv3',
        password: 'Celaque2024*' + 'OX0KIWzYvpQtYjIqiSXT6IGfF'  
    };

    var options = {
        method: 'POST',
        payload: payload,
        muteHttpExceptions: true
    };

    try {
        var response = UrlFetchApp.fetch(url, options);
        var responseData = JSON.parse(response.getContentText());
        
        if (responseData.access_token) {
        Logger.log("Conexión exitosa. Token de acceso: " + responseData.access_token);
        return responseData.access_token;
        } else {
        Logger.log("No se pudo obtener el token de acceso. Respuesta: " + response.getContentText());
        return null;
        }
    } catch (e) {
        Logger.log("Error al conectar con Salesforce: " + e.message);
        return null;
    }
}

function obtenerDatedConversionRate() {
    var token = obtenerTokenSalesforce();
    var url = 'https://celaque--devtestv3.sandbox.my.salesforce.com/services/data/v61.0/query?q=SELECT+Id,+IsoCode,+ConversionRate,+StartDate+FROM+DatedConversionRate';

    if (token) {

        var options = {
            method: 'GET',
            contentType: 'application/json',
            headers: {
                'Authorization': 'Bearer ' + token
            }
        };

        try {
            var response = UrlFetchApp.fetch(url, options);
            Logger.log("Respuesta completa: " + response.getContentText());
            var responseData = JSON.parse(response.getContentText());

            if (responseData.records && responseData.records.length > 0) {
                Logger.log('Se encontraron ' + responseData.records.length + ' registros.');
                
                var registros = responseData.records;
                for (var i = 0; i < registros.length; i++) {
                if (registros[i].IsoCode == 'HNL') {
                    Logger.log('Id: ' + registros[i].Id); 
                    Logger.log('IsoCode: ' + registros[i].IsoCode);
                    Logger.log('ConversionRate: ' + registros[i].ConversionRate);
                    Logger.log('StartDate: ' + registros[i].StartDate);
                }
            
            }

        } else {
            Logger.log('No se encontraron registros en la consulta.');
        }

        } catch (e) {
            Logger.log("Error al obtener registros de Salesforce: " + e.message);
        }
    } else {
        Logger.log("No se pudo obtener el token de acceso. No se realizarán solicitudes a Salesforce.");
    }
}
  
function obtenerYGuardarTipoCambio() {
    
    var url = 'https://bchapi-am.azure-api.net/api/v1/indicadores/620/cifras?formato=Json&ordenamiento=desc&clave=acd6f33468194c77b46fd5397fb05e60';
    var response = UrlFetchApp.fetch(url);
    var responseData = JSON.parse(response.getContentText());
    
    if (responseData && responseData.length > 0) {
    
        var ultimoRegistro = responseData[0]; 
        var valor = ultimoRegistro.Valor;
        var fecha = ultimoRegistro.Fecha.split('T')[0]; 
      
        Logger.log('Último registro obtenido: Valor = ' + valor + ', Fecha = ' + fecha);
      
        // Se obtiene el Token 
        var token = obtenerTokenSalesforce();
      
        if (token) {
    
            var insertUrl = 'https://celaque--devtestv3.sandbox.my.salesforce.com/services/data/v61.0/sobjects/DatedConversionRate';
    
            var insertPayload = {
                IsoCode: 'HNL',
                ConversionRate: parseFloat(valor),
                StartDate: fecha
            };
    
            var insertOptions = {
                method: 'POST',
                contentType: 'application/json',
                headers: {
                    'Authorization': 'Bearer ' + token
                },
                payload: JSON.stringify(insertPayload)
            };
    
            try {
                var insertResponse = UrlFetchApp.fetch(insertUrl, insertOptions);
                Logger.log('Nuevo registro en DatedConversionRate insertado: ' + insertResponse.getContentText());

            } catch (e) {
                Logger.log('Error al insertar en DatedConversionRate: ' + e.message);
            }

        } else {
            Logger.log('No se pudo obtener el token de acceso. No se realizará la inserción en Salesforce.');
        }

    } else {
        Logger.log('No se encontraron registros en la respuesta de la API.');
    }

}
  
  
function actualizarTasaCambio() {
    //obtenerDatedConversionRate(); // Usar esta función, solo si es necesario, de lo contrario no aporta valor. 
    obtenerYGuardarTipoCambio();
}