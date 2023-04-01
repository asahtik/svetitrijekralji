var express = require('express');
const axios = require('axios'); // node
var router = express.Router();

async function login() {
  axios.post('http://localhost:8090/api/collections/users/auth-with-password', {
    identity: 'test@test.com',
    password: 'testtest'
  })
  .then(function (response) {
    console.log(response.data.token);
    return response.data.token;
  })
  .catch(function (error) {
    console.log(error);
  });
}

token = login();

async function getMountains() {
  var response = await axios.get('http://localhost:8090/api/collections/mountains/records', {
    headers: {
      'Autharization': token
  }}).catch(function (error) {
    console.log(error);
  });
  return response != null ? response.data : null;
}

async function getAscents() {
  var response = await axios.get('http://localhost:8090/api/collections/ascents/records', {
    headers: {
      'Autharization': token
  }}).catch(function (error) {
    console.log(error);
  });
  return response != null ? response.data : null;
}

async function getConnections() {
  var response = await axios.get('http://localhost:8090/api/collections/connections/records', {
    headers: {
      'Autharization': token
  }}).catch(function (error) {
    console.log(error);
  });
  return response != null ? response.data : null;
}

/* GET home page. */
router.get('/', async function(req, res, next) {
  res.json(await getMountains());
});

router.get('/ascents/', async function(req, res, next) {
  res.json(await getAscents());
});

router.get('/connections/', async function(req, res, next) {
  res.json(await getConnections());
});


module.exports = router;
