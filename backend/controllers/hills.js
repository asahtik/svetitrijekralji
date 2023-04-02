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

async function getGroupAscents(req, res) {
  const groupId = req.params["groupId"];
  axios.get(`http://localhost:3000/api/collections/ascents/records?filter=(group.id='${groupId}')&sort=-created&perPage=999`, {
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

async function flagAscent(req, res) {
  const ascentId = req.params["ascentId"];
  const userId = req.body["userId"];

  try {
    await axios.patch(`http://localhost:3000/api/collections/ascents/records/${ascentId}`, {
      "user": userId
    }, {
      headers: req.headers
    });
    await axios.post("http://localhost:3000/api/collections/ascenthistory/records", {
      "ascent": ascentId,
      "user": userId,
      "time": new Date().toISOString()
    }, {
      headers: req.headers
    })
  } catch (e) {
    if (e.response) {
      res.status(e.response.status).json(e.response.statusText);
    } else {
      res.status(500).json({"error": "Internal error"});
    }
  }
}

module.exports = {
    getAllHills,
    getGroupAscents,
    getAllEdges,
    getFlaggedHills,
    flagAscent
}