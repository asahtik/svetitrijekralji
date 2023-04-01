const axios = require('axios');

async function getAllHills(req, res) {
  axios.get('http://localhost:3000/api/collections/hills/records?sort=id&perPage=999', {
    headers: req.headers
  })
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

async function getAllEdges(req, res) {
  const groupId = req.params["groupId"];
  axios.get(`http://localhost:3000/api/collections/edges/records?filter=(group.id='${groupId}')`, {
    headers: req.headers
  })
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

async function getFlaggedHills(req, res) {
    const userId = req.params["userId"];
    axios.get(`http://localhost:3000/api/collections/ascents/records?filter=(user.id='${userId}')&expand=hill&perPage=999`, {
        headers: req.headers
    })
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
    getAllHills,
    getAllEdges,
    getFlaggedHills
}