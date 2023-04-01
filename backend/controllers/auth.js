const axios = require('axios');

async function login(req, res) {
  axios.post('http://localhost:3000/api/collections/users/auth-with-password', req.body)
  .then(function (response) {
    res.status(200).json(response.data);
  })
  .catch(function (error) {
    if (error.response) {
        res.status(error.response.status).json(error.response.data)
    } else {
        res.status(500).json(error);
    }
  });
}

async function register(req, res) {
  axios.post('http://localhost:3000/api/collections/users/records', req.body)
  .then(function (response) {
    res.status(200).json(response.data);
  })
  .catch(function (error) {
    if (error.response) {
        res.status(error.response.status).json(error.response.data)
    } else {
        res.status(500).json(error);
    }
  });
}

module.exports = {
    login,
    register
}