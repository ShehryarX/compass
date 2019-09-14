const axios = require('axios')

const API_KEY = 'AIzaSyB11HAsUjP68SILT9CT2paxX7br_Hlbk1g'
const findURL = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
const placeURL = 'https://maps.googleapis.com/maps/api/place/details/json'

module.exports.textToLongLat = async function(text) {
    try {
        const response = await axios.get(findURL, {
            params: {
                key: API_KEY,
                input: text,
                inputtype: "textquery"
            }
        });
        const place_id = response.data.candidates[0].place_id
        const response2 = await axios.get(placeURL, {
            params: {
                key: API_KEY,
                place_id: place_id,
            }
        })
    } catch (error) {
        console.error(error);
    }

    .then(function(response) {

            .then(function(response) {
                    const location = response.data.result.geometry.location
                    return location;
                })
                .catch(function(error) {
                    console.log(error);
                })
        })
        .catch(function(error) {
            console.log(error);
        })
}



module.exports.textToLocation = function(text) {
    axios.get(findURL, {
            params: {
                key: API_KEY,
                input: text,
                inputtype: "textquery"
            }
        })
        .then(function(response) {
            const place_id = response.data.candidates[0].place_id
            axios.get(placeURL, {
                    params: {
                        key: API_KEY,
                        place_id: place_id,
                    }
                })
                .then(function(response) {
                    const placeAPI = response.data.result.geometry.location
                    console.log(response.data.result)
                    return (placeAPI);
                })
                .catch(function(error) {
                    console.log(error);
                })
        })
        .catch(function(error) {
            console.log(error);
        })
}