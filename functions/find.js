const axios = require('axios')

const API_KEY = 'AIzaSyB11HAsUjP68SILT9CT2paxX7br_Hlbk1g'
const findURL = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
const placeURL = 'https://maps.googleapis.com/maps/api/place/details/json'

module.exports.textToLongLat = async function(text) {
    try {
        const response = await axios.get(findURL, {
            params: {
                key: API_KEY,
                input: removeNumbers(text) + " waterloo",
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
        const location = response2.data.result.geometry.location
        return location;
    } catch (error) {
        console.error(error);
    }
}

const removeNumbers = str => str.replace(/[0-9]/g, '');

module.exports.textToLocation = async function(text) {
    try {
        const response = await axios.get(findURL, {
            params: {
                key: API_KEY,
                input: removeNumbers(text) + " waterloo",
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
        const lat = response2.data.result.geometry.location.lat
        const long = response2.data.result.geometry.location.lng
        const street = response2.data.result.formatted_address

        return {
            street,
            lat,
            long
        };
    } catch (error) {
        console.error(error);
    }
}