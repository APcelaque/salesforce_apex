const axios = require('axios');

// const url = 'https://bchapi-am.azure-api.net/api/v1/indicadores/620/cifras?formato=Json&ordenamiento=desc&clave=acd6f33468194c77b46fd5397fb05e60';
const url = 'https://bchapi-am.azure-api.net/api/v1/indicadores/620/cifras?formato=Json&fechaInicio=2017-01-01&ordenamiento=asc&clave=04d1c14361564cbfa78b0c37eb2398af';

axios.get(url)
    .then(response => {
        console.log(response.data);
    })
    .catch(error => {
        console.log(error);
    });