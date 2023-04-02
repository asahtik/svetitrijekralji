const axios = require('axios');

async function getUsers(req, res) {
  const groupId = req.params["groupId"];
  axios.get(`http://localhost:3000/api/collections/users/records?filter=(group.id='${groupId}')`, {
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
    getUsers
}